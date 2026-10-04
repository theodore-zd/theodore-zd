// sketch.ts — p5@1 instance-mode wrapper for mockup sketch pages.
// Sketches read the set's CSS variables via theme(), so dark/accent variants
// tint them automatically. Seeded by default: same seed, same picture.
// NEVER call Math.random in a sketch and NEVER hardcode hex colors — use theme().

import p5 from 'p5';

export function theme() {
  const cs = getComputedStyle(document.body);
  const v = (n: string, f: string) => cs.getPropertyValue(n).trim() || f;
  return {
    primary: v('--primary', '#e8710a'),
    background: v('--background', '#ffffff'),
    foreground: v('--foreground', '#1f1f1c'),
    muted: v('--muted', '#e6e6e1'),
    border: v('--border', '#8d8d87'),
  };
}

export function rgba(hex: string, a: number): string {
  const s = hex.replace('#', '');
  const n = parseInt(s.length === 3 ? s.split('').map((c) => c + c).join('') : s, 16);
  return `rgba(${(n >> 16) & 255},${(n >> 8) & 255},${n & 255},${a})`;
}

// sketch(host, height, draw, seed) — creates one p5 instance in the host
// element, seeds it, draws once, and redraws on resize. Returns a cleanup
// function (handy as an onMount/$effect return value).
export function sketch(
  host: HTMLElement,
  height: number,
  draw: (p: p5, w: number, h: number) => void,
  seed = 42,
): () => void {
  let inst: p5 | undefined;
  inst = new p5((p) => {
    p.setup = () => {
      p.randomSeed(seed);
      p.noiseSeed(seed);
      p.createCanvas(Math.max(host.clientWidth || 800, 280), height).parent(host);
      p.pixelDensity(2);
      p.draw = () => draw(p, p.width, p.height);
      p.draw();
      p.noLoop();
    };
  });
  const ro = new ResizeObserver(() => {
    inst?.resizeCanvas(Math.max(host.clientWidth || 800, 280), height);
    inst?.redraw();
  });
  ro.observe(host);
  return () => {
    ro.disconnect();
    inst?.remove();
    inst = undefined;
  };
}
