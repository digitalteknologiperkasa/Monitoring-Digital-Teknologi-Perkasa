<script setup>
import { useRoute } from 'vue-router'
import { computed } from 'vue'

const props = defineProps({
  isSidebarOpen: Boolean,
  isMobileSidebarOpen: Boolean,
  userProfile: Object,
  projectName: String,
  projectDescription: String,
  menuItems: Array,
  adminItems: Array
})

const emit = defineEmits(['logout', 'toggleSidebar', 'toggleMobileSidebar'])
const route = useRoute()

const truncatedDescription = computed(() => {
  const desc = props.projectDescription || 'DIGITAL PLATFORM'
  const words = desc.split(' ')
  if (words.length <= 3) return desc
  return words.slice(0, 3).join(' ') + '....'
})

const handleNavClick = () => {
  if (window.innerWidth < 1024) { // lg breakpoint
    emit('toggleMobileSidebar')
  }
}

const handleLogout = () => {
  emit('logout')
}
</script>

<template>
  <aside 
    :class="[
      'bg-white dark:bg-[#0d1f1f] flex flex-col flex-shrink-0 transition-all duration-300 z-50 border-r border-slate-200 dark:border-white/5',
      'fixed inset-y-0 left-0 lg:relative lg:translate-x-0 shadow-[4px_0_24px_-12px_rgba(0,0,0,0.1)]',
      isMobileSidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0',
      isSidebarOpen ? 'w-64' : 'w-20'
    ]"
  >
    <!-- Sidebar Header -->
    <div class="h-16 flex items-center justify-between px-6 border-b border-slate-100 dark:border-white/10 flex-shrink-0">
      <div class="flex items-center gap-3 overflow-hidden">
        <div class="flex-shrink-0">
          <img src="/digitek putih.webp" alt="Logo" class="size-10 object-contain" />
        </div>
        <div v-if="isSidebarOpen" class="flex flex-col overflow-hidden">
          <span class="text-sm font-bold leading-tight text-slate-900 dark:text-white truncate">{{ projectName }}</span>
          <router-link to="/settings" class="hover:underline">
            <span class="text-[8px] text-emerald-600 dark:text-emerald-400 font-medium tracking-wide" :title="projectDescription || 'DIGITAL PLATFORM'">{{ truncatedDescription }}</span>
          </router-link>
        </div>
      </div>
      
      <!-- Close button / Toggle button inside sidebar -->
      <button 
        @click="emit('toggleMobileSidebar')"
        class="lg:hidden text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors"
      >
        <span class="material-symbols-outlined text-xl">close</span>
      </button>
      
      <button 
        @click="emit('toggleSidebar')"
        class="hidden lg:block text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors"
      >
        <span class="material-symbols-outlined text-xl">
          {{ isSidebarOpen ? 'menu_open' : 'menu' }}
        </span>
      </button>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 py-6 px-4 flex flex-col gap-1 overflow-y-auto custom-scrollbar">
      <div v-if="isSidebarOpen" class="px-3 mb-2 text-[10px] font-bold text-slate-400 uppercase tracking-widest">Main Menu</div>
      
      <router-link 
        v-for="item in menuItems" 
        :key="item.path"
        :to="item.path"
        @click="handleNavClick"
        class="flex items-center gap-3 px-3 py-3 rounded-r-lg transition-all group border-l-[3px] border-transparent"
        :class="[route.path === item.path ? 'bg-emerald-50 dark:bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-600 dark:border-emerald-400 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-white/5 hover:text-slate-900 dark:hover:text-white']"
      >
        <span class="material-symbols-outlined text-xl group-hover:text-emerald-500 transition-colors">{{ item.icon }}</span>
        <span v-if="isSidebarOpen" class="text-sm font-medium">{{ item.name }}</span>
      </router-link>

      <div class="my-3 mx-3 border-t border-slate-100 dark:border-white/10"></div>
      
      <div v-if="isSidebarOpen" class="px-3 mb-2 text-[10px] font-bold text-slate-400 uppercase tracking-widest">Administrasi</div>
      
      <router-link 
        v-for="item in adminItems" 
        :key="item.path"
        :to="item.path"
        @click="handleNavClick"
        class="flex items-center gap-3 px-3 py-3 rounded-r-lg transition-all group border-l-[3px] border-transparent"
        :class="[route.path === item.path ? 'bg-emerald-50 dark:bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-600 dark:border-emerald-400 shadow-sm' : 'text-slate-500 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-white/5 hover:text-slate-900 dark:hover:text-white']"
      >
        <span class="material-symbols-outlined text-xl group-hover:text-emerald-500 transition-colors">{{ item.icon }}</span>
        <span v-if="isSidebarOpen" class="text-sm font-medium">{{ item.name }}</span>
      </router-link>
    </nav>

    <!-- Sidebar Footer / Profile -->
    <div class="p-4 border-t border-slate-100 dark:border-white/10 flex-shrink-0">
      <div class="flex items-center gap-3 px-2">
        <div 
          class="size-10 rounded-full bg-slate-100 dark:bg-slate-800 bg-cover border border-slate-200 dark:border-white/10 shadow-sm flex-shrink-0 flex items-center justify-center font-bold text-slate-600 dark:text-slate-400 text-sm"
          :style="userProfile?.avatar ? { backgroundImage: `url(${userProfile.avatar})` } : {}"
        >
          <span v-if="!userProfile?.avatar">{{ userProfile?.name?.charAt(0).toUpperCase() || 'U' }}</span>
        </div>
        <div v-if="isSidebarOpen" class="flex-1 min-w-0 overflow-hidden">
          <p class="text-xs font-bold truncate text-slate-900 dark:text-white">{{ userProfile?.name || 'User' }}</p>
          <p class="text-[9px] text-slate-400 dark:text-slate-500 italic truncate mb-0.5" v-if="userProfile?.description">
            {{ userProfile.description }}
          </p>
          <p class="text-[10px] text-slate-500 dark:text-emerald-400">{{ userProfile?.role || 'Viewer' }}</p>
        </div>
        <button 
          v-if="isSidebarOpen"
          @click="handleLogout"
          class="text-slate-400 hover:text-red-600 dark:hover:text-red-400 transition-colors p-1 hover:bg-red-50 dark:hover:bg-red-500/10 rounded"
          title="Keluar Sistem"
        >
          <span class="material-symbols-outlined text-xl">logout</span>
        </button>
      </div>
      <button 
        v-if="!isSidebarOpen"
        @click="handleLogout"
        class="mt-4 w-full flex items-center justify-center text-slate-400 hover:text-red-600 transition-colors"
      >
        <span class="material-symbols-outlined">logout</span>
      </button>
    </div>
  </aside>
</template>
