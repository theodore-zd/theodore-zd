// flow.ts — navigation connectors between frames on a .flow-canvas.
// Usage: Flow.connect('from-id', 'to-id', 'Label', { via: 'h' | 'v', primary: true, out: .5, in: .5 });
//   via     — 'h' exits/enters left/right sides, 'v' top/bottom; default picks the
//             dominant delta.
//   primary — happy path: accent line + label.
//   out/in  — 0..1 position along the exit/entry edge (default .5).
// Connectors recompute on Flow.render(); it runs on load and resize automatically.

export type Via = 'h' | 'v';

export interface Edge {
  aId: string;
  bId: string;
  text: string;
  via?: Via;
  primary?: boolean;
  out?: number;
  in?: number;
}

const REG: Edge[] = [];
let listening = false;

interface Rect { x: number; y: number; w: number; h: number }

function rectOf(canvas: HTMLElement, el: Element): Rect {
  const cr = canvas.getBoundingClientRect();
  const r = el.getBoundingClientRect();
  return { x: r.left - cr.left, y: r.top - cr.top, w: r.width, h: r.height };
}

function ensureListeners() {
  if (listening) return;
  listening = true;
  window.addEventListener('resize', render);
  window.addEventListener('load', render);
}

function clear(canvas: HTMLElement) {
  for (const el of Array.from(canvas.querySelectorAll('.connector-seg, .connector-head, .connector-label'))) {
    el.remove();
  }
}

function seg(canvas: HTMLElement, x: number, y: number, w: number, h: number, primary?: boolean) {
  const d = document.createElement('div');
  d.className = 'connector-seg' + (primary ? ' primary' : '');
  d.style.left = (w < 0 ? x + w : x) + 'px';
  d.style.top = (h < 0 ? y + h : y) + 'px';
  d.style.width = Math.max(Math.abs(w), 1) + 'px';
  d.style.height = Math.max(Math.abs(h), 1) + 'px';
  canvas.appendChild(d);
}

function head(canvas: HTMLElement, x: number, y: number, dir: string, primary?: boolean) {
  const d = document.createElement('div');
  d.className = 'connector-head' + (primary ? ' primary' : '');
  d.style.left = (x - 5) + 'px';
  d.style.top = (y - 5) + 'px';
  d.style.transform = 'rotate(' + ({ right: 0, down: 90, left: 180, up: 270 } as const)[dir as 'right'] + 'deg)';
  canvas.appendChild(d);
}

function label(canvas: HTMLElement, x: number, y: number, text: string, primary?: boolean) {
  const d = document.createElement('div');
  d.className = 'connector-label' + (primary ? ' primary' : '');
  d.style.left = x + 'px';
  d.style.top = y + 'px';
  d.style.transform = 'translate(-50%, -50%)';
  d.textContent = text;
  canvas.appendChild(d);
}

function draw(e: Edge) {
  const a = document.getElementById(e.aId);
  const b = document.getElementById(e.bId);
  if (!a || !b) throw new Error('flow: missing frame ' + (!a ? e.aId : e.bId));
  const canvas = a.closest('.flow-canvas');
  if (!(canvas instanceof HTMLElement)) throw new Error('flow: frame not on a .flow-canvas');
  const ra = rectOf(canvas, a);
  const rb = rectOf(canvas, b);

  const via: Via = e.via ?? (Math.abs(rb.x + rb.w / 2 - (ra.x + ra.w / 2)) >= Math.abs(rb.y + rb.h / 2 - (ra.y + ra.h / 2)) ? 'h' : 'v');
  const out = e.out ?? 0.5;
  const inn = e.in ?? 0.5;

  // Exit point on frame a, entry point on frame b.
  let ex: number, ey: number, nx: number, ny: number;
  if (via === 'h') {
    const aRight = rb.x + rb.w / 2 > ra.x + ra.w / 2;
    ex = aRight ? ra.x + ra.w : ra.x;
    ey = ra.y + ra.h * out;
    nx = aRight ? rb.x : rb.x + rb.w;
    ny = rb.y + rb.h * inn;
  } else {
    const aBelow = rb.y + rb.h / 2 > ra.y + ra.h / 2;
    ex = ra.x + ra.w * out;
    ey = aBelow ? ra.y + ra.h : ra.y;
    nx = rb.x + rb.w * inn;
    ny = aBelow ? rb.y : rb.y + rb.h;
  }

  // Orthogonal elbow: exit run, one perpendicular turn, entry run.
  const mid = via === 'h' ? (ex + nx) / 2 : (ey + ny) / 2;
  let pts: Array<[number, number]>;
  if (via === 'h') {
    pts = [[ex, ey], [mid, ey], [mid, ny], [nx, ny]];
  } else {
    pts = [[ex, ey], [ex, mid], [nx, mid], [nx, ny]];
  }

  for (let i = 0; i < pts.length - 1; i++) {
    seg(canvas, pts[i][0], pts[i][1], pts[i + 1][0] - pts[i][0], pts[i + 1][1] - pts[i][1], e.primary);
  }

  // Arrowhead points along the final segment's direction.
  const [px, py] = pts[pts.length - 2];
  const dir = nx > px ? 'right' : nx < px ? 'left' : ny > py ? 'down' : 'up';
  head(canvas, nx, ny, dir, e.primary);

  // Label chip sits at the elbow corner.
  label(canvas, mid, via === 'h' ? ey : mid, e.text, e.primary);
}

export function connect(aId: string, bId: string, text: string, opts: Omit<Edge, 'aId' | 'bId' | 'text'> = {}) {
  REG.push({ aId, bId, text, ...opts });
  ensureListeners();
  if (document.readyState !== 'loading') render();
}

export function render() {
  const canvases: HTMLElement[] = [];
  for (const e of REG) {
    const a = document.getElementById(e.aId);
    const canvas = a?.closest('.flow-canvas');
    if (canvas instanceof HTMLElement) canvases.push(canvas);
  }
  for (const c of canvases) clear(c); // clear is idempotent; duplicate canvases just clear twice
  for (const e of REG) draw(e);
}

export const Flow = { connect, render };
