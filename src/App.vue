<script setup>
import { onMounted } from 'vue'
import { useAuthStore } from './stores/auth'

const authStore = useAuthStore()

onMounted(async () => {
  console.log('App Mounted, checking environment variables...')
  console.log('API URL:', import.meta.env.VITE_SUPABASE_URL)
  console.log('Anon Key Present:', !!import.meta.env.VITE_SUPABASE_ANON_KEY)
  
  try {
    await authStore.initialize()
    console.log('Auth initialized. User:', authStore.user?.email || 'Not logged in')
  } catch (error) {
    console.error('Auth Init Error:', error)
  }
  
  // Check for dark mode preference
  if (localStorage.getItem('darkMode') === 'true' || 
      (!localStorage.getItem('darkMode') && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    document.documentElement.classList.add('dark')
  }
})
</script>

<template>
  <router-view v-if="!authStore.loading" />
  <div v-else class="h-screen w-screen flex items-center justify-center bg-background-light dark:bg-background-dark">
    <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-600"></div>
  </div>
</template>

<style>
/* Global styles already in style.css */
</style>
