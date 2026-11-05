# Inset Canvas QA checklist

Work through every item. Report each failure along with a screenshot.

## Build and console
- [ ] The production build passes with no new warnings.
- [ ] The browser console shows no new errors or warnings compared with the baseline taken before the redesign.

## Shell
- [ ] The old top nav and its CSS are completely gone. Searching for the old class names finds nothing.
- [ ] The rail shows the brand, every route in its original order with an icon, and the footer utilities.
- [ ] The active route shows an indigo pill and a left indicator bar, and both follow navigation, including deep links and reloads.
- [ ] Collapsing hides the labels and brand text, shows `title` tooltips, and persists across reloads.
- [ ] The canvas is inset with rounded corners on desktop and goes full-bleed on mobile.
- [ ] Global bars (filters, breadcrumbs) sit in the canvas top bar and stay sticky inside the canvas.

## Footer utilities
- [ ] Every dropdown opens upward, isn't clipped by the rail, and is readable.
- [ ] The compact triggers work when the rail is collapsed.
- [ ] Every modal launched from these menus still opens and closes.

## Responsive (check at 1440, 1024, 768 and 375px)
- [ ] From 768 to 1023px the rail defaults to collapsed.
- [ ] Below 768px the drawer opens from the menu button, and closes via the scrim, `Esc` and route change.
- [ ] No page scrolls horizontally, apart from tables inside their own scroll container.

## Polish
- [ ] Spacing uses the `--space-*` tokens. There are no stray 1.125rem, 0.938rem or 13px-style values left in the touched styles.
- [ ] Card, table, badge, page-header and form-control styles are consistent on every page.
- [ ] Numbers in tables and KPIs use tabular figures.
- [ ] Status colours are unchanged in meaning.
- [ ] The UI contains no emojis.

## Accessibility
- [ ] The nav has `aria-label`, active links set `aria-current="page"`, and the toggle has `aria-expanded`.
- [ ] Focus rings are visible on links, buttons and selects.
- [ ] Text contrast is at least 4.5:1 in the rail, both normal and active.
- [ ] Transitions are disabled under `prefers-reduced-motion`.

## Behaviour parity
- [ ] Every route renders the same data as before.
- [ ] Filters, sorting, modals, locale and currency switching all work as before.
- [ ] No script logic was changed beyond the layout and sidebar state.
