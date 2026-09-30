// flow.js — draws navigation connectors between frames on a .flow-canvas.
// Usage: Flow.connect('from-id', 'to-id', 'Label', {via:'h'|'v', primary:true, out:.5, in:.5});
//   via     — 'h' horizontal exit/entry (left/right sides), 'v' vertical (top/bottom),
//             default 'auto' picks the dominant delta.
//   primary — happy path: accent line + label.
//   out/in  — 0..1 position along the exit/entry edge (default .5).
// Connectors recompute on load and resize; call Flow.render() after layout changes.
window.Flow = (() => {
  const REG = [];

  function rects(aId, bId) {
    const a = document.getElementById(aId);
    const b = document.getElementById(bId);
    if (!a || !b) throw new Error('flow: missing frame ' + (!a ? aId : bId));
    const canvas = a.closest('.flow-canvas');
    const cr = canvas.getBoundingClientRect();
    const ar = a.getBoundingClientRect();
    const br = b.getBoundingClientRect();
    return {
      canvas,
      a: { x: ar.left - cr.left, y: ar.top - cr.top, w: ar.width, h: ar.height },
      b: { x: br.left - cr.left, y: br.top - cr.top, w: br.width, h: br.height },
    };
  }

  function seg(canvas, x, y, w, h, primary) {
    const d = document.createElement('div');
    d.className = 'connector-seg' + (primary ? ' primary' : '');
    d.style.left = x + 'px';
    d.style.top = y + 'px';
    d.style.width = Math.max(Math.abs(w), 1) + 'px';
    d.style.height = Math.max(Math.abs(h), 1) + 'px';
    if (w < 0) d.style.left = (x + w) + 'px';
    if (h < 0) d.style.top = (y + h) + 'px';
    canvas.appendChild(d);
  }

  function head(canvas, x, y, dir, primary) {
    const d = document.createElement('div');
    d.className = 'connector-head' + (primary ? ' primary' : '');
    d.style.left = (x - 5) + 'px';
    d.style.top = (y - 5) + 'px';
    d.style.transform = 'rotate(' + { right: 0, down: 90, left: 180, up: 270 }[dir] + 'deg)';
    canvas.appendChild(d);
  }

  function label(canvas, x, y, text, primary) {
    const d = document.createElement('div');
    d.className = 'connector-label' + (primary ? ' primary' : '');
    d.textContent = text;
    canvas.appendChild(d);
    requestAnimationFrame(() => {
      d.style.left = (x - d.offsetWidth / 2) + 'px';
      d.style.top = (y - d.offsetHeight / 2) + 'px';
    });
  }

  function draw(c) {
    const { canvas, a, b } = rects(c.aId, c.bId);
    const aCx = a.x + a.w / 2, aCy = a.y + a.h / 2;
    const bCx = b.x + b.w / 2, bCy = b.y + b.h / 2;
    const via = c.via || (Math.abs(bCy - aCy) > Math.abs(bCx - aCx) ? 'v' : 'h');

    if (via === 'h') {
      const toRight = bCx >= aCx;
      const ax = toRight ? a.x + a.w : a.x;
      const bx = toRight ? b.x : b.x + b.w;
      const ay = a.y + a.h * (c.out ?? .5);
      const by = b.y + b.h * (c.in ?? .5);
      const midX = (ax + bx) / 2;
      seg(canvas, ax, ay, midX - ax, 0, c.primary);
      seg(canvas, midX, ay, 0, by - ay, c.primary);
      seg(canvas, midX, by, bx - midX, 0, c.primary);
      head(canvas, bx, by, toRight ? 'right' : 'left', c.primary);
      label(canvas, midX, (ay + by) / 2, c.text, c.primary);
    } else {
      const toDown = bCy >= aCy;
      const ay = toDown ? a.y + a.h : a.y;
      const by = toDown ? b.y : b.y + b.h;
      const ax = a.x + a.w * (c.out ?? .5);
      const bx = b.x + b.w * (c.in ?? .5);
      const midY = (ay + by) / 2;
      seg(canvas, ax, ay, 0, midY - ay, c.primary);
      seg(canvas, ax, midY, bx - ax, 0, c.primary);
      seg(canvas, bx, midY, 0, by - midY, c.primary);
      head(canvas, bx, by, toDown ? 'down' : 'up', c.primary);
      label(canvas, (ax + bx) / 2, midY, c.text, c.primary);
    }
  }

  function render() {
    document
      .querySelectorAll('.flow-canvas .connector-seg, .flow-canvas .connector-head, .flow-canvas .connector-label')
      .forEach(e => e.remove());
    for (const c of REG) {
      try { draw(c); } catch (e) { /* missing frame — skip this connector */ }
    }
  }

  function connect(aId, bId, text, opts) {
    REG.push(Object.assign({ aId, bId, text }, opts || {}));
  }

  window.addEventListener('resize', render);
  window.addEventListener('load', render);
  document.addEventListener('DOMContentLoaded', render);

  return { connect, render };
})();