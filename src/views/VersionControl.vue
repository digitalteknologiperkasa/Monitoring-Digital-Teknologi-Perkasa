<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const versions = ref([])
const modules = ref(['Semua Modul'])
const componentList = ref([]) // For the select dropdown in modal
const searchQuery = ref('')
const filterModule = ref('Semua Modul')
const sortBy = ref('Terbaru')
const loading = ref(true)
const defaultProjectId = ref(null)
const currentView = ref('list') // 'list', 'detail'
const selectedVersion = ref(null)

// Modal & Form State
const showModal = ref(false)
const modalLoading = ref(false)
const isEditing = ref(false)
const form = ref({
  id: null,
  version_number: '',
  title: '',
  details: '',
  change_type: 'Feature',
  component_id: '',
  release_date: new Date().toISOString().split('T')[0],
  status: 'Pending QA',
  notes: '',
  pic_name: ''
})

const fetchDefaultProject = async () => {
  try {
    const projectId = authStore.user?.project_id || 1
    const { data, error } = await supabase.from('projects').select('id').eq('id', projectId).single()
    if (data) {
      defaultProjectId.value = data.id
    }
  } catch (error) {
    console.error('Error fetching project:', error)
  }
}

const fetchVersions = async () => {
  loading.value = true
  try {
    const projectId = authStore.user?.project_id || 1
    let query = supabase
      .from('version_logs')
      .select('*, app_components(id, name)')
      .eq('project_id', projectId)
      .order('release_date', { ascending: false })

    const { data, error } = await query
    
    if (error) throw error
    
    versions.value = data.map(v => ({
      id: v.id,
      version: v.version_number,
      date: v.release_date, // Keep original for display
      module: v.app_components?.name || 'General',
      type: v.change_type,
      description: v.title,
      pic: v.pic_name || 'N/A',
      status: v.status || 'Pending QA',
      notes: v.notes || '-',
      // Store original values for editing
      raw: v
    }))
  } catch (error) {
    console.error('Error fetching versions:', error.message)
  } finally {
    loading.value = false
  }
}

const fetchModules = async () => {
  try {
    const projectId = authStore.user?.project_id || 1
    const { data, error } = await supabase
      .from('app_components')
      .select('id, name')
      .eq('project_id', projectId)
      .order('name')
    
    if (error) throw error
    
    if (data) {
      componentList.value = data
      modules.value = ['Semua Modul', ...data.map(m => m.name)]
    }
  } catch (error) {
    console.error('Error fetching modules:', error.message)
  }
}

const openModal = (item = null) => {
  if (['Viewer'].includes(authStore.user?.role)) {
    alert('Anda tidak memiliki izin untuk melakukan aksi ini.')
    return
  }
  if (item) {
    isEditing.value = true
    form.value = {
      id: item.raw.id,
      version_number: item.raw.version_number,
      title: item.raw.title,
      details: item.raw.details,
      change_type: item.raw.change_type,
      component_id: item.raw.component_id,
      release_date: item.raw.release_date,
      status: item.raw.status || 'Pending QA',
      notes: item.raw.notes || '',
      pic_name: item.raw.pic_name || ''
    }
  } else {
    isEditing.value = false
    form.value = {
      id: null,
      version_number: '',
      title: '',
      details: '',
      change_type: 'Feature',
      component_id: componentList.value[0]?.id || '',
      release_date: new Date().toISOString().split('T')[0],
      status: 'Pending QA',
      notes: '',
      pic_name: ''
    }
  }
  showModal.value = true
}

const saveVersion = async () => {
  if (!authStore.user) {
    alert('Anda harus login untuk menyimpan data.')
    return
  }

  // Ensure we have a project ID
  if (!defaultProjectId.value) {
    await fetchDefaultProject()
    if (!defaultProjectId.value) {
      alert('Error: Data project tidak ditemukan. Pastikan tabel projects memiliki data.')
      return
    }
  }

  modalLoading.value = true
  try {
    const payload = {
      ...form.value,
      component_id: form.value.component_id || null, // Convert empty string to null
      project_id: authStore.user?.project_id || defaultProjectId.value || 1,
      pic_id: authStore.user?.id
    }

    console.log('Saving version with payload:', payload)

    if (isEditing.value) {
      const { error } = await supabase
        .from('version_logs')
        .update(payload)
        .eq('id', form.value.id)
      if (error) throw error
    } else {
      const { error } = await supabase
        .from('version_logs')
        .insert([payload])
      if (error) throw error
    }

    showModal.value = false
    fetchVersions()
  } catch (error) {
    console.error('Error saving version:', error)
    if (error.code === '42501') {
      alert('Error: Izin ditolak (RLS). Pastikan Anda memiliki hak akses yang cukup di database.')
    } else {
      alert('Error saving version: ' + (error.message || 'Unknown error'))
    }
  } finally {
    modalLoading.value = false
  }
}

const deleteVersion = async (id) => {
  if (['Viewer'].includes(authStore.user?.role)) {
    alert('Anda tidak memiliki izin untuk menghapus data.')
    return
  }
  if (!confirm('Apakah Anda yakin ingin menghapus data versi ini?')) return
  
  try {
    const { error } = await supabase
      .from('version_logs')
      .delete()
      .eq('id', id)
    
    if (error) throw error
    fetchVersions()
  } catch (error) {
    alert('Error deleting version: ' + error.message)
  }
}

const navigateTo = (view, item = null) => {
  currentView.value = view
  if (item) {
    selectedVersion.value = item
  } else {
    selectedVersion.value = null
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return { date: '-', time: '' }
  try {
    const d = new Date(dateStr)
    if (isNaN(d.getTime())) return { date: dateStr, time: '' }
    return {
      date: d.toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' }),
      time: d.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' })
    }
  } catch (e) {
    return { date: dateStr, time: '' }
  }
}

const getStatusBadgeClass = (status) => {
  switch (status) {
    case 'Done': return 'border-emerald-500/30 bg-emerald-50 text-emerald-600 dark:bg-emerald-900/20 dark:text-emerald-400'
    case 'In Progress': return 'border-blue-500/30 bg-blue-50 text-blue-600 dark:bg-blue-900/20 dark:text-blue-400'
    case 'Pending QA': return 'border-amber-500/30 bg-amber-50 text-amber-600 dark:bg-amber-900/20 dark:text-amber-400'
    case 'Rejected': return 'border-rose-500/30 bg-rose-50 text-rose-600 dark:bg-rose-900/20 dark:text-rose-400'
    default: return 'border-slate-500/30 bg-slate-50 text-slate-600 dark:bg-slate-900/20 dark:text-slate-400'
  }
}

onMounted(() => {
  fetchDefaultProject()
  fetchVersions()
  fetchModules()
})

const filteredVersions = computed(() => {
  return versions.value.filter(v => {
    const matchesSearch = v.version.toLowerCase().includes(searchQuery.value.toLowerCase()) || 
                          v.module.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                          v.description.toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchesModule = filterModule.value === 'Semua Modul' || v.module === filterModule.value
    return matchesSearch && matchesModule
  })
})

const getTypeBadgeClass = (type) => {
  switch (type) {
    case 'Feature': return 'border-emerald-500/30 bg-emerald-50 text-emerald-600 dark:bg-emerald-900/20 dark:text-emerald-400'
    case 'Bugfix': return 'border-rose-500/30 bg-rose-50 text-rose-600 dark:bg-rose-900/20 dark:text-rose-400'
    case 'Refactor': return 'border-amber-500/30 bg-amber-50 text-amber-600 dark:bg-amber-900/20 dark:text-amber-400'
    default: return 'border-slate-500/30 bg-slate-50 text-slate-600 dark:bg-slate-900/20 dark:text-slate-400'
  }
}

const getTypeIconClass = (type) => {
  switch (type) {
    case 'Feature': return 'bg-emerald-500'
    case 'Bugfix': return 'bg-rose-500'
    case 'Refactor': return 'bg-amber-500'
    default: return 'bg-slate-500'
  }
}
</script>

<template>
  <div class="max-w-[1600px] mx-auto space-y-6">
    <div v-if="currentView === 'list'" class="space-y-6 animate-in fade-in duration-300">
      <!-- Actions & Filters -->
      <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h3 class="text-xl font-bold text-slate-900 dark:text-white">Manajemen Versi</h3>
        <button 
          v-if="['Super Admin', 'Admin', 'Editor'].includes(authStore.user?.role)"
          @click="openModal()"
          class="flex items-center gap-2 px-4 py-2 text-sm font-bold text-white bg-emerald-600 rounded-lg hover:bg-emerald-700 transition-all shadow-lg shadow-emerald-900/20"
        >
          <span class="material-symbols-outlined text-[18px]">add</span>
          Tambah Data Versi
        </button>
      </div>

      <div class="flex flex-col md:flex-row gap-4">
        <div class="flex-1 relative">
          <span class="material-symbols-outlined absolute left-3 top-2.5 text-slate-400">search</span>
          <input 
            v-model="searchQuery"
            type="text" 
            placeholder="Cari versi, modul, atau deskripsi..." 
            class="w-full bg-white dark:bg-[#141414] border border-slate-200 dark:border-gray-800 rounded-lg py-2.5 pl-10 pr-4 text-sm text-slate-900 dark:text-slate-200 focus:ring-2 focus:ring-emerald-500 outline-none transition-all"
          />
        </div>
        <div class="flex gap-4">
          <select 
            v-model="filterModule"
            class="bg-white dark:bg-[#141414] border border-slate-200 dark:border-gray-800 rounded-lg px-4 py-2.5 text-sm text-slate-700 dark:text-slate-300 outline-none focus:ring-2 focus:ring-emerald-500 cursor-pointer"
          >
            <option v-for="mod in modules" :key="mod" :value="mod">{{ mod }}</option>
          </select>
        </div>
      </div>

      <!-- Table -->
      <div class="bg-white dark:bg-[#141414] rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm overflow-hidden min-h-[400px]">
        <!-- Loading State -->
        <div v-if="loading" class="flex flex-col items-center justify-center py-20 gap-3">
          <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-emerald-600"></div>
          <p class="text-slate-500 text-sm animate-pulse">Memuat data versi...</p>
        </div>

        <div v-else class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 dark:bg-[#1a1a1a]/50 border-b border-slate-200 dark:border-gray-800">
                <th class="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">No</th>
                <th class="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Versi</th>
                <th class="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Tanggal Rilis</th>
                <th class="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Modul</th>
                <th class="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Jenis</th>
                <th class="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Deskripsi</th>
                <th class="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">PIC</th>
                <th class="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">Status</th>
                <th class="px-6 py-4 text-[10px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 dark:divide-gray-800 text-sm">
              <tr v-if="filteredVersions.length === 0">
                <td colspan="9" class="px-6 py-12 text-center text-slate-400 italic">Data versi tidak ditemukan.</td>
              </tr>
              <tr v-for="(v, index) in filteredVersions" :key="v.id" 
                @click="navigateTo('detail', v)"
                class="group hover:bg-slate-50 dark:hover:bg-[#1a1a1a]/50 transition-colors cursor-pointer"
              >
                <td class="px-6 py-5 text-slate-500 dark:text-slate-400">{{ index + 1 }}</td>
                <td class="px-6 py-5">
                  <span class="inline-flex items-center gap-1.5 border border-blue-500/30 bg-blue-50 text-blue-600 dark:bg-blue-900/20 dark:text-blue-400 text-[11px] font-bold px-2.5 py-1 rounded-full">
                    {{ v.version }}
                  </span>
                </td>
                <td class="px-6 py-5 text-slate-900 dark:text-slate-200 whitespace-nowrap">{{ v.date }}</td>
                <td class="px-6 py-5 font-bold text-slate-900 dark:text-slate-200">{{ v.module }}</td>
                <td class="px-6 py-5">
                  <span :class="getTypeBadgeClass(v.type)" class="inline-flex items-center gap-1.5 border text-[10px] font-bold px-2.5 py-1 rounded-full uppercase tracking-wide">
                    <span :class="getTypeIconClass(v.type)" class="size-1.5 rounded-full"></span>
                    {{ v.type }}
                  </span>
                </td>
                <td class="px-6 py-5 text-slate-600 dark:text-slate-400 text-sm max-w-[200px]">
                  <div class="font-medium text-slate-900 dark:text-white truncate" :title="v.description">{{ v.description }}</div>
                  <div class="text-[11px] truncate mt-0.5" :title="v.raw.details">{{ v.raw.details }}</div>
                </td>
                <td class="px-6 py-5 text-slate-900 dark:text-slate-200">{{ v.pic }}</td>
                <td class="px-6 py-5">
                  <span :class="getStatusBadgeClass(v.status)" class="px-2 py-1 text-[10px] font-bold rounded border uppercase tracking-wider">
                    {{ v.status }}
                  </span>
                </td>
                <td class="px-6 py-5 text-right">
                  <div v-if="['Super Admin', 'Admin', 'Editor'].includes(authStore.user?.role)" class="flex items-center justify-end gap-2">
                    <button 
                      @click.stop="openModal(v)"
                      class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-lg transition-all" title="Edit"
                    >
                      <span class="material-symbols-outlined text-[20px]">edit</span>
                    </button>
                    <button 
                      @click.stop="deleteVersion(v.id)"
                      class="p-2 text-slate-400 hover:text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-900/20 rounded-lg transition-all" title="Hapus"
                    >
                      <span class="material-symbols-outlined text-[20px]">delete</span>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Detail View (Matching Logs.vue Style) -->
    <div v-else-if="currentView === 'detail' && selectedVersion" class="max-w-5xl mx-auto space-y-6 animate-in slide-in-from-right-4 duration-300">
      <div class="flex items-center justify-between">
        <button 
          @click="navigateTo('list')"
          class="flex items-center gap-2 text-sm text-gray-500 hover:text-emerald-600 transition-colors group"
        >
          <span class="material-symbols-outlined text-sm group-hover:-translate-x-1 transition-transform">arrow_back</span>
          <span>Kembali ke Daftar</span>
        </button>
        <div v-if="['Super Admin', 'Admin', 'Editor'].includes(authStore.user?.role)" class="flex gap-2">
          <button 
            @click="openModal(selectedVersion)"
            class="flex items-center gap-2 px-4 py-2 bg-white dark:bg-[#1e1e1e] border border-gray-200 dark:border-gray-800 rounded-lg text-sm font-bold text-slate-700 dark:text-slate-200 hover:bg-gray-50 dark:hover:bg-[#252525] transition-all shadow-sm"
          >
            <span class="material-symbols-outlined text-[18px]">edit</span>
            <span>Edit Versi</span>
          </button>
        </div>
      </div>

      <!-- Header Card -->
      <div class="bg-white dark:bg-[#141414] rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm overflow-hidden">
        <div class="bg-slate-50 dark:bg-[#1a1a1a]/50 px-6 py-4 border-b border-slate-200 dark:border-gray-800 flex flex-wrap items-center gap-4">
          <div class="flex items-center gap-3 mr-auto">
            <span class="inline-flex items-center px-3 py-1 rounded-full bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 text-sm font-bold border border-blue-500/20">
              {{ selectedVersion.version }}
            </span>
            <h2 class="text-xl font-bold text-slate-900 dark:text-white">{{ selectedVersion.description }}</h2>
          </div>
          <span :class="getStatusBadgeClass(selectedVersion.status)" class="px-3 py-1 rounded-full text-[10px] font-bold uppercase border tracking-wider">
            {{ selectedVersion.status }}
          </span>
        </div>

        <div class="p-6 grid grid-cols-1 md:grid-cols-4 gap-6 border-b border-slate-100 dark:border-gray-800">
          <div class="space-y-1">
            <p class="text-[10px] uppercase tracking-widest text-slate-500 font-bold">Modul / Area</p>
            <p class="text-sm font-semibold text-slate-900 dark:text-white">{{ selectedVersion.module }}</p>
          </div>
          <div class="space-y-1">
            <p class="text-[10px] uppercase tracking-widest text-slate-500 font-bold">Tanggal Rilis</p>
            <p class="text-sm font-semibold text-slate-900 dark:text-white">{{ selectedVersion.date }}</p>
          </div>
          <div class="space-y-1">
            <p class="text-[10px] uppercase tracking-widest text-slate-500 font-bold">Jenis Perubahan</p>
            <div class="flex items-center gap-2">
              <span :class="getTypeIconClass(selectedVersion.type)" class="size-2 rounded-full"></span>
              <p class="text-sm font-semibold text-slate-900 dark:text-white">{{ selectedVersion.type }}</p>
            </div>
          </div>
          <div class="space-y-1">
            <p class="text-[10px] uppercase tracking-widest text-slate-500 font-bold">PIC</p>
            <div class="flex items-center gap-2">
              <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center text-[10px] font-bold text-emerald-600">
                {{ selectedVersion.pic?.charAt(0) }}
              </div>
              <p class="text-sm font-semibold text-slate-900 dark:text-white">{{ selectedVersion.pic }}</p>
            </div>
          </div>
        </div>

        <div class="p-6 space-y-6">
          <div class="space-y-3">
            <h4 class="text-xs font-bold text-slate-500 uppercase tracking-widest flex items-center gap-2">
              <span class="material-symbols-outlined text-sm">description</span>
              Detail Perubahan
            </h4>
            <div class="p-4 bg-slate-50 dark:bg-[#1a1a1a] rounded-lg border border-slate-100 dark:border-gray-800">
              <p class="text-sm text-slate-700 dark:text-slate-300 leading-relaxed whitespace-pre-wrap">{{ selectedVersion.raw.details || 'Tidak ada detail tambahan.' }}</p>
            </div>
          </div>

          <div v-if="selectedVersion.notes" class="space-y-3">
            <h4 class="text-xs font-bold text-slate-500 uppercase tracking-widest flex items-center gap-2">
              <span class="material-symbols-outlined text-sm">sticky_note_2</span>
              Catatan Internal
            </h4>
            <div class="p-4 bg-amber-50/50 dark:bg-amber-900/10 rounded-lg border border-amber-100 dark:border-amber-900/20">
              <p class="text-sm text-slate-700 dark:text-slate-300 italic">{{ selectedVersion.notes }}</p>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Forum & Activity Area (Matching Logs.vue) -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2 space-y-4">
          <div class="flex items-center gap-2 mb-2">
            <h3 class="text-lg font-bold text-black dark:text-white">Forum Diskusi</h3>
            <span class="px-2 py-0.5 bg-gray-200 dark:bg-gray-700 rounded-md text-[10px] font-bold text-black dark:text-gray-300">
              0 Pesan
            </span>
          </div>

          <div class="bg-white dark:bg-[#141414] p-8 rounded-xl border border-slate-200 dark:border-gray-800 flex flex-col items-center justify-center text-center space-y-3 min-h-[200px] opacity-60">
            <span class="material-symbols-outlined text-4xl text-slate-300">forum</span>
            <p class="text-slate-500 text-sm font-medium">Forum diskusi untuk versi ini akan segera tersedia.</p>
            <p class="text-slate-400 text-[11px]">Anda dapat berdiskusi mengenai implementasi fitur ini di sini nantinya.</p>
          </div>
        </div>

        <div class="space-y-4">
          <h3 class="text-lg font-bold text-black dark:text-white flex items-center gap-2">
            <span class="material-symbols-outlined text-sm">history</span>
            Riwayat Aktivitas
          </h3>
          <div class="bg-white dark:bg-[#141414] p-8 rounded-xl border border-slate-200 dark:border-gray-800 flex flex-col items-center justify-center text-center space-y-3 opacity-60">
            <span class="material-symbols-outlined text-4xl text-slate-300">history</span>
            <p class="text-slate-500 text-sm font-medium">Belum ada riwayat aktivitas.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Form -->
    <div v-if="showModal" class="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
      <div class="bg-white dark:bg-[#141414] w-full max-w-lg rounded-2xl shadow-2xl border border-slate-200 dark:border-gray-800 overflow-hidden animate-in zoom-in duration-200">
        <div class="px-6 py-4 border-b border-slate-100 dark:border-gray-800 flex items-center justify-between bg-slate-50 dark:bg-[#1a1a1a]/50">
          <h4 class="font-bold text-slate-800 dark:text-white">{{ isEditing ? 'Edit Versi' : 'Tambah Versi Baru' }}</h4>
          <button @click="showModal = false" class="text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>
        
        <div class="p-6 space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">Nomor Versi</label>
              <input v-model="form.version_number" type="text" placeholder="e.g. v1.0.2" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none" />
            </div>
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">Tanggal Rilis</label>
              <input v-model="form.release_date" type="text" placeholder="e.g. 2026-02-15 atau Menunggu PM" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none" />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">Judul / Fitur Utama</label>
              <input v-model="form.title" type="text" placeholder="Apa yang baru?" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none" />
            </div>
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">PIC (Penanggung Jawab)</label>
              <input v-model="form.pic_name" type="text" placeholder="e.g. Adi" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none" />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">Modul Terkait</label>
              <select v-model="form.component_id" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none">
                <option value="">Umum / Sidebar</option>
                <option v-for="c in componentList" :key="c.id" :value="c.id">{{ c.name }}</option>
              </select>
            </div>
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">Jenis Perubahan</label>
              <select v-model="form.change_type" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none">
                <option value="New Feature">New Feature</option>
                <option value="Improvement">Improvement</option>
                <option value="Bug Fix">Bug Fix</option>
                <option value="Refactor">Refactor</option>
                <option value="Maintenance">Maintenance</option>
              </select>
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">Status</label>
              <select v-model="form.status" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none">
                <option value="Pending QA">Pending QA</option>
                <option value="In Progress">In Progress</option>
                <option value="Done">Done</option>
                <option value="Rejected">Rejected</option>
              </select>
            </div>
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">Catatan</label>
              <input v-model="form.notes" type="text" placeholder="-" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none" />
            </div>
          </div>

          <div class="space-y-1.5">
            <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">Detail Lengkap Perubahan</label>
            <textarea v-model="form.details" rows="2" placeholder="Jelaskan detail perubahan secara mendalam..." class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none resize-none"></textarea>
          </div>
        </div>

        <div class="px-6 py-4 border-t border-slate-100 dark:border-gray-800 flex items-center justify-end gap-3 bg-slate-50 dark:bg-[#1a1a1a]/50">
          <button @click="showModal = false" class="px-4 py-2 text-sm font-bold text-slate-600 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-colors">Batal</button>
          <button 
            @click="saveVersion"
            :disabled="modalLoading"
            class="px-6 py-2 text-sm font-bold text-white bg-emerald-600 rounded-lg hover:bg-emerald-700 transition-all disabled:opacity-50 flex items-center gap-2"
          >
            <span v-if="modalLoading" class="animate-spin size-4 border-2 border-white/30 border-t-white rounded-full"></span>
            {{ isEditing ? 'Update Versi' : 'Simpan Versi' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
