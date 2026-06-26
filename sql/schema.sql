-- ============================================================
-- AIVIA PLATFORM — DATABASE SCHEMA (PostgreSQL)
-- Elaborato di Tirocinio 2025/2026
-- ============================================================

-- Funzione helper: genera ID casuali alfanumerici (32 char)
CREATE OR REPLACE FUNCTION get_random_string(length integer) RETURNS TEXT AS $$
DECLARE
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
BEGIN
  FOR i IN 1..length LOOP
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE 'plpgsql';


-- ============================================================
-- UTENTI E AUTENTICAZIONE
-- ============================================================

-- Utenti dell'applicazione — credenziali, ruolo, profilo
CREATE TABLE IF NOT EXISTS users (
    id char(32) NOT NULL PRIMARY KEY DEFAULT get_random_string(32),
    email text UNIQUE,
    role varchar,                    -- SYSTEM_ADMIN | ADMIN | MANAGER | OPERATOR | REPORT
    password text,                   -- hash bcryptjs
    reset_token text,
    reset_token_expiration timestamptz,
    details jsonb,                   -- { name, surname, preferences }
    profile_image_url text,
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_updated_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on timestamptz           -- NULL = attivo (soft delete)
);


-- ============================================================
-- ORGANIZZAZIONI E LOCATION (Multi-tenant)
-- ============================================================

-- Ogni organizzazione ha la propria dashboard e configurazione
CREATE TABLE IF NOT EXISTS organizations (
    id char(32) NOT NULL PRIMARY KEY DEFAULT get_random_string(32),
    details jsonb,                   -- { name, city, country, type }
    logo_url text,
    login_background_url text,
    default_location char(32),
    bots_enabled boolean,
    bots_usage_today int,
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on timestamptz
);

-- Location: area geografica monitorata (es. "Centro Storico Milano")
CREATE TABLE IF NOT EXISTS locations (
    id char(32) NOT NULL PRIMARY KEY DEFAULT get_random_string(32),
    details jsonb,                   -- { name, description, coordinates }
    is_default_of_user boolean DEFAULT false,
    organization char(32) NOT NULL REFERENCES organizations(id),
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on timestamptz
);

-- Relazione molti-a-molti utenti/organizzazioni con ruolo specifico
CREATE TABLE IF NOT EXISTS user_organizations (
    user_id char(32) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    organization char(32) NOT NULL REFERENCES organizations(id),
    role varchar,
    deleted_on timestamptz
);


-- ============================================================
-- WIDGET (SENSORI, TELECAMERE, DISPOSITIVI)
-- ============================================================

-- Widget: ogni sensore, telecamera o dispositivo visualizzato in dashboard.
-- Il campo 'details' (JSONB) contiene la configurazione specifica
-- per ognuno dei 15+ tipi widget supportati.
-- La colonna 'related_widget' implementa la relazione padre-figlio:
-- un widget CAMERA può avere widget METRIC figli (analytics).
CREATE TABLE IF NOT EXISTS widgets (
    id char(32) NOT NULL PRIMARY KEY DEFAULT get_random_string(32),
    related_widget char(32) REFERENCES widgets(id),  -- gerarchia padre→figlio
    details jsonb,
    image_url text,
    organization char(32) NOT NULL REFERENCES organizations(id),
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on timestamptz
);

-- Esempio details JSONB per widget telecamera Milestone:
-- {
--   "type": "CAMERA",
--   "name": "Telecamera Piazza Centrale",
--   "position": { "lat": 45.464, "lng": 9.188 },
--   "externalCode": "cam-001",
--   "manufacturer": "MILESTONE",
--   "frameStoreHost": "https://framestore.aivia.io",
--   "installationPlace": "PARKING"
-- }
--
-- Esempio details JSONB per widget sensore generico (bidone):
-- {
--   "type": "GENERIC",
--   "name": "Bidone Via Roma",
--   "metricType": "GENERIC",
--   "ceiling": 100,
--   "position": { "lat": 45.465, "lng": 9.190 }
-- }

-- Dashboard: mappa widget → location con posizione ordinata
CREATE TABLE IF NOT EXISTS dashboards (
    id char(32) NOT NULL PRIMARY KEY DEFAULT get_random_string(32),
    location_id char(32) NOT NULL REFERENCES locations(id),
    widget_id char(32) NOT NULL REFERENCES widgets(id),
    widget_position int NOT NULL,
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on timestamptz
);


-- ============================================================
-- METRICHE — DATI TIME-SERIES
-- ============================================================

-- Ogni lettura di un sensore = una riga in questa tabella.
-- Struttura intenzionalmente semplice: valore TEXT per supportare
-- qualsiasi tipo di dato (numerico, enum, JSON embedded).
CREATE TABLE IF NOT EXISTS metrics (
    id char(32) NOT NULL PRIMARY KEY DEFAULT get_random_string(32),
    widget_id char(32) REFERENCES widgets(id),
    value TEXT,                      -- valore letto dal sensore
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_metrics_widget_id ON metrics(widget_id);

-- Alert visivi: cambiano colore del marker sulla mappa in base a soglie
CREATE TABLE IF NOT EXISTS metric_visual_alerts (
    id char(32) NOT NULL PRIMARY KEY DEFAULT get_random_string(32),
    metric_widget_id char(32) REFERENCES widgets(id),
    widget_id char(32) REFERENCES widgets(id),
    comparison_operator varchar(60) NOT NULL,  -- > | < | >= | <= | = | !=
    comparison_value varchar(60) NOT NULL,
    color varchar(50),               -- colore CSS (es. "#ef4444")
    priority int NOT NULL,           -- priorità: vince il valore più alto
    metric_type varchar(60) NOT NULL,
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on timestamptz
);


-- ============================================================
-- NOTIFICHE E ALERT
-- ============================================================

-- Regole di notifica: definisce QUANDO scattare un'allerta
CREATE TABLE IF NOT EXISTS notifications (
    id char(32) NOT NULL PRIMARY KEY DEFAULT get_random_string(32),
    name varchar(300) NOT NULL,
    enabled boolean NOT NULL,
    metric_type varchar(32) NOT NULL,
    widget_id char(32) REFERENCES widgets(id),
    comparison_operator varchar(60) NOT NULL,
    comparison_value varchar(60),
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on timestamptz
);

-- Storico notifiche inviate — audit trail completo con stato lettura
CREATE TABLE IF NOT EXISTS fired_notifications (
    id char(32) NOT NULL PRIMARY KEY DEFAULT get_random_string(32),
    notification_id char(32) NOT NULL REFERENCES notifications(id),
    user_id char(32) NOT NULL REFERENCES users(id),
    fired_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    event_at timestamptz,
    value text,                      -- valore che ha triggerato l'alert
    read_at timestamptz,             -- NULL = non letta
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_on timestamptz
);


-- ============================================================
-- QUERY DI ESEMPIO
-- ============================================================

-- 1. Campionamento metriche con aggregazione oraria (usato dal backend)
SELECT
    widget_id,
    AVG(value::numeric)              AS media_valore,
    DATE_TRUNC('hour', created_on)   AS ora
FROM metrics
WHERE
    widget_id = 'abc123def456'
    AND created_on >= NOW() - INTERVAL '24 hours'
GROUP BY widget_id, ora
ORDER BY ora ASC;


-- 2. Tutti i widget di una dashboard con alert visivi (usato da getDashboardByLocationId)
SELECT
    w.id,
    w.details,
    w.details->>'name'           AS widget_name,
    w.details->>'type'           AS widget_type,
    w.details->'position'->>'lat' AS lat,
    w.details->'position'->>'lng' AS lng,
    d.widget_position,
    json_agg(mva.*) FILTER (WHERE mva.id IS NOT NULL) AS visual_alerts
FROM widgets w
JOIN dashboards d
    ON d.widget_id = w.id
    AND d.deleted_on IS NULL              -- soft delete automatico
LEFT JOIN metric_visual_alerts mva
    ON mva.widget_id = w.id
    AND mva.deleted_on IS NULL
WHERE
    d.location_id = 'location_id_here'
    AND w.deleted_on IS NULL
GROUP BY w.id, d.widget_position
ORDER BY d.widget_position ASC;


-- 3. Notifiche non lette di un utente (usato dalla notification center)
SELECT
    fn.id,
    fn.fired_at,
    fn.value,
    fn.read_at,
    n.name           AS notification_name,
    n.metric_type,
    n.comparison_operator,
    n.comparison_value
FROM fired_notifications fn
JOIN notifications n ON n.id = fn.notification_id
WHERE
    fn.user_id = 'user_id_here'
    AND fn.read_at IS NULL
    AND fn.deleted_on IS NULL
ORDER BY fn.fired_at DESC
LIMIT 50;
