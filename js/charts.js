// ============================================================
// AIVIA — Grafici demo (Chart.js)
// ============================================================

document.addEventListener('DOMContentLoaded', () => {
  if (typeof Chart === 'undefined') return;

  // Configura stile globale
  Chart.defaults.color = '#94a3b8';
  Chart.defaults.borderColor = 'rgba(255,255,255,0.05)';

  initSensorChart();
});

function initSensorChart() {
  const ctx = document.getElementById('sensor-chart');
  if (!ctx) return;

  const hours = Array.from({ length: 24 }, (_, i) => `${String(i).padStart(2, '0')}:00`);

  // Dati simulati: occupazione parcheggio (%) nelle 24 ore
  const occupancy = [
    8, 5, 3, 2, 2, 5, 18, 42,
    68, 80, 85, 88, 84, 78, 80, 84,
    75, 60, 45, 35, 28, 22, 18, 12
  ];

  const colors = occupancy.map(v =>
    v >= 80 ? 'rgba(239,68,68,0.75)' :
    v >= 60 ? 'rgba(245,158,11,0.75)' :
              'rgba(79,70,229,0.75)'
  );

  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: hours,
      datasets: [{
        label: document.body.classList.contains('lang-en')
          ? 'Parking occupancy (%)'
          : 'Occupazione parcheggio (%)',
        data: occupancy,
        backgroundColor: colors,
        borderRadius: 5,
        borderSkipped: false,
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          labels: { font: { size: 12 }, color: '#94a3b8' }
        },
        tooltip: {
          callbacks: {
            label: ctx => ` ${ctx.parsed.y}% occupato`
          }
        }
      },
      scales: {
        x: {
          ticks: { color: '#64748b', font: { size: 11 }, maxRotation: 0 },
          grid: { color: 'rgba(255,255,255,0.04)' }
        },
        y: {
          min: 0, max: 100,
          ticks: { color: '#64748b', font: { size: 11 }, callback: v => v + '%' },
          grid: { color: 'rgba(255,255,255,0.04)' },
          title: { display: true, text: 'Occupazione (%)', color: '#64748b', font: { size: 11 } }
        }
      }
    }
  });
}
