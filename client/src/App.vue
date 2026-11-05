<template>
  <div class="app-shell">
    <AppSidebar :items="navItems" :mobile-open="mobileNavOpen" @close-mobile="mobileNavOpen = false">
      <template #brand="{ collapsed }">
        <div class="brand">
          <span class="brand-mark" aria-hidden="true">
            <svg viewBox="0 0 24 24">
              <path d="M21 8 12 3 3 8v8l9 5 9-5V8z" />
              <path d="M3 8l9 5 9-5" />
              <path d="M12 13v8" />
            </svg>
          </span>
          <div v-if="!collapsed" class="brand-text">
            <span class="brand-name">{{ t('nav.companyName') }}</span>
            <span class="brand-subtitle">{{ t('nav.subtitle') }}</span>
          </div>
        </div>
      </template>
      <template #footer="{ collapsed }">
        <LanguageSwitcher :collapsed="collapsed" />
        <ProfileMenu
          :collapsed="collapsed"
          @show-profile-details="showProfileDetails = true"
          @show-tasks="showTasks = true"
        />
      </template>
    </AppSidebar>

    <div class="app-canvas">
      <header class="canvas-topbar">
        <button
          type="button"
          class="mobile-menu-btn"
          aria-label="Open navigation"
          @click="mobileNavOpen = true"
        >
          <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
        <FilterBar />
      </header>
      <main class="canvas-content">
        <router-view />
      </main>
    </div>

    <ProfileDetailsModal
      :is-open="showProfileDetails"
      @close="showProfileDetails = false"
    />

    <TasksModal
      :is-open="showTasks"
      :tasks="tasks"
      @close="showTasks = false"
      @add-task="addTask"
      @delete-task="deleteTask"
      @toggle-task="toggleTask"
    />
  </div>
</template>

<script>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { api } from './api'
import { useAuth } from './composables/useAuth'
import { useI18n } from './composables/useI18n'
import FilterBar from './components/FilterBar.vue'
import ProfileMenu from './components/ProfileMenu.vue'
import ProfileDetailsModal from './components/ProfileDetailsModal.vue'
import TasksModal from './components/TasksModal.vue'
import LanguageSwitcher from './components/LanguageSwitcher.vue'
import AppSidebar from './components/AppSidebar.vue'

export default {
  name: 'App',
  components: {
    AppSidebar,
    FilterBar,
    ProfileMenu,
    ProfileDetailsModal,
    TasksModal,
    LanguageSwitcher
  },
  setup() {
    const { currentUser } = useAuth()
    const { t } = useI18n()
    const showProfileDetails = ref(false)
    const showTasks = ref(false)
    const apiTasks = ref([])
    const route = useRoute()
    const mobileNavOpen = ref(false)

    // Computed so the labels re-translate when the locale changes.
    // Order and paths mirror the routes in main.js; "Reports" has no locale key yet.
    const navItems = computed(() => [
      { to: '/', label: t('nav.overview'), icon: 'home' },
      { to: '/inventory', label: t('nav.inventory'), icon: 'box' },
      { to: '/orders', label: t('nav.orders'), icon: 'cart' },
      { to: '/spending', label: t('nav.finance'), icon: 'wallet' },
      { to: '/demand', label: t('nav.demandForecast'), icon: 'trend' },
      { to: '/reports', label: 'Reports', icon: 'chart' }
    ])

    // Close the mobile drawer after any navigation
    watch(() => route.fullPath, () => { mobileNavOpen.value = false })

    // Merge mock tasks from currentUser with API tasks
    const tasks = computed(() => {
      return [...currentUser.value.tasks, ...apiTasks.value]
    })

    const loadTasks = async () => {
      try {
        apiTasks.value = await api.getTasks()
      } catch (err) {
        console.error('Failed to load tasks:', err)
      }
    }

    const addTask = async (taskData) => {
      try {
        const newTask = await api.createTask(taskData)
        // Add new task to the beginning of the array
        apiTasks.value.unshift(newTask)
      } catch (err) {
        console.error('Failed to add task:', err)
      }
    }

    const deleteTask = async (taskId) => {
      try {
        // Check if it's a mock task (from currentUser)
        const isMockTask = currentUser.value.tasks.some(t => t.id === taskId)

        if (isMockTask) {
          // Remove from mock tasks
          const index = currentUser.value.tasks.findIndex(t => t.id === taskId)
          if (index !== -1) {
            currentUser.value.tasks.splice(index, 1)
          }
        } else {
          // Remove from API tasks
          await api.deleteTask(taskId)
          apiTasks.value = apiTasks.value.filter(t => t.id !== taskId)
        }
      } catch (err) {
        console.error('Failed to delete task:', err)
      }
    }

    const toggleTask = async (taskId) => {
      try {
        // Check if it's a mock task (from currentUser)
        const mockTask = currentUser.value.tasks.find(t => t.id === taskId)

        if (mockTask) {
          // Toggle mock task status
          mockTask.status = mockTask.status === 'pending' ? 'completed' : 'pending'
        } else {
          // Toggle API task
          const updatedTask = await api.toggleTask(taskId)
          const index = apiTasks.value.findIndex(t => t.id === taskId)
          if (index !== -1) {
            apiTasks.value[index] = updatedTask
          }
        }
      } catch (err) {
        console.error('Failed to toggle task:', err)
      }
    }

    onMounted(loadTasks)

    return {
      t,
      navItems,
      mobileNavOpen,
      showProfileDetails,
      showTasks,
      tasks,
      addTask,
      deleteTask,
      toggleTask
    }
  }
}
</script>

<style>
/*
 * Inset Canvas design tokens.
 * Brand blue (#2563eb) from the old nav is retained as --info; the new shell accent is indigo.
 */
:root {
  /* Spacing: 4px scale */
  --space-0: 0;
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-3: 0.75rem;  /* 12px */
  --space-4: 1rem;     /* 16px */
  --space-5: 1.25rem;  /* 20px */
  --space-6: 1.5rem;   /* 24px */
  --space-8: 2rem;     /* 32px */
  --space-10: 2.5rem;  /* 40px */
  --space-12: 3rem;    /* 48px */

  /* Radius */
  --radius-sm: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-full: 999px;

  /* Typography */
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --text-xs: 0.75rem;
  --text-sm: 0.8125rem;
  --text-base: 0.875rem;
  --text-md: 0.9375rem;
  --text-lg: 1.0625rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --text-3xl: 1.875rem;

  /* Neutrals (slate) */
  --text: #0f172a;
  --text-secondary: #334155;
  --text-muted: #64748b;
  --text-faint: #94a3b8;
  --border: #e2e8f0;
  --border-strong: #cbd5e1;
  --surface: #ffffff;
  --surface-subtle: #f8fafc;
  --surface-muted: #f1f5f9;
  --canvas: #f8fafc;

  /* Accent (indigo) */
  --accent-50: #eef2ff;
  --accent-100: #e0e7ff;
  --accent-500: #6366f1;
  --accent-600: #4f46e5;
  --accent-700: #4338ca;

  /* Status */
  --success-bg: #d1fae5;  --success-fg: #065f46;  --success: #059669;
  --info-bg: #dbeafe;     --info-fg: #1e40af;     --info: #2563eb;
  --warning-bg: #fef3c7;  --warning-fg: #92400e;  --warning: #d97706;
  --danger-bg: #fee2e2;   --danger-fg: #991b1b;   --danger: #dc2626;

  /* Rail (dark sidebar) */
  --rail-bg: #0f172a;
  --rail-bg-end: #111827;
  --rail-text: #94a3b8;
  --rail-text-strong: #f1f5f9;
  --rail-hover: rgba(148, 163, 184, 0.10);
  --rail-active: rgba(99, 102, 241, 0.16);
  --rail-indicator: #818cf8;
  --rail-border: rgba(148, 163, 184, 0.12);
  --rail-width: 248px;
  --rail-width-collapsed: 72px;

  /* Elevation */
  --shadow-xs: 0 1px 2px rgba(15, 23, 42, 0.04);
  --shadow-sm: 0 1px 3px rgba(15, 23, 42, 0.06), 0 1px 2px rgba(15, 23, 42, 0.04);
  --shadow-md: 0 4px 12px rgba(15, 23, 42, 0.08);
  --shadow-lg: 0 12px 32px rgba(15, 23, 42, 0.14);
  --shadow-canvas: 0 0 0 1px rgba(15, 23, 42, 0.06), 0 8px 24px rgba(2, 6, 23, 0.25);

  /* Motion */
  --ease: cubic-bezier(0.2, 0, 0, 1);
  --duration: 180ms;

  /* Layout */
  --canvas-inset: var(--space-2);
  --content-max: 1440px;
}

/* Base */
*, *::before, *::after { box-sizing: border-box; }

/* Zero margins/padding: existing views rely on this reset (kept from the previous global styles) */
* {
  margin: 0;
  padding: 0;
}

body {
  margin: 0;
  font-family: var(--font-sans);
  font-size: var(--text-base);
  color: var(--text);
  /* Slate shows around the inset canvas, so the rail colour doubles as page background */
  background: var(--rail-bg);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

:focus-visible {
  outline: 2px solid var(--accent-500);
  outline-offset: 2px;
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    transition-duration: 0.01ms !important;
    animation-duration: 0.01ms !important;
  }
}

/* Shell layout */
.app-shell {
  display: flex;
  min-height: 100vh;
  background: var(--rail-bg);
}

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
  /* clip (not hidden) so the sticky topbar keeps working while corners stay rounded */
  overflow: clip;
}

.canvas-topbar {
  position: sticky;
  top: 0;
  z-index: 50;
  display: flex;
  align-items: center;
  gap: var(--space-4);
  padding: var(--space-3) var(--space-8);
  background: color-mix(in srgb, var(--canvas) 85%, transparent);
  backdrop-filter: blur(8px);
  border-bottom: 1px solid var(--border);
}

.canvas-topbar > .filters-bar {
  flex: 1;
  min-width: 0;
}

.canvas-content {
  flex: 1;
  width: 100%;
  max-width: var(--content-max);
  margin: 0 auto;
  padding: var(--space-6) var(--space-8) var(--space-10);
}

.mobile-menu-btn {
  display: none;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  flex-shrink: 0;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  color: var(--text-secondary);
  cursor: pointer;
}

.mobile-menu-btn svg {
  width: 20px;
  height: 20px;
  fill: none;
  stroke: currentColor;
  stroke-width: 1.75;
  stroke-linecap: round;
}

/* Sidebar brand (rendered in the AppSidebar brand slot) */
.brand {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  min-width: 0;
}

.brand-mark {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  flex-shrink: 0;
  border-radius: var(--radius-md);
  background: var(--accent-600);
  color: var(--rail-text-strong);
}

.brand-mark svg {
  width: 18px;
  height: 18px;
  fill: none;
  stroke: currentColor;
  stroke-width: 1.75;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.brand-text {
  display: flex;
  flex-direction: column;
  min-width: 0;
  white-space: nowrap;
}

.brand-name {
  font-size: var(--text-md);
  font-weight: 600;
  color: var(--rail-text-strong);
  letter-spacing: -0.01em;
}

.brand-subtitle {
  font-size: var(--text-xs);
  color: var(--rail-text);
  overflow: hidden;
  text-overflow: ellipsis;
}

@media (max-width: 767px) {
  .app-canvas {
    margin: 0;
    border-radius: 0;
    box-shadow: none;
  }

  .canvas-topbar {
    padding: var(--space-3) var(--space-4);
  }

  .canvas-content {
    padding: var(--space-4);
  }

  .mobile-menu-btn {
    display: inline-flex;
  }
}

/* Page header */
.page-header {
  margin-bottom: var(--space-6);
}

.page-header h2 {
  font-size: var(--text-2xl);
  font-weight: 600;
  color: var(--text);
  margin-bottom: var(--space-1);
  letter-spacing: -0.02em;
}

.page-header p {
  color: var(--text-muted);
  font-size: var(--text-md);
}

/* Stat / KPI cards */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--space-5);
  margin-bottom: var(--space-6);
}

.stat-card {
  background: var(--surface);
  padding: var(--space-5);
  border-radius: var(--radius-lg);
  border: 1px solid var(--border);
  box-shadow: var(--shadow-xs);
  transition: box-shadow var(--duration) var(--ease), border-color var(--duration) var(--ease);
}

.stat-card:hover {
  border-color: var(--border-strong);
  box-shadow: var(--shadow-sm);
}

.stat-label {
  color: var(--text-muted);
  font-size: var(--text-xs);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: var(--space-2);
}

.stat-value {
  font-size: var(--text-3xl);
  font-weight: 700;
  color: var(--text);
  letter-spacing: -0.025em;
  font-variant-numeric: tabular-nums;
}

.stat-card.warning .stat-value {
  color: var(--warning);
}

.stat-card.success .stat-value {
  color: var(--success);
}

.stat-card.danger .stat-value {
  color: var(--danger);
}

.stat-card.info .stat-value {
  color: var(--info);
}

/* Cards */
.card {
  background: var(--surface);
  border-radius: var(--radius-lg);
  padding: var(--space-5);
  border: 1px solid var(--border);
  box-shadow: var(--shadow-xs);
  margin-bottom: var(--space-5);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-4);
  padding-bottom: var(--space-3);
  border-bottom: 1px solid var(--border);
}

.card-title {
  font-size: var(--text-lg);
  font-weight: 600;
  color: var(--text);
  letter-spacing: -0.02em;
}

/* Tables */
.table-container {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

thead {
  background: var(--surface-subtle);
  border-top: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
}

th {
  text-align: left;
  padding: var(--space-3);
  font-weight: 600;
  color: var(--text-muted);
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  /* Opaque so rows scroll underneath cleanly inside a scrolling table container */
  position: sticky;
  top: 0;
  background: var(--surface-subtle);
}

td {
  padding: var(--space-3);
  border-top: 1px solid var(--surface-muted);
  color: var(--text-secondary);
  font-size: var(--text-base);
  font-variant-numeric: tabular-nums;
}

/* Opt-in helper for numeric columns (add class="num" to th/td) */
th.num,
td.num {
  text-align: right;
}

tbody tr {
  transition: background-color var(--duration) var(--ease);
}

tbody tr:hover {
  background: var(--surface-subtle);
}

/* Badges: pill shape, sentence case */
.badge {
  display: inline-block;
  padding: var(--space-1) var(--space-3);
  border-radius: var(--radius-full);
  font-size: var(--text-xs);
  font-weight: 500;
}

.badge.success {
  background: var(--success-bg);
  color: var(--success-fg);
}

.badge.warning {
  background: var(--warning-bg);
  color: var(--warning-fg);
}

.badge.danger {
  background: var(--danger-bg);
  color: var(--danger-fg);
}

.badge.info {
  background: var(--info-bg);
  color: var(--info-fg);
}

.badge.increasing {
  background: var(--success-bg);
  color: var(--success-fg);
}

.badge.decreasing {
  background: var(--danger-bg);
  color: var(--danger-fg);
}

.badge.stable {
  background: var(--accent-100);
  color: var(--accent-700);
}

.badge.high {
  background: var(--danger-bg);
  color: var(--danger-fg);
}

.badge.medium {
  background: var(--warning-bg);
  color: var(--warning-fg);
}

.badge.low {
  background: var(--info-bg);
  color: var(--info-fg);
}

/* Loading / error states */
.loading {
  text-align: center;
  padding: var(--space-12);
  color: var(--text-muted);
  font-size: var(--text-md);
}

.error {
  background: var(--danger-bg);
  border: 1px solid var(--danger-bg);
  color: var(--danger-fg);
  padding: var(--space-4);
  border-radius: var(--radius-md);
  margin: var(--space-4) 0;
  font-size: var(--text-md);
}
</style>
