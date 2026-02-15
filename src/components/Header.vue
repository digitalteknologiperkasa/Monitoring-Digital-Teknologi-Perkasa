<script setup>
import { useRoute } from 'vue-router'

const props = defineProps({
  isDarkMode: Boolean,
  isSidebarOpen: Boolean,
  userProfile: Object
})

const emit = defineEmits(['toggleSidebar', 'toggleDarkMode', 'toggleMobileSidebar', 'logout'])
const route = useRoute()
</script>

<template>
  <header class="h-16 bg-white dark:bg-[#141414] border-b border-slate-200 dark:border-gray-800 flex items-center justify-between px-4 md:px-6 sticky top-0 z-40 flex-shrink-0 transition-colors">
    <div class="flex items-center gap-2 md:gap-4 flex-1">
      <!-- Mobile Hamburger -->
      <button 
        @click="emit('toggleMobileSidebar')"
        class="lg:hidden p-2 text-slate-600 dark:text-gray-400 hover:bg-slate-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
      >
        <span class="material-symbols-outlined">menu</span>
      </button>

      <div class="flex flex-col lg:flex-row lg:items-center lg:gap-4 flex-1 text-center lg:text-left">
        <div class="lg:flex-1">
          <h1 class="text-base md:text-lg font-bold text-slate-800 dark:text-white leading-tight truncate px-2 lg:px-0">
            {{ route.meta.title || 'Dashboard Overview' }}
          </h1>
          <p class="text-[10px] md:text-xs text-slate-500 dark:text-gray-400 truncate px-2 lg:px-0">
            {{ route.meta.subtitle || 'Overview sistem dan status pembaruan' }}
          </p>
        </div>
      </div>
    </div>

    <div class="flex items-center gap-2 md:gap-4">
      <!-- Search (Hidden on small mobile) -->
      <!-- <div class="relative hidden xl:block">
        <input 
          class="pl-9 pr-4 py-1.5 text-sm border border-slate-200 dark:border-gray-700 rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none w-64 text-slate-600 dark:text-gray-300 bg-slate-50 dark:bg-[#1a1a1a] transition-colors"
          placeholder="Cari modul atau log..."
          type="text"
        />
        <span class="material-symbols-outlined absolute left-2.5 top-1.5 text-slate-400 text-lg">search</span>
      </div> -->

      <div class="hidden lg:block h-6 w-px bg-slate-200 dark:bg-gray-700 mx-2"></div>

      <!-- Dark Mode Toggle (Minimalist Oval Design) -->
      <button 
        @click="emit('toggleDarkMode')"
        class="relative flex items-center h-8 w-14 rounded-full p-1 transition-all duration-300 focus:outline-none shadow-inner border border-slate-200 dark:border-gray-700 bg-slate-100 dark:bg-[#1a1a1a]"
        aria-label="Toggle Dark Mode"
      >
        <!-- Circle Switcher -->
        <div 
          class="absolute h-6 w-6 rounded-full flex items-center justify-center shadow-md transform transition-all duration-300 ease-[cubic-bezier(0.34,1.56,0.64,1)]"
          :class="[isDarkMode ? 'translate-x-6 bg-slate-800' : 'translate-x-0 bg-white']"
        >
          <span 
            class="material-symbols-outlined text-[18px] transition-all duration-300"
            :class="[isDarkMode ? 'text-emerald-400 rotate-0' : 'text-amber-500 rotate-12']"
          >
            {{ isDarkMode ? 'dark_mode' : 'light_mode' }}
          </span>
        </div>
        
        <!-- Background Icons (Optional for better aesthetics) -->
        <div class="flex justify-between w-full px-1 opacity-20 dark:opacity-40">
          <span class="material-symbols-outlined text-[14px]">light_mode</span>
          <span class="material-symbols-outlined text-[14px]">dark_mode</span>
        </div>
      </button>

      <!-- Notifications -->
      <button class="relative p-2 text-slate-500 dark:text-gray-400 hover:bg-slate-50 dark:hover:bg-gray-800 rounded-full transition-colors">
        <span class="material-symbols-outlined">notifications</span>
        <span class="absolute top-2 right-2 size-2 bg-rose-500 rounded-full border border-white dark:border-[#141414]"></span>
      </button>
    </div>
  </header>
</template>
