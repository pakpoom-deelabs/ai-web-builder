You are building a single-file static website for a small local business based
on the brief above. Follow these rules exactly.

## Output

A single self-contained `index.html` at the project root. No external CSS or JS
files. No build step. No `package.json`.

## Tech

- `<!DOCTYPE html>` + `<html lang="th" data-palette="warm">` (or appropriate default palette — see below)
- `<meta charset="utf-8">` and `<meta name="viewport" content="width=device-width, initial-scale=1">`
- Tailwind CDN in `<head>`: `<script src="https://cdn.tailwindcss.com"></script>`
- Load every Google Font you need across the 3 layouts in a **single** `<link>` request at the top of `<head>` (combine all families into one URL)
- Mobile-first responsive

## Three layout variants

The file must contain **3 distinct layout variants** of the site. Only ONE is
visible at a time; the user clicks `1 2 3` in a floating switcher to swap.

Each layout differs in **typography, structure, spacing, and mood** — NOT in
color. Color comes from a separate palette switcher (see below) and is applied
via CSS custom properties so palette changes repaint all 3 layouts at once.

### Suggested layout directions

1. **Editorial** — serif-driven (Playfair Display / Cormorant), minimalist, generous whitespace, centered hero, elegant pacing
2. **Bold Modern** — large geometric sans (Inter / Space Grotesk), asymmetric grid, magazine-style menu cards, confident hierarchy
3. **Warm Boutique** — softer humanist sans with optional script accent (DM Sans / Caveat), two-column blocks, handcrafted feel

Each layout must include all required sections (below) with the same business data.

## Color palettes

Define **5 palettes** as CSS custom properties at the top of `<style>`. The
active palette is set on `<html data-palette="...">` and persisted in
`localStorage.palette`.

```css
[data-palette="warm"]     { --bg:#fef9e7; --surface:#fff7e0; --text:#3d2914; --muted:#78716c; --primary:#c2410c; --accent:#f59e0b; --border:#e7d8b0; }
[data-palette="forest"]   { --bg:#f5f5f0; --surface:#ffffff; --text:#1f2d24; --muted:#5b6b62; --primary:#2f5d3b; --accent:#a8c686; --border:#dde3d8; }
[data-palette="midnight"] { --bg:#0f1419; --surface:#1a2028; --text:#f5ead8; --muted:#a89580; --primary:#d4a857; --accent:#e8c87a; --border:#2a3340; }
[data-palette="rose"]     { --bg:#fdf2f4; --surface:#ffffff; --text:#3d1f2e; --muted:#8b6679; --primary:#b8456c; --accent:#e89cb3; --border:#f0d4dc; }
[data-palette="mono"]     { --bg:#fafaf9; --surface:#ffffff; --text:#18181b; --muted:#71717a; --primary:#27272a; --accent:#52525b; --border:#e4e4e7; }
```

Reference variables in HTML via Tailwind arbitrary values:
- `class="bg-[color:var(--bg)] text-[color:var(--text)]"`
- `class="bg-[color:var(--primary)] hover:bg-[color:var(--accent)]"`
- `class="border-[color:var(--border)]"`

Use these tokens consistently across all 3 layouts so palette swaps work.

### Palette defaults by business type

Set the initial `data-palette` based on the brief's `Business type`:
- `restaurant` / `cafe` → `warm`
- `retail` (boutique/fashion) → `rose`
- `service` / `professional` → `mono`
- `wellness` / `outdoor` → `forest`
- Premium/upscale of any type → `midnight`

User can always override via the color switcher.

## Required sections (per layout)

1. **Hero** — business name, one-line tagline, primary CTA (call or LINE)
2. **About** — short paragraph derived from the brief
3. **Menu / Services** — list of items with prices, nicely formatted
4. **Hours** — opening hours, clearly readable (single line if simple; small grid if per-weekday)
5. **Contact** — clickable `tel:` link, LINE link, address with Google Maps search link
6. **Footer** — © year + business name

### Contact link formats

- Phone: `<a href="tel:+66XXXXXXXXX">...</a>` (strip spaces/dashes for the href; keep human-readable text)
- LINE personal id: `https://line.me/ti/p/~<LINE_ID>`
- LINE official `@`-prefixed id: `https://line.me/R/ti/p/@<id>`
- Address: `https://www.google.com/maps/search/?api=1&query=<urlencoded address>`

## Switchers — positioning and behavior

Three floating UI controls, each in its own corner so they don't collide:

| Control | Position | Function | localStorage key | Default |
|---|---|---|---|---|
| Layout switcher | bottom-right | Buttons `1 2 3` | `siteVariant` | `'1'` |
| Color switcher | bottom-left | 5 colored swatches | `palette` | per business type |
| Language toggle | top-right | `TH \| EN` (only if bilingual=yes) | `lang` | `'th'` |

### Layout switcher

- Fixed bar with 3 numbered buttons (`1 2 3`), bottom-right
- Active button visually highlighted (filled background)
- On click: hide all other `.variant`, show the chosen one, persist, scroll to top

### Color switcher

- Fixed bar with 5 round swatches, bottom-left
- Each swatch shows a preview of that palette's `--primary` (or `--accent`) on its `--bg`
- Active swatch has a subtle ring (`ring-2 ring-[color:var(--text)]` or similar)
- On click: set `<html data-palette="...">`, persist in `localStorage.palette`

### Implementation pattern

```html
<div id="variants">
  <div class="variant" data-variant="1"><!-- layout 1 content --></div>
  <div class="variant" data-variant="2"><!-- layout 2 content --></div>
  <div class="variant" data-variant="3"><!-- layout 3 content --></div>
</div>

<div id="variant-switcher" class="fixed bottom-5 right-5 z-50 flex gap-2 ...">
  <button data-variant="1">1</button>
  <button data-variant="2">2</button>
  <button data-variant="3">3</button>
</div>

<div id="palette-switcher" class="fixed bottom-5 left-5 z-50 flex gap-2 ...">
  <button data-palette="warm"     aria-label="Warm"     class="w-8 h-8 rounded-full" style="background:#c2410c"></button>
  <button data-palette="forest"   aria-label="Forest"   class="w-8 h-8 rounded-full" style="background:#2f5d3b"></button>
  <button data-palette="midnight" aria-label="Midnight" class="w-8 h-8 rounded-full" style="background:#0f1419"></button>
  <button data-palette="rose"     aria-label="Rose"     class="w-8 h-8 rounded-full" style="background:#b8456c"></button>
  <button data-palette="mono"     aria-label="Mono"     class="w-8 h-8 rounded-full" style="background:#27272a"></button>
</div>

<script>
  // Layout: read localStorage 'siteVariant' (default '1'), show that .variant, mark active button
  // Palette: read localStorage 'palette' (default per business type), set on <html>, mark active swatch
  // Both: click handlers persist + apply
</script>
```

## Bilingual handling

If the brief says `Bilingual (TH/EN toggle): yes`:

- Set `<html lang="th">` initially
- Add a fixed **top-right** toggle button: `TH | EN`
- Inside **every** layout, mark translatable text nodes with `data-th="..."` and `data-en="..."` on the leaf element (no inner content — JS fills it)
- A single inline `<script>` swaps all `[data-th]` elements across the whole document — visible or hidden layouts both update
- Persist language in `localStorage` under key `lang` (default `'th'`)
- **Preserve proper nouns** — business name, Thai menu items, address — don't translate them. Only translate UI labels and the About paragraph.

If `Bilingual (TH/EN toggle): no`, omit the toggle and the `data-en` attributes entirely.

## Polish guardrails

- Design must feel polished — not generic Bootstrap-ish
- Clear hierarchy, generous whitespace, restrained shadow use
- **Do not use emoji** unless the brief explicitly asks for them
- Don't repeat the same hero pattern across all 3 layouts
- Prices: render with currency unit (e.g. `80 บาท` or `฿80`) even if the brief shows raw numbers
- Hours: format clearly — single line for simple, small grid for per-weekday
- Color must come from CSS variables — do NOT hardcode hex values in the layout markup (palette swatches in the switcher itself are the only exception)

## Edge cases

- If the brief is missing required info (no business name, no contact), do your best with what's there but leave a clear placeholder rather than fabricating
- If the brief is in pure English, set `<html lang="en">` and skip the TH/EN toggle even if `Bilingual: yes` — there's nothing to translate
