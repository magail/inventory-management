# Sidebar template and layout shell

Adapt this to the target project's conventions before you use it:

- **Component style.** The template is written as `export default { setup() }`. If the project uses `<script setup>`, convert it.
- **i18n.** Pass `items[].label` already translated, or call the project's `t()` inside.
- **Icons.** `items[].icon` is a key into the `icons` map of inline SVG paths. Add icons that fit the project's routes. If the project already ships an icon library, use that instead.

## `AppSidebar.vue`

```vue
<template>
  <aside
    :class="['app-rail', { collapsed: isCollapsed, 'mobile-open': mobileOpen }]"
    :style="{ '--rail-current': isCollapsed ? 'var(--rail-width-collapsed)' : 'var(--rail-width)' }"
  >
    <div class="rail-brand">
      <slot name="brand" :collapsed="slotCollapsed" />
    </div>

    <nav class="rail-nav" aria-label="Main">
      <router-link
        v-for="item in items"
        :key="item.to"
        :to="item.to"
        class="rail-link"
        exact-active-class="active"
        :title="slotCollapsed ? item.label : undefined"
      >
        <svg class="rail-icon" viewBox="0 0 24 24" aria-hidden="true">
          <path v-for="d in icons[item.icon] || icons.dot" :key="d" :d="d" />
        </svg>
        <span class="rail-label">{{ item.label }}</span>
      </router-link>
    </nav>

    <div class="rail-footer">
      <slot name="footer" :collapsed="slotCollapsed" />
      <button
        type="button"
        class="rail-toggle"
        :aria-expanded="!isCollapsed"
        :aria-label="isCollapsed ? 'Expand sidebar' : 'Collapse sidebar'"
        @click="toggleCollapsed"
      >
        <svg class="rail-icon" viewBox="0 0 24 24" aria-hidden="true">
          <path :d="isCollapsed ? 'M9 6l6 6-6 6' : 'M15 6l-6 6 6 6'" />
        </svg>
        <span class="rail-label">Collapse</span>
      </button>
    </div>
  </aside>
  <div v-if="mobileOpen" class="rail-scrim" @click="$emit('close-mobile')" />
</template>

<script>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'

const STORAGE_KEY = 'app-sidebar-collapsed'

// Lucide-style 24x24 stroke paths. Keep the set small and add icons only when needed.
const icons = {
  dot: ['M12 12h.01'],
  home: ['M3 10.5 12 3l9 7.5', 'M5 9.5V21h14V9.5'],
  box: ['M21 8 12 3 3 8v8l9 5 9-5V8z', 'M3 8l9 5 9-5', 'M12 13v8'],
  cart: ['M3 4h2l2.4 11.2a2 2 0 0 0 2 1.6h7.7a2 2 0 0 0 2-1.5L21 8H6', 'M9 21h.01', 'M18 21h.01'],
  wallet: ['M3 7a2 2 0 0 1 2-2h13v4', 'M3 7v11a2 2 0 0 0 2 2h15V9H5a2 2 0 0 1-2-2z', 'M16 14h.01'],
  trend: ['M3 17l6-6 4 4 8-8', 'M14 7h7v7'],
  chart: ['M4 20V10', 'M10 20V4', 'M16 20v-7', 'M22 20H2'],
  users: ['M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2', 'M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z', 'M22 21v-2a4 4 0 0 0-3-3.9', 'M16 3.1a4 4 0 0 1 0 7.8'],
  settings: ['M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z', 'M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z']
}

export default {
  name: 'AppSidebar',
  props: {
    // [{ to: '/path', label: 'Translated label', icon: 'home' }]
    items: { type: Array, required: true },
    mobileOpen: { type: Boolean, default: false }
  },
  emits: ['close-mobile'],
  setup(props, { emit }) {
    // A stored preference wins. Otherwise collapse by default on tablet widths (768-1023px).
    const stored = localStorage.getItem(STORAGE_KEY)
    const isCollapsed = ref(
      stored !== null ? stored === 'true' : window.matchMedia('(max-width: 1023px)').matches
    )

    const toggleCollapsed = () => {
      isCollapsed.value = !isCollapsed.value
      localStorage.setItem(STORAGE_KEY, String(isCollapsed.value))
    }

    // The mobile drawer is always full width, so slot content (brand, footer menus) must render
    // expanded there even when the desktop "collapsed" preference is persisted.
    const mobileQuery = window.matchMedia('(max-width: 767px)')
    const isMobile = ref(mobileQuery.matches)
    const onMobileChange = (e) => { isMobile.value = e.matches }
    const slotCollapsed = computed(() => isCollapsed.value && !isMobile.value)

    // Esc closes the mobile drawer (no-op on desktop where the drawer is never open)
    const onKeydown = (e) => {
      if (e.key === 'Escape' && props.mobileOpen) emit('close-mobile')
    }
    onMounted(() => {
      window.addEventListener('keydown', onKeydown)
      mobileQuery.addEventListener('change', onMobileChange)
    })
    onBeforeUnmount(() => {
      window.removeEventListener('keydown', onKeydown)
      mobileQuery.removeEventListener('change', onMobileChange)
    })

    return { icons, isCollapsed, slotCollapsed, toggleCollapsed }
  }
}
</script>

<style scoped>
.app-rail {
  position: sticky;
  top: 0;
  height: 100vh;
  width: var(--rail-current);
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  padding: var(--space-4) var(--space-3);
  background: linear-gradient(180deg, var(--rail-bg), var(--rail-bg-end));
  color: var(--rail-text);
  transition: width var(--duration) var(--ease);
  /* Must stay visible: footer dropdowns pop out beyond the rail's width */
  overflow: visible;
  z-index: 100;
}

.rail-brand { min-height: 40px; display: flex; align-items: center; padding: 0 var(--space-1); overflow: hidden; }

/* Only the nav list clips/scrolls, so labels never spill out while the width animates.
   Negative margin + matching padding extends the clip box to the rail edge so the
   active indicator (drawn in the rail padding) is not cut off. */
.rail-nav {
  display: flex; flex-direction: column; gap: var(--space-1); flex: 1;
  overflow-x: hidden; overflow-y: auto;
  margin: 0 calc(-1 * var(--space-3));
  padding: 0 var(--space-3);
}

.rail-link,
.rail-toggle {
  position: relative;
  display: flex;
  align-items: center;
  gap: var(--space-3);
  height: 40px;
  padding: 0 var(--space-3);
  border-radius: var(--radius-md);
  color: var(--rail-text);
  font-size: var(--text-base);
  font-weight: 500;
  text-decoration: none;
  white-space: nowrap;
  background: none;
  border: 0;
  cursor: pointer;
  transition: background var(--duration) var(--ease), color var(--duration) var(--ease);
}

.rail-link:hover,
.rail-toggle:hover { background: var(--rail-hover); color: var(--rail-text-strong); }

.rail-link.active { background: var(--rail-active); color: var(--rail-text-strong); }

/* The indicator bar sits in the rail's left padding so it never shifts the label. */
.rail-link.active::before {
  content: '';
  position: absolute;
  left: calc(-1 * var(--space-3));
  top: 8px;
  bottom: 8px;
  width: 3px;
  border-radius: 0 3px 3px 0;
  background: var(--rail-indicator);
}

.rail-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
  fill: none;
  stroke: currentColor;
  stroke-width: 1.75;
  stroke-linecap: round;
  stroke-linejoin: round;
}

/* Collapsed labels must leave the layout (not just fade): an invisible label still takes up
   width, and centring icon + label then pushes the icon off the rail's left edge. */
.collapsed .rail-label { display: none; }
.collapsed .rail-brand { justify-content: center; }
.collapsed .rail-link,
.collapsed .rail-toggle { justify-content: center; padding: 0; }

.rail-footer {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding-top: var(--space-3);
  border-top: 1px solid var(--rail-border);
}

.rail-scrim { display: none; }

/* Mobile: the rail becomes an off-canvas drawer */
@media (max-width: 767px) {
  .app-rail {
    position: fixed;
    inset: 0 auto 0 0;
    z-index: 200;
    width: var(--rail-width);
    transform: translateX(-100%);
    transition: transform var(--duration) var(--ease);
  }
  .app-rail.mobile-open { transform: translateX(0); }
  /* The drawer is always full width, so ignore a persisted desktop "collapsed" state */
  .collapsed .rail-label { display: inline; }
  .collapsed .rail-brand { justify-content: flex-start; }
  .collapsed .rail-link { justify-content: flex-start; padding: 0 var(--space-3); }
  .rail-toggle { display: none; }
  .rail-scrim {
    display: block;
    position: fixed;
    inset: 0;
    z-index: 199;
    background: rgba(2, 6, 23, 0.5);
  }
}
</style>
```

## Root layout shell

```vue
<template>
  <div class="app-shell">
    <AppSidebar :items="navItems" :mobile-open="mobileNavOpen" @close-mobile="mobileNavOpen = false">
      <template #brand="{ collapsed }">
        <!-- Brand mark always visible; wordmark hidden when collapsed -->
      </template>
      <template #footer="{ collapsed }">
        <!-- Profile menu, language switcher, etc. Pass `collapsed` for compact triggers -->
      </template>
    </AppSidebar>

    <div class="app-canvas">
      <header class="canvas-topbar">
        <button class="mobile-menu-btn" aria-label="Open navigation" @click="mobileNavOpen = true">
          <!-- hamburger svg -->
        </button>
        <!-- existing global bars (filters, breadcrumbs) -->
      </header>
      <main class="canvas-content">
        <router-view />
      </main>
    </div>

    <!-- existing modals stay here, unchanged -->
  </div>
</template>
```

In `setup()`, build `navItems` from the router or the old nav markup. Close the drawer on navigation:

```js
const route = useRoute()
const mobileNavOpen = ref(false)
watch(() => route.fullPath, () => { mobileNavOpen.value = false })
```

Global layout CSS:

```css
.app-shell { display: flex; min-height: 100vh; background: var(--rail-bg); }

/* The inset canvas: a rounded light panel floating on the rail colour */
.app-canvas {
  flex: 1;
  min-width: 0;
  margin: var(--canvas-inset) var(--canvas-inset) var(--canvas-inset) 0;
  background: var(--canvas);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-canvas);
  display: flex;
  flex-direction: column;
  /* clip so sticky topbar keeps rounded corners */
  overflow: clip;
}

.canvas-topbar {
  position: sticky;
  top: 0;
  z-index: 50;
  display: flex;
  align-items: center;
  gap: var(--space-4);
  padding: var(--space-4) var(--space-8);
  background: color-mix(in srgb, var(--canvas) 85%, transparent);
  backdrop-filter: blur(8px);
  border-bottom: 1px solid var(--border);
}

.canvas-content {
  flex: 1;
  width: 100%;
  max-width: var(--content-max);
  margin: 0 auto;
  padding: var(--space-6) var(--space-8) var(--space-10);
}

.mobile-menu-btn { display: none; }

@media (max-width: 767px) {
  .app-canvas { margin: 0; border-radius: 0; box-shadow: none; }
  .canvas-topbar { padding: var(--space-3) var(--space-4); }
  .canvas-content { padding: var(--space-4); }
  .mobile-menu-btn { display: inline-flex; }
}
```

Note on `overflow: clip` versus `hidden`: `hidden` creates a scroll container, which breaks `position: sticky` on the top bar. `clip` doesn't.
