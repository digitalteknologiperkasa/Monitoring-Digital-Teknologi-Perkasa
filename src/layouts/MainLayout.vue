<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { supabase } from '../lib/supabase'
import Sidebar from '../components/Sidebar.vue'
import Header from '../components/Header.vue'

const router = useRouter()
const authStore = useAuthStore()

const isDarkMode = ref(localStorage.getItem('darkMode') === 'true')
const isSidebarOpen = ref(true)
const isMobileSidebarOpen = ref(false)
const projectName = ref(localStorage.getItem('app_name') || 'Monitoring Digitek')
const userProfile = ref({
  name: 'Memuat...',
  role: 'Viewer', // Default to Viewer
  avatar: 'https://ui-avatars.com/api/?name=User&background=random'
})

const toggleDarkMode = () => {
  isDarkMode.value = !isDarkMode.value
  if (isDarkMode.value) {
    document.documentElement.classList.add('dark')
    document.documentElement.style.backgroundColor = ''
  } else {
    document.documentElement.classList.remove('dark')
    document.documentElement.style.backgroundColor = '#f8fafc'
  }
  localStorage.setItem('darkMode', isDarkMode.value)
}

const toggleSidebar = () => {
  isSidebarOpen.value = !isSidebarOpen.value
}

const toggleMobileSidebar = () => {
  isMobileSidebarOpen.value = !isMobileSidebarOpen.value
}

const closeMobileSidebar = () => {
  isMobileSidebarOpen.value = false
}

const handleLogout = async () => {
  await authStore.signOut()
  router.push('/login')
}

const updateProjectName = (e) => {
  projectName.value = e.detail
}

onMounted(async () => {
  window.addEventListener('app-name-updated', updateProjectName)
  
  // Ensure dark mode is applied on mount
  if (isDarkMode.value) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
    // Force background color for light mode consistency
    document.documentElement.style.backgroundColor = '#f8fafc'
  }

  if (authStore.user) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('*, project_id')
      .eq('id', authStore.user.id)
      .single()
    
    if (profile) {
      userProfile.value = {
        name: profile.full_name || authStore.user.email.split('@')[0],
        role: profile.role || 'Viewer',
        description: profile.description || '',
        avatar: profile.avatar_url || `https://ui-avatars.com/api/?name=${profile.full_name || 'User'}&background=random`
      }

      // Ambil Nama Projek berdasarkan project_id user
      const { data: project } = await supabase
        .from('projects')
        .select('name')
        .eq('id', profile.project_id || 1)
        .single()
      
      if (project) {
        projectName.value = project.name
        localStorage.setItem('app_name', project.name)
        localStorage.setItem('project_id', profile.project_id || 1)
      }
    }
  }
})

onUnmounted(() => {
  window.removeEventListener('app-name-updated', updateProjectName)
})

const menuItems = [
  { name: 'Dashboard', icon: 'dashboard', path: '/' },
  { name: 'Manajemen Semua Log', icon: 'bug_report', path: '/logs' },
  { name: 'Manajemen Fitur', icon: 'featured_play_list', path: '/features' },
  { name: 'Manajemen Version Control', icon: 'history', path: '/version-control' },
  { name: 'Manajemen Access Control', icon: 'admin_panel_settings', path: '/access-control' },
  { name: 'Laporan & Statistik', icon: 'analytics', path: '/reports' },
]

const filteredAdminItems = computed(() => {
  const items = [
    { name: 'Manajemen Akses Tim', icon: 'groups', path: '/team', roles: ['Super Admin', 'Editor'] },
    { name: 'Pengaturan', icon: 'settings', path: '/settings', roles: ['Super Admin', 'Editor', 'Viewer'] },
  ]
  
  return items.filter(item => !item.roles || item.roles.includes(userProfile.value.role))
})
</script>

<template>
  <div class="flex h-screen bg-background-light dark:bg-background-dark font-sans overflow-hidden transition-colors duration-300">
    <!-- Overlay for mobile -->
    <div 
      v-if="isMobileSidebarOpen" 
      class="fixed inset-0 bg-black/50 z-40 lg:hidden backdrop-blur-sm transition-opacity"
      @click="closeMobileSidebar"
    ></div>

    <!-- Sidebar -->
    <Sidebar 
      :is-sidebar-open="isSidebarOpen"
      :is-mobile-sidebar-open="isMobileSidebarOpen"
      :user-profile="userProfile"
      :project-name="projectName"
      :menu-items="menuItems"
      :admin-items="filteredAdminItems"
      @logout="handleLogout"
      @toggle-sidebar="toggleSidebar"
      @toggle-mobile-sidebar="toggleMobileSidebar"
    />

    <!-- Main Content -->
    <div class="flex-1 flex flex-col min-w-0 h-screen">
      <!-- Header -->
      <Header 
        :is-dark-mode="isDarkMode"
        :is-sidebar-open="isSidebarOpen"
        :user-profile="userProfile"
        @toggle-sidebar="toggleSidebar"
        @toggle-dark-mode="toggleDarkMode"
        @toggle-mobile-sidebar="toggleMobileSidebar"
        @logout="handleLogout"
      />

      <!-- Content Area -->
      <main class="flex-1 overflow-y-auto overflow-x-hidden custom-scrollbar bg-slate-50 dark:bg-background-dark p-6 transition-colors">
        <router-view @toggle-dark-mode="toggleDarkMode"></router-view>
      </main>
    </div>
  </div>
</template>

<style>
.custom-scrollbar::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 10px;
}
.dark .custom-scrollbar::-webkit-scrollbar-thumb {
  background: #334155;
}
</style>
