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
  chart: ['M4 20V10', 'M10 20V4', 'M16 20v-7', 'M22 20H2']
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
