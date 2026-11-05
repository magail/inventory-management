---
name: saas-redesign
description: Redesign a Vue 3 application's UI into a modern SaaS-style interface with a collapsible vertical sidebar on the left (replacing a top nav bar), a token-based spacing system and a polished, professional look. Use this skill when asked to modernize, restyle or "SaaS-ify" a Vue 3 app, move navigation into a sidebar, or make spacing and styling consistent.
---

# SaaS Redesign for Vue 3

This skill turns a Vue 3 app with a top navigation bar into a modern SaaS layout called **Inset Canvas**:

- A dark slate **rail** on the left. It is 248px wide when expanded and 72px when collapsed, with icons and labels, and remembers its collapse state.
- The page content sits in a rounded light **canvas** that floats on the slate background, giving the "app window" look used by Linear, Arc and Vercel.
- One **design-token** system (spacing, radius, shadow, type, colour) that every surface uses.
- Full behaviour parity. Routes, data flow, props, events and business logic stay exactly as they were.

The redesign is **style and layout only**. If a change would alter what the app *does*, stop and ask.

## Reference files

| File | Purpose |
|---|---|
| [references/tokens.css](references/tokens.css) | Design tokens and base resets. Copy them into the global stylesheet. |
| [references/sidebar-template.md](references/sidebar-template.md) | Generic `AppSidebar.vue` source, plus the layout shell for the root component |
| [references/checklist.md](references/checklist.md) | Visual and functional QA checklist for the final step |

## Workflow

Do the steps in order. Do not skip Step 1 and Step 2. They are what make this skill work on *any* Vue 3 app.

### Step 1 - Discover (read-only)

Find and read these before editing anything:

1. **Project rules.** Read every `CLAUDE.md` (root, client and nested). Obey them. If they require `.vue` edits to go to a specific subagent (for example `vue-expert`), delegate every `.vue` change to it, and pass along this skill and the reference files as its brief.
2. **Router.** Look in `main.js` / `main.ts`, `router/index.*` or `src/router.*`. List every route, its path, its component and any `meta`.
3. **Root layout.** Look in `App.vue`, `layouts/*.vue` or `src/components/Layout*.vue`. Find the current nav markup, the header utilities (profile menu, language switcher, notifications, search) and anything rendered around `<router-view>`.
4. **Global styles.** Find where they live: the unscoped `<style>` in `App.vue`, `src/assets/*.css`, `src/styles/*` or `main.css`. Note any existing CSS variables.
5. **Component style.** Check whether the code uses `<script setup>` or `export default { setup() }`, JS or TS, and Options API or Composition API. **Match it exactly.**
6. **i18n.** Look for `vue-i18n`, a custom `useI18n`/`t()` helper or hard-coded strings. Nav labels must go through the same mechanism the old nav used.
7. **UI framework.** Check `package.json` for Tailwind, Vuetify, PrimeVue, Element Plus, Naive UI or Quasar. If one is present, build the sidebar with that framework's primitives and theme tokens instead of raw CSS, but keep the same visual direction.
8. **Icons.** Check whether an icon library is already installed. If none is, use inline SVG (Lucide-style 24x24 strokes, `stroke-width="1.75"`). **Never add a runtime dependency only for icons.**

### Step 2 - Confirm the inventory

Write a short summary for the user before you edit anything:

- Nav items, in order: label, route and the icon you chose.
- Header utilities that will move into the sidebar footer.
- Files you will create or modify.
- Any constraint you found, for example "must delegate `.vue` edits", "Tailwind present" or "labels come from `t('nav.*')`".

If the app has more than about 8 top-level routes, propose grouping them under section headings (for example "Operations" and "Finance") and confirm with the user.

### Step 3 - Install the tokens

Copy the `:root` block and the base rules from `references/tokens.css` into the global stylesheet. Do it once, at the top.

- If the project already has brand colours, map them onto `--accent-*` rather than introducing a new hue.
- Keep the existing semantic status colours (success, warning, danger, info) if the project defines them. Only fill in the missing ones.

### Step 4 - Build the shell

1. Create `AppSidebar.vue` in the components folder from `references/sidebar-template.md`, adapted to:
   - the project's component style (`<script setup>` or `setup()`),
   - its i18n helper (labels passed in already translated, or translated inside),
   - its routes. Active state comes from `router-link`'s `active-class` / `exact-active-class`, so you don't need to compare `$route.path` by hand.
2. Restructure the root layout into the shell shown in the template file:
   `div.app-shell > AppSidebar + div.app-canvas > (header.canvas-topbar + main.canvas-content > router-view)`.
3. Move header utilities (profile menu, language switcher and so on) into the sidebar's `footer` slot. Restyle their dropdowns so they:
   - open **upward** (`bottom: calc(100% + var(--space-2)); top: auto`),
   - stay readable on the dark rail. The trigger uses rail colours, and the popover itself stays a light surface.
   - show a compact, icon-only trigger when the rail is collapsed.
4. Keep global bars such as filter bars or breadcrumbs, but place them inside `canvas-topbar`, sticky within the canvas.
5. Delete the old top-nav markup **and** its CSS. No dead selectors should be left behind.
6. Keep every modal, toast and teleport target mounted exactly where it was.

### Step 5 - Spacing and polish pass

Go through the global styles first, then each view and component's `<style>`:

- Replace hard-coded `padding`, `margin`, `gap`, `border-radius`, `box-shadow` and `font-size` values with tokens. Round to the nearest step on the 4px scale (`--space-*`).
- Unify the recurring surfaces:
  - **Page header:** title `--text-2xl`/600 with `--space-1` gap to the subtitle, `--space-6` below.
  - **Card:** `--surface`, `1px solid var(--border)`, `--radius-lg`, `--space-5` padding, `--shadow-xs`; on hover `--shadow-sm` only where the card is clickable.
  - **Stat/KPI card:** label `--text-xs` uppercase `--text-muted`, value `--text-3xl` tabular-nums.
  - **Table:** sticky light header, `--space-3` cell padding, row hover `--surface-subtle`, numeric columns right-aligned with `font-variant-numeric: tabular-nums`.
  - **Badge:** pill (`--radius-full`), `--text-xs`, 500 weight, sentence case (drop shouty `uppercase` unless it's a status code).
  - **Form controls:** 36px height, `--radius-md`, `--border` with `--accent-500` focus ring.
  - **Grids:** `gap: var(--space-5)` everywhere. No mixed 1rem/1.25rem/1.5rem gaps.
- **Do not touch** template logic, `v-if`/`v-for` conditions, bindings, script code, chart maths or data formatting. Class names may be *added* for styling. Don't rename existing ones that scripts or tests might reference.
- Keep chart colours. Only adjust axes, gridlines and labels to `--border` / `--text-muted`.

### Step 6 - Responsive and accessible

- At `>= 1024px` the rail is expanded by default. Users can collapse it, and the choice persists in `localStorage`.
- From `768px` to `1023px` the rail defaults to collapsed.
- Below `768px` the rail becomes an off-canvas drawer opened by a menu button in `canvas-topbar`. It has a scrim, closes on route change and on `Esc`, and the canvas goes full-bleed with no inset.
- Use `<nav aria-label="Main">`, and make sure `router-link` sets `aria-current="page"`. The toggle button needs `aria-expanded` and an `aria-label`.
- In collapsed mode, give each nav link a `title` equal to its label (a native tooltip).
- Add visible `:focus-visible` rings on every interactive element, and `@media (prefers-reduced-motion: reduce)` to disable transitions.
- Use no emojis anywhere in the UI.

### Step 7 - Verify

Work through `references/checklist.md`. At minimum:

1. The production build passes (`npm run build` or the project's equivalent).
2. Take browser screenshots (Playwright if available) of **every route** in three states: expanded, collapsed, and at 375px mobile width with the drawer open.
3. Exercise the existing features: filters, modals, menus and locale switching. They must behave as before.
4. Compare the console before and after. There should be **no new** warnings or errors. Report any that existed before, but don't fix them as part of this skill.
5. Run a code-review agent on the diff if the project provides one.
6. Do **not** commit. Give the user a summary and screenshots to review.

## Guardrails

- Behaviour parity is mandatory. If a style change forces a logic change, explain why and ask first.
- Add no new runtime dependencies.
- Follow the project's comment rules, and add a short comment on any non-obvious logic (for example collapse persistence or the breakpoint handling).
- Match the existing naming, file layout and formatting.
- Keep diffs reviewable. Do the shell (Steps 3, 4 and 6) first, then the polish pass (Step 5) file by file.
