You are building a single-file static website for a small local business based
on the brief above. Follow these rules exactly.

## Output

A single self-contained `index.html` at the project root. No external CSS or JS
files. No build step. No `package.json`.

## Tech

- `<!DOCTYPE html>` + `<html lang="th">` (default — English handled via toggle below)
- `<meta charset="utf-8">` and `<meta name="viewport" content="width=device-width, initial-scale=1">`
- Tailwind CDN in `<head>`: `<script src="https://cdn.tailwindcss.com"></script>`
- Load every Google Font you need across the 5 variants in a **single** `<link>` request at the top of `<head>` (combine all families into one URL)
- Mobile-first responsive

## Five design variants

The file must contain **5 distinct design variants** of the site. Only ONE is
visible at a time; the user clicks `1 2 3 4 5` in a floating switcher to swap.

Each variant must:
- Include all required sections (below) with the same business data
- Differ from the others in palette, typography, layout structure, AND overall mood. Color swaps alone are **not** enough.

### Suggested directions (pick or adapt 5 distinct flavors)

1. **Editorial** — serif-driven, minimalist cream + ink, generous whitespace, centered hero
2. **Bold Modern** — large sans-serif, asymmetric grid, one vibrant accent color, magazine-style menu layout
3. **Warm Boutique** — earthy palette, handcrafted feel, soft textures, two-column blocks
4. **Dark Cinematic** — dark background with gold/copper accents, oversized display type, full-bleed hero
5. **Playful** — rounded shapes, pastel or duotone palette, soft shadows, illustrative touches

Interpret each direction through the business type. A restaurant gets warmer
palettes; a tech service gets cooler/cleaner. Don't copy verbatim — and don't
reach for the same hero pattern in every variant.

## Required sections (per variant)

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

### Variant switcher

- Fixed floating button bar with 5 numbered buttons (`1 2 3 4 5`)
- Position: bottom-right (so it doesn't conflict with the TH/EN toggle at top-right when present)
- Active variant button visually highlighted (filled background)
- Persist selection in `localStorage` under key `siteVariant` (default `'1'`)
- On click: hide all other variants, show the chosen one, store the choice, scroll to top

### Implementation pattern

```html
<div id="variants">
  <div class="variant" data-variant="1"><!-- variant 1 content --></div>
  <div class="variant" data-variant="2"><!-- variant 2 content --></div>
  <div class="variant" data-variant="3"><!-- variant 3 content --></div>
  <div class="variant" data-variant="4"><!-- variant 4 content --></div>
  <div class="variant" data-variant="5"><!-- variant 5 content --></div>
</div>

<div id="variant-switcher" class="fixed bottom-5 right-5 z-50 ...">
  <button data-variant="1">1</button>
  <button data-variant="2">2</button>
  <button data-variant="3">3</button>
  <button data-variant="4">4</button>
  <button data-variant="5">5</button>
</div>

<script>
  // 1. Read localStorage 'siteVariant' (default '1')
  // 2. Show that .variant[data-variant=N], hide the rest
  // 3. Mark matching switcher button as .active
  // 4. On button click: persist + apply
</script>
```

## Bilingual handling

If the brief says `Bilingual (TH/EN toggle): yes`:

- Set `<html lang="th">` initially
- Add a fixed **top-right** toggle button: `TH | EN` (separate from the variant switcher at bottom-right)
- Inside **every** variant, mark translatable text nodes with `data-th="..."` and `data-en="..."` on the leaf element (no inner content — JS fills it)
- A single inline `<script>` swaps all `[data-th]` elements across the whole document, so when the language toggles, every variant updates in one pass — visible or hidden
- Persist language in `localStorage` under key `lang` (default `'th'`)
- **Preserve proper nouns** — business name, Thai menu items, address — don't translate them. Only translate UI labels and the About paragraph.

If `Bilingual (TH/EN toggle): no`, omit the toggle and the `data-en` attributes entirely.

## Polish guardrails

- Design must feel polished — not generic Bootstrap-ish
- Clear hierarchy, generous whitespace, restrained shadow use
- **Do not use emoji** unless the brief explicitly asks for them
- Don't repeat the same hero pattern across all 5 variants
- Prices: render with currency unit (e.g. `80 บาท` or `฿80`) even if the brief shows raw numbers
- Hours: format clearly — single line for simple, small grid for per-weekday

## Edge cases

- If the brief is missing required info (no business name, no contact), do your best with what's there but leave a clear placeholder rather than fabricating
- If the brief is in pure English, set `<html lang="en">` and skip the TH/EN toggle even if `Bilingual: yes` — there's nothing to translate
