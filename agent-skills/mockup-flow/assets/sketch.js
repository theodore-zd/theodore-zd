// sketch.js — shared p5 helpers for mockup-flow sets: reads the set's CSS
// variables so every sketch follows the current theme (light / dark / accent
// variants) automatically. Requires p5 (CDN) loaded before this file.
window.MK = (() => {
  function theme() {
    const cs = getComputedStyle(document.body);
    const v = (n, f) => (cs.getPropertyValue(n).trim() || f);
    return {
      accent: v('--accent', '#e8710a'),
      ink: v('--ink', '#1f1f1c'),
      paper: v('--paper', '#ffffff'),
      line: v('--line', '#8d8d87'),
      muted: v('--muted', '#e6e6e1'),
    };
  }
  function rgba(hex, a) {
    const s = hex.replace('#', '');
    const n = parseInt(s.length === 3 ? s.split('').map(c => c + c).join('') : s, 16);
    return 'rgba(' + ((n >> 16) & 255) + ',' + ((n >> 8) & 255) + ',' + (n & 255) + ',' + a + ')';
  }
  // mount(p, containerId, height) -> {w, h}; wires resize to container width.
  function mount(p, id, h) {
    const el = document.getElementById(id);
    const w = Math.max((el && el.clientWidth) || window.innerWidth - 32, 280);
    p.createCanvas(w, h).parent(id);
    p.pixelDensity(2);
    p.windowResized = () => {
      const cw = Math.max((el && el.clientWidth) || window.innerWidth - 32, 280);
      p.resizeCanvas(cw, h);
    };
    return { w: w, h: h };
  }
  return { theme: theme, rgba: rgba, mount: mount };
})();