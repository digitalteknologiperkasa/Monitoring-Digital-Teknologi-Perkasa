<script setup>
import { ref, onMounted, computed } from 'vue'
import axios from '../lib/axios'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const projectName = ref(localStorage.getItem('app_name') || 'Monitoring Digitek')
const projectId = ref(localStorage.getItem('project_id') || null)
const isUpdating = ref(false)
const userRole = ref('Viewer')

// Fetch User Profile (Role & Project ID)
const fetchUserProfile = async () => {
  try {
    const { data } = await axios.get(`/profiles?id=eq.${authStore.user.id}&select=role,project_id`, {
      headers: { 'Accept': 'application/vnd.pgrst.object+json' }
    })
    userRole.value = data?.role || 'Viewer'
    if (data?.project_id) {
      projectId.value = data.project_id
      localStorage.setItem('project_id', data.project_id)
    }
  } catch (error) {
    console.error('Error fetching profile:', error)
  }
}

// Fetch Project Info
const fetchProjectInfo = async () => {
  try {
    const idToFetch = projectId.value || authStore.user?.project_id || 1
    const { data } = await axios.get(`/projects?id=eq.${idToFetch}&select=*&limit=1`)
    if (data && data.length > 0) {
      const project = data[0]
      projectName.value = project.name
      projectId.value = project.id
      localStorage.setItem('project_id', project.id)
      localStorage.setItem('app_name', project.name)
      
      // Update sidebar name if needed (via event or store)
      window.dispatchEvent(new CustomEvent('app-name-updated', { detail: project.name }))
    }
  } catch (error) {
    console.error('Error fetching project info:', error)
  }
}

const canEditProject = computed(() => ['Super Admin'].includes(userRole.value))

const updateProjectName = async () => {
  if (!canEditProject.value) {
    alert('Hanya Super Admin yang dapat mengubah nama proyek.')
    return
  }

  if (!projectName.value.trim()) {
    alert('Nama proyek tidak boleh kosong.')
    return
  }

  isUpdating.value = true
  try {
    if (projectId.value) {
      await axios.patch(`/projects?id=eq.${projectId.value}`, {
        name: projectName.value.trim()
      })
    } else {
      const { data } = await axios.post('/projects', {
        name: projectName.value.trim()
      }, {
        headers: { 'Prefer': 'return=representation' }
      })
      if (data && data.length > 0) {
        projectId.value = data[0].id
        localStorage.setItem('project_id', data[0].id)
      }
    }
    
    localStorage.setItem('app_name', projectName.value.trim())
    window.dispatchEvent(new CustomEvent('app-name-updated', { detail: projectName.value.trim() }))
    alert('Nama proyek berhasil diperbarui!')
  } catch (error) {
    console.error('Error updating project name:', error)
    alert('Gagal memperbarui nama proyek: ' + (error.response?.data?.message || error.message))
  } finally {
    isUpdating.value = false
  }
}

onMounted(() => {
  fetchUserProfile()
  fetchProjectInfo()
})
</script>

<template>
  <div class="max-w-4xl mx-auto space-y-8 animate-in fade-in duration-500">
    <!-- Header Section -->
    <div class="flex flex-col gap-1">
      <h2 class="text-[#121417] dark:text-white text-3xl font-extrabold leading-tight tracking-tight">
        System Settings
      </h2>
      <p class="text-[#646f82] dark:text-gray-400 text-base font-normal">
        Manage application preferences and configuration.
      </p>
    </div>

    <div class="grid grid-cols-1 gap-8">
      <!-- General Information -->
      <section class="bg-white dark:bg-[#141414] rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm overflow-hidden">
        <div class="px-6 py-5 border-b border-gray-100 dark:border-gray-800 flex items-center gap-3">
          <div class="size-10 rounded-lg bg-emerald-50 dark:bg-emerald-500/10 flex items-center justify-center">
            <span class="material-symbols-outlined text-emerald-600 dark:text-emerald-400">info</span>
          </div>
          <h3 class="text-lg font-bold text-[#121417] dark:text-white">
            General Information
          </h3>
        </div>
        <div class="p-6">
          <div class="max-w-md space-y-4">
            <div>
              <label class="block text-sm font-semibold text-[#121417] dark:text-white mb-2">
                Log Name / Project Title
              </label>
              <div class="flex gap-3">
                <input
                  v-model="projectName"
                  type="text"
                  :disabled="!canEditProject"
                  class="flex-1 bg-gray-50 dark:bg-[#1a1a1a] border border-gray-200 dark:border-gray-700 rounded-lg py-2.5 px-4 text-sm text-gray-900 dark:text-white focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 outline-none transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                  placeholder="Masukkan nama proyek..."
                />
                <button
                  @click="updateProjectName"
                  :disabled="isUpdating || !canEditProject"
                  class="bg-emerald-600 hover:bg-emerald-700 disabled:bg-gray-400 text-white px-6 py-2.5 rounded-lg text-sm font-bold shadow-lg shadow-emerald-900/10 transition-all flex items-center gap-2"
                >
                  <span v-if="isUpdating" class="size-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
                  <span>Update</span>
                </button>
              </div>
              <p v-if="!canEditProject" class="mt-2 text-xs text-amber-600 dark:text-amber-400 flex items-center gap-1">
                <span class="material-symbols-outlined text-xs">warning</span>
                Hanya akun dengan role Super Admin yang dapat mengubah nama proyek.
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- Appearance -->
      <section class="bg-white dark:bg-[#141414] rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm overflow-hidden">
        <div class="px-6 py-5 border-b border-gray-100 dark:border-gray-800 flex items-center gap-3">
          <div class="size-10 rounded-lg bg-blue-50 dark:bg-blue-500/10 flex items-center justify-center">
            <span class="material-symbols-outlined text-blue-600 dark:text-blue-400">palette</span>
          </div>
          <h3 class="text-lg font-bold text-[#121417] dark:text-white">
            Appearance
          </h3>
        </div>
        <div class="p-6 space-y-6">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-semibold text-[#121417] dark:text-white">Interface Theme</p>
              <p class="text-xs text-gray-500 dark:text-gray-400">Kustomisasi tampilan aplikasi sesuai keinginan Anda.</p>
            </div>
            <div class="relative flex items-center bg-gray-100 dark:bg-[#1a1a1a] rounded-lg p-1 border border-gray-200 dark:border-gray-700 w-[180px] h-10 overflow-hidden cursor-pointer" @click="$emit('toggleDarkMode')">
              <!-- Slider Background -->
              <div 
                class="absolute top-1 bottom-1 w-[calc(50%-4px)] rounded-md transition-all duration-300 ease-in-out shadow-sm"
                :class="[$parent.isDarkMode ? 'translate-x-[calc(100%+4px)] bg-gray-800' : 'translate-x-0 bg-white']"
              ></div>
              
              <!-- Light Button -->
              <div 
                class="relative flex-1 flex items-center justify-center gap-2 text-sm font-semibold transition-colors duration-300 z-10"
                :class="[!$parent.isDarkMode ? 'text-amber-500' : 'text-gray-500']"
              >
                <span class="material-symbols-outlined text-[20px]">light_mode</span>
                <span>Light</span>
              </div>

              <!-- Dark Button -->
              <div 
                class="relative flex-1 flex items-center justify-center gap-2 text-sm font-semibold transition-colors duration-300 z-10"
                :class="[$parent.isDarkMode ? 'text-emerald-400' : 'text-gray-500']"
              >
                <span class="material-symbols-outlined text-[20px]">dark_mode</span>
                <span>Dark</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Language -->
      <section class="bg-white dark:bg-[#141414] rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm overflow-hidden">
        <div class="px-6 py-5 border-b border-gray-100 dark:border-gray-800 flex items-center gap-3">
          <div class="size-10 rounded-lg bg-purple-50 dark:bg-purple-500/10 flex items-center justify-center">
            <span class="material-symbols-outlined text-purple-600 dark:text-purple-400">language</span>
          </div>
          <h3 class="text-lg font-bold text-[#121417] dark:text-white">
            Language
          </h3>
        </div>
        <div class="p-6">
          <div class="max-w-xs">
            <label class="block text-sm font-semibold text-[#121417] dark:text-white mb-2">Pilih Bahasa</label>
            <select class="w-full bg-gray-50 dark:bg-[#1a1a1a] border border-gray-200 dark:border-gray-700 rounded-lg py-2.5 px-4 text-sm text-gray-900 dark:text-white focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all">
              <option value="id">Bahasa Indonesia</option>
              <option value="en">English (Coming Soon)</option>
            </select>
          </div>
        </div>
      </section>

      <!-- Help & Support -->
      <section class="bg-white dark:bg-[#141414] rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm overflow-hidden">
        <div class="px-6 py-5 border-b border-gray-100 dark:border-gray-800 flex items-center gap-3">
          <div class="size-10 rounded-lg bg-orange-50 dark:bg-orange-500/10 flex items-center justify-center">
            <span class="material-symbols-outlined text-orange-600 dark:text-orange-400">help</span>
          </div>
          <h3 class="text-lg font-bold text-[#121417] dark:text-white">
            Help & Support
          </h3>
        </div>
        <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-4">
          <a href="#" class="flex items-start gap-4 p-4 rounded-xl border border-gray-100 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-[#1a1a1a] transition-all group">
            <div class="size-10 rounded-full bg-gray-100 dark:bg-gray-800 flex items-center justify-center group-hover:bg-emerald-500 group-hover:text-white transition-all">
              <span class="material-symbols-outlined">description</span>
            </div>
            <div>
              <p class="text-sm font-bold text-[#121417] dark:text-white">Dokumentasi</p>
              <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">Baca panduan dan referensi API.</p>
            </div>
          </a>
          <a href="#" class="flex items-start gap-4 p-4 rounded-xl border border-gray-100 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-[#1a1a1a] transition-all group">
            <div class="size-10 rounded-full bg-gray-100 dark:bg-gray-800 flex items-center justify-center group-hover:bg-emerald-500 group-hover:text-white transition-all">
              <span class="material-symbols-outlined">support_agent</span>
            </div>
            <div>
              <p class="text-sm font-bold text-[#121417] dark:text-white">Hubungi Support</p>
              <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">Dapatkan bantuan teknis dari tim kami.</p>
            </div>
          </a>
        </div>
      </section>
    </div>
  </div>
</template>
