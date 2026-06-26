# Piano: Capolavoro 4^ — Sito Elaborato Tirocinio Aivia

## Contesto

Elaborato finale del tirocinio scolastico (4° anno). Sito statico puro che documenta il lavoro svolto su Aivia: piattaforma IoT per monitoraggio urbano. Bilingue IT/EN.

## Struttura del Progetto

```
Capolavoro 4^/
├── PIANO.md            ← questo file
├── index.html          ← pagina principale (single-page)
├── css/
│   └── style.css       ← design system completo
├── js/
│   ├── main.js         ← lingua IT/EN, navbar, skill bars
│   └── charts.js       ← Chart.js grafici demo
├── assets/
│   ├── screenshots/    ← screenshot reali app (da inserire)
│   └── diagrams/       ← diagrammi SVG
└── sql/
    └── schema.sql      ← schema PostgreSQL con query di esempio
```

## Tecnologie Usate per il Sito

- HTML5 semantico
- CSS3 custom (variabili, grid, flexbox, animazioni)
- JavaScript vanilla (ES2020+)
- **CDN (zero installazione):**
  - AOS 2.3 — animazioni scroll
  - Chart.js 4.4 — grafico demo sensori
  - Prism.js 1.29 — syntax highlighting SQL/JS
  - Google Fonts (Inter + JetBrains Mono)

## Sezioni del Sito

1. **Hero** — Titolo, badge, tech tags, CTA
2. **Il Progetto** — Descrizione Aivia, 6 feature card
3. **Architettura** — Diagramma 5 livelli, pattern chiave
4. **Stack Tecnologico** — ~20 tech card per categoria
5. **Gestione Dati** — ER diagram, query SQL, tabella aggregazione
6. **Sensori e IoT** — Flowchart 5 step, grafico Chart.js
7. **Telecamere** — Milestone XProtect, snippet JS fullscreen
8. **Dashboard** — 12 tipi widget, grid layout, parent-child
9. **Mappa** — OpenLayers, marker, touch, fullscreen
10. **Deploy** — Git branches, CI/CD pipeline 3 step
11. **Competenze** — Tabella prima/dopo, progress bar animate

## Come Aprire

Aprire `index.html` direttamente nel browser (doppio click).  
Nessun server o build necessario.

## Cose da Completare

- [ ] Sostituire `[NOME STUDENTE]` con il nome reale
- [ ] Sostituire `[CLASSE]` con la classe (es. `4^A`)
- [ ] Sostituire `[NOME ISTITUTO]` con il nome della scuola
- [ ] Sostituire `[DATA INIZIO]` e `[DATA FINE]` con le date del tirocinio
- [ ] Inserire screenshot reali nella cartella `assets/screenshots/`
      e aggiornare i placeholder nel HTML (`<div class="screenshot-ph">`)

## Design System

| Variabile | Valore |
|---|---|
| Primary | `#07078E` (navy Aivia) |
| Accent | `#4f46e5` (indigo) |
| Background | `#0d0d1f` |
| Surface card | `#1a1a35` |
| Testo | `#f8fafc` / `#94a3b8` muted |
| Font | Inter (testo) + JetBrains Mono (codice) |
