// sketch.ts — p5@1 instance-mode wrapper for mockup sketch pages.
// Sketches read the set's CSS variables via theme(), so dark/accent variants
// tint them automatically. Seeded by default: same seed, same picture.
// NEVER call Math.random in a sketch and NEVER hardcode hex colors — use theme().

import p5 from 'p5';

export function theme() {
  const cs = getComputedStyle(document.body);
  const v = (n: string, f: string) => cs.getPropertyValue(n).trim() || f;
  return {
    primary: v('--primary', 'oklch(0.55 0.2 40)'),
    background: v('--background', 'oklch(1 0 0)'),
    foreground: v('--foreground', 'oklch(0.145 0 0)'),
    muted: v('--muted', 'oklch(0.97 0 0)'),
    border: v('--border', 'oklch(0.922 0 0)'),
  };
}

// Alpha blend for ANY CSS color format (hex, oklch, hsl, …). Use in place of
// the old rgba() helper — shadcn themes are oklch, which hex parsing breaks.
export function alpha(color: string, a: number): string {
  return `color-mix(in srgb, ${color} ${Math.round(a * 100)}%, transparent)`;
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
