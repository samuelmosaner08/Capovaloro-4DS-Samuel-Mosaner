// ============================================================
// AIVIA — Elaborato di Tirocinio 2025/2026
// main.js — Lingua, navigazione, animazioni
// ============================================================

let currentLang = localStorage.getItem('lang') || 'it';
let isDark = localStorage.getItem('theme') !== 'light';

// ── Lingua ──────────────────────────────────────────────────
function setLang(lang) {
  document.body.classList.remove('lang-it', 'lang-en');
  document.body.classList.add('lang-' + lang);
  currentLang = lang;
  localStorage.setItem('lang', lang);
  const btn = document.getElementById('lang-btn');
  if (btn) btn.textContent = lang === 'it' ? 'EN' : 'IT';
}

function toggleLang() {
  setLang(currentLang === 'it' ? 'en' : 'it');
}

// ── Tema Dark / Light ────────────────────────────────────────
function applyTheme() {
  document.body.classList.toggle('light-mode', !isDark);
  const btn = document.getElementById('theme-btn');
  if (btn) btn.textContent = isDark ? '☀️' : '🌙';
}

function toggleTheme() {
  isDark = !isDark;
  localStorage.setItem('theme', isDark ? 'dark' : 'light');
  applyTheme();
}

// ── Navbar scroll ────────────────────────────────────────────
function onScroll() {
  const nav = document.querySelector('.navbar');
  if (nav) nav.classList.toggle('scrolled', window.scrollY > 40);
  updateActiveNav();
}

function updateActiveNav() {
  const sections = Array.from(document.querySelectorAll('section[id]'));
  const scrollY = window.scrollY + 100;
  let current = '';
  sections.forEach(s => { if (scrollY >= s.offsetTop) current = s.id; });
  document.querySelectorAll('.nav-link').forEach(link => {
    link.classList.toggle('active', link.getAttribute('href') === '#' + current);
  });
}

// ── Menu mobile ──────────────────────────────────────────────
function toggleMenu() {
  const menu = document.getElementById('mobile-menu');
  if (menu) menu.classList.toggle('open');
}

function closeMenu() {
  const menu = document.getElementById('mobile-menu');
  if (menu) menu.classList.remove('open');
}

// ── Skill bars (IntersectionObserver) ────────────────────────
function initSkillBars() {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const fill = entry.target.querySelector('.skill-fill');
      const val = entry.target.dataset.skill;
      if (fill && val) fill.style.width = val + '%';
      observer.unobserve(entry.target);
    });
  }, { threshold: 0.3 });

  document.querySelectorAll('.skill-item[data-skill]').forEach(el => observer.observe(el));
}

// ── Smooth scroll ────────────────────────────────────────────
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(link => {
    link.addEventListener('click', e => {
      const target = document.querySelector(link.getAttribute('href'));
      if (!target) return;
      e.preventDefault();
      closeMenu();
      const offset = target.getBoundingClientRect().top + window.scrollY - 70;
      window.scrollTo({ top: offset, behavior: 'smooth' });
    });
  });
}

// ── Init ─────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  setLang(currentLang);
  applyTheme();
  initSkillBars();
  initSmoothScroll();

  window.addEventListener('scroll', onScroll, { passive: true });

  if (typeof AOS !== 'undefined') {
    AOS.init({ duration: 650, easing: 'ease-out', once: true, offset: 70 });
  }
});
