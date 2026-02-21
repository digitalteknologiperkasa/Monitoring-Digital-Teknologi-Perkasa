<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import axios from '../lib/axios'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const route = useRoute()
const loading = ref(true)
const requests = ref([])
const stats = ref({
  total: 0,
  reviewing: 0,
  approved: 0,
  rejected: 0
})

// Modal & Form State
const showAddModal = ref(false)
const showDetailModal = ref(false)
const showRejectionModal = ref(false)
const rejectionReason = ref('')
const modalLoading = ref(false)
const selectedRequest = ref(null)
const openDropdownId = ref(null)

const toggleDropdown = (id) => {
  openDropdownId.value = openDropdownId.value === id ? null : id
}
const projects = ref([])
const components = ref([])
const allProfiles = ref([]) // Untuk pilihan pelapor
const modalFile = ref(null)
const modalFileInput = ref(null)

const form = ref({
  project_id: '',
  component_id: '',
  reporter_id: '', // Field pelapor baru
  judul_request: '',
  kategori_dev: 'Fitur Baru',
  status_perwakilan: 'Inisiatif Sendiri',
  kode_pesantren: '',
  unit_yayasan: '',
  kategori_modul: '',
  deskripsi_masukan: '',
  masalah: '',
  usulan: '',
  dampak: '',
  urgensi: 'Medium',
  attachment_wa: '',
  attachment_lain: ''
})

// Search state
const searchQuery = ref('')
const statusOrder = {
  'Baru': 1,
  'Sedang Ditinjau': 2,
  'Sedang Dipertimbangkan': 3,
  'Sedang Dikembangkan': 4,
  'Selesai': 5,
  'Ditolak': 6
}
const availableStatuses = Object.keys(statusOrder)

const filteredRequests = computed(() => {
  let result = [...requests.value]
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(req => 
      req.judul_request?.toLowerCase().includes(query) ||
      req.unit_yayasan?.toLowerCase().includes(query) ||
      req.reporter?.full_name?.toLowerCase().includes(query)
    )
  }

  // Sort by status order
  return result.sort((a, b) => {
    const orderA = statusOrder[a.status_lifecycle] || 99
    const orderB = statusOrder[b.status_lifecycle] || 99
    if (orderA !== orderB) return orderA - orderB
    return new Date(b.created_at) - new Date(a.created_at) // Sub-sort by newest
  })
})

const allAttachments = computed(() => {
  const list = []
  if (!selectedRequest.value) return list

  if (selectedRequest.value.attachment_wa) {
    list.push({
      name: 'Link Lampiran (Utama)',
      url: selectedRequest.value.attachment_wa,
      type: 'link'
    })
  }
  if (selectedRequest.value.attachment_lain) {
    list.push({
      name: 'Lampiran Tambahan',
      url: selectedRequest.value.attachment_lain,
      type: 'file'
    })
  }

  // Tambahkan lampiran dari komentar
  comments.value.forEach((c, index) => {
    if (c.attachment_url) {
      list.push({
        name: `Lampiran Diskusi #${index + 1}`,
        url: c.attachment_url,
        type: 'file',
        user: c.user?.full_name
      })
    }
  })

  return list
})

// Chat / Discussion Forum State
const comments = ref([])
const newComment = ref('')
const commentLoading = ref(false)
const selectedFile = ref(null)
const fileInput = ref(null)

const triggerFileInput = () => {
  fileInput.value?.click()
}

const handleFileChange = (e) => {
  const file = e.target.files[0]
  if (file) {
    selectedFile.value = file
  }
}

const removeFile = () => {
  selectedFile.value = null
  if (fileInput.value) fileInput.value.value = ''
}

const fetchComments = async (requestId) => {
  try {
    const { data } = await axios.get(`/discussion_forum?parent_id=eq.${requestId}&parent_type=eq.FEATURE&select=*,user:profiles(full_name,avatar_url,role)&order=created_at.asc`)
    comments.value = data || []
  } catch (error) {
    console.error('Error fetching comments:', error)
  }
}

const uploadAttachment = async (file) => {
  try {
    const fileExt = file.name.split('.').pop()
    const fileName = `${Math.random()}.${fileExt}`
    const filePath = `forum/${fileName}`

    const { error: uploadError } = await supabase.storage
      .from('forum-attachments')
      .upload(filePath, file)

    if (uploadError) throw uploadError

    const { data } = supabase.storage
      .from('forum-attachments')
      .getPublicUrl(filePath)

    return data.publicUrl
  } catch (error) {
    console.error('Error uploading file:', error)
    return null
  }
}

const sendComment = async () => {
  if ((!newComment.value.trim() && !selectedFile.value) || !selectedRequest.value || !authStore.user) return
  
  commentLoading.value = true
  try {
    let attachmentUrl = null
    if (selectedFile.value) {
      attachmentUrl = await uploadAttachment(selectedFile.value)
    }

    await axios.post('/discussion_forum', {
      parent_id: selectedRequest.value.id,
      parent_type: 'FEATURE',
      user_id: authStore.user.id,
      comment_text: newComment.value.trim(),
      attachment_url: attachmentUrl,
      created_at: new Date().toISOString()
    })
    
    newComment.value = ''
    selectedFile.value = null
    if (fileInput.value) fileInput.value.value = ''
    await fetchComments(selectedRequest.value.id)
  } catch (error) {
    console.error('Error sending comment:', error)
    alert('Gagal mengirim komentar: ' + error.message)
  } finally {
    commentLoading.value = false
  }
}

const openDetail = async (req) => {
  selectedRequest.value = req
  showDetailModal.value = true
  await fetchComments(req.id)
}

const fetchProfiles = async () => {
  try {
    const role = (authStore.user?.role || 'Viewer').toString()
    const isSuperAdmin = ['Super Admin', 'Admin'].includes(role)
    const currentUserId = authStore.user?.id
    const projectId = form.value.project_id || authStore.user?.project_id || 1
    
    let url = '/profiles?select=id,full_name,avatar_url,project_id,email'
    
    if (projectId) {
      // Strict filtering
      url += `&project_id=eq.${projectId}`
    }
    
    const response = await axios.get(url)
    const data = Array.isArray(response.data) ? response.data : []
    
    if (currentUserId && !data.find(p => p.id === currentUserId)) {
      data.unshift({
        id: currentUserId,
        full_name: authStore.user?.full_name || authStore.user?.email || 'Saya',
        avatar_url: authStore.user?.avatar_url,
        email: authStore.user?.email
      })
    }
    
    allProfiles.value = data
    
    if (!form.value.reporter_id && currentUserId) {
      form.value.reporter_id = currentUserId
    }
  } catch (error) {
    console.error('Error fetching profiles:', error)
    if (authStore.user?.id) {
      allProfiles.value = [{
        id: authStore.user.id,
        full_name: authStore.user.email || 'Saya'
      }]
      form.value.reporter_id = authStore.user.id
    }
  }
}

// Data Fetching
const fetchInitialData = async () => {
  try {
    const isSuperAdmin = ['Super Admin', 'Admin'].includes(authStore.user?.role)
    const projectId = authStore.user?.project_id || 1
    
    let projUrl = '/projects?select=id,name'
    let compUrl = '/app_components?select=id,name'
    
    // Strict filtering: Always filter by project_id regardless of role
    projUrl += `&id=eq.${projectId}`
    compUrl += `&project_id=eq.${projectId}`

    const [projRes, compRes] = await Promise.all([
      axios.get(projUrl),
      axios.get(compUrl)
    ])
    
    console.log('Initial data fetched:', { projects: projRes.data, components: compRes.data })
    
    projects.value = projRes.data || []
    components.value = compRes.data || []
    
    if (projects.value.length > 0) {
      // Jika admin, pilih project pertama dari list, jika bukan pilih project user
      const defaultProj = isSuperAdmin ? projects.value[0] : projects.value.find(p => p.id === projectId)
      form.value.project_id = defaultProj?.id || projects.value[0].id
    }
    if (components.value.length > 0) form.value.component_id = components.value[0].id
  } catch (error) {
    console.error('Error fetching initial data:', error)
  }
}

const fetchRequests = async () => {
  loading.value = true
  try {
    const isSuperAdmin = ['Super Admin', 'Admin'].includes(authStore.user?.role)
    const projectId = authStore.user?.project_id || 1
    
    let url = '/feature_requests?select=*,reporter:profiles(full_name,avatar_url),component:app_components(name),project:projects(name)&order=created_at.desc'
    
    // Strict filtering: Always filter by project_id regardless of role
    url += `&project_id=eq.${projectId}`

    const { data } = await axios.get(url)
    console.log('Requests fetched via axios:', data)
    requests.value = data || []
    
    // Calculate stats
    stats.value = {
      total: requests.value.length,
      reviewing: requests.value.filter(r => r.status_lifecycle === 'Sedang Ditinjau').length,
      approved: requests.value.filter(r => ['Sedang Dikembangkan', 'Selesai'].includes(r.status_lifecycle)).length,
      rejected: requests.value.filter(r => r.status_lifecycle === 'Ditolak').length
    }
  } catch (error) {
    console.error('Error fetching requests:', error)
  } finally {
    loading.value = false
  }
}

const saveRequest = async () => {
  if (modalLoading.value) return
  if (!authStore.user) {
    alert('Anda harus login untuk mengirim request.')
    return
  }

  modalLoading.value = true
  try {
    // Upload file if selected
    let fileUrl = null
    if (modalFile.value) {
      fileUrl = await uploadAttachment(modalFile.value)
    }

    // 1. Ambil data dari form dan bersihkan (konversi empty string ke null)
    const f = form.value
    
    // 2. Konstruksi payload secara eksplisit sesuai kolom database
    const payload = {
      project_id: Number(authStore.user?.project_id || f.project_id || 1),
      reporter_id: f.reporter_id || authStore.user.id,
      component_id: f.component_id || null,
      status_perwakilan: f.status_perwakilan,
      kode_pesantren: f.status_perwakilan === 'Inisiatif Sendiri' ? null : (f.kode_pesantren || null),
      unit_yayasan: f.unit_yayasan || null,
      kategori_modul: f.kategori_modul || null,
      judul_request: f.judul_request,
      kategori_dev: f.kategori_dev,
      deskripsi_masukan: f.deskripsi_masukan || null,
      masalah: f.masalah || null,
      usulan: f.usulan || null,
      dampak: f.dampak || null,
      urgensi: f.urgensi || 'Medium',
      attachment_wa: f.attachment_wa || null,
      attachment_lain: fileUrl || f.attachment_lain || null,
      status_lifecycle: 'Baru'
    }

    console.log('Sending feature request explicit payload via axios:', payload)

    // 3. Eksekusi insert menggunakan RPC (Stored Procedure) untuk bypass potensi masalah RLS
    console.log('Attempting insert via RPC submit_feature_request...')
    
    // Siapkan parameter untuk RPC
    const rpcParams = {
      p_project_id: payload.project_id,
      p_component_id: payload.component_id,
      p_reporter_id: payload.reporter_id,
      p_judul_request: payload.judul_request,
      p_kategori_dev: payload.kategori_dev,
      p_deskripsi_masukan: payload.deskripsi_masukan,
      p_urgensi: payload.urgensi,
      p_status_perwakilan: payload.status_perwakilan,
      p_kode_pesantren: payload.kode_pesantren,
      p_unit_yayasan: payload.unit_yayasan,
      p_kategori_modul: payload.kategori_modul,
      p_masalah: payload.masalah,
      p_usulan: payload.usulan,
      p_dampak: payload.dampak,
      p_attachment_wa: payload.attachment_wa,
      p_attachment_lain: payload.attachment_lain
    }

    const insertPromise = supabase
      .rpc('submit_feature_request', rpcParams)

    // Timeout 15 detik
    const timeoutPromise = new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Force Timeout 15s: RPC request hung')), 15000)
    )

    const { data, error } = await Promise.race([insertPromise, timeoutPromise])

    if (error) {
      console.error('RPC Error:', error)
      // Fallback ke insert biasa jika RPC gagal (misal fungsi belum dibuat)
      console.log('RPC failed, falling back to direct insert...')
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('feature_requests')
        .insert(payload)
        .select()
        .single()
        
      if (fallbackError) throw fallbackError
      console.log('Fallback Insert success:', fallbackData)
    } else {
      console.log('RPC Insert success:', data)
    }

    // Reset loading state
    modalLoading.value = false
    showAddModal.value = false
    resetForm()
    
    fetchRequests()
    
    alert('Request fitur berhasil dikirim!')
  } catch (error) {
    console.error('Final catch error saving request:', error)
    modalLoading.value = false
    
    let errorMsg = 'Terjadi kesalahan pada server database'
    
    if (error.message?.includes('Timeout')) {
      errorMsg = 'Request timed out. Mohon jalankan script SQL "fix_feature_insert_rpc.sql" di Supabase Dashboard.'
    } else if (error.message) {
      errorMsg = error.message
    } else if (error.details) {
      errorMsg = error.details
    }
    
    alert('Gagal menyimpan request: ' + errorMsg)
  } finally {
    modalLoading.value = false
  }
}

const updateStatus = async (id, newStatus) => {
  if (!['Super Admin', 'Admin', 'Editor'].includes(authStore.user?.role)) {
    alert('Anda tidak memiliki izin untuk mengubah status.')
    return
  }
  if (newStatus === 'Ditolak' && !showRejectionModal.value) {
    showRejectionModal.value = true
    openDropdownId.value = null // Close dropdown when opening rejection modal
    return
  }

  try {
    const updateData = { 
      status_lifecycle: newStatus, 
      updated_at: new Date().toISOString() 
    }

    if (newStatus === 'Ditolak') {
      updateData.alasan_penolakan = rejectionReason.value
    }

    const config = { timeout: 10000 }
    await axios.patch(`/feature_requests?id=eq.${id}`, updateData, config)
    
    // Reset rejection state
    if (newStatus === 'Ditolak') {
      showRejectionModal.value = false
      rejectionReason.value = ''
    }

    // If approved or being developed, promote to backlog
    if (['Sedang Dipertimbangkan', 'Sedang Dikembangkan'].includes(newStatus)) {
      await promoteToBacklog(id)
    }

    // If finished, sync with backlog if exists
    if (newStatus === 'Selesai') {
      await syncBacklogFinish(id)
    }

    await fetchRequests()
    if (selectedRequest.value?.id === id) {
      const updatedReq = requests.value.find(r => r.id === id)
      if (updatedReq) selectedRequest.value = updatedReq
    }
    openDropdownId.value = null
    alert(`Status berhasil diperbarui ke ${newStatus}`)
  } catch (error) {
    console.error('Error updating status:', error)
    const msg = error.code === 'ECONNABORTED' ? 'Request timed out (Check RLS policies)' : (error.response?.data?.message || error.message);
    alert('Gagal memperbarui status: ' + msg)
  }
}

const promoteToBacklog = async (requestId) => {
  try {
    const req = requests.value.find(r => r.id === requestId)
    if (!req) return

    // Check if already in backlog
    const { data: existing } = await axios.get(`/feature_backlog?discussion_reference=eq.${requestId}&select=id`)
    
    if (existing && existing.length > 0) return

    const backlogPayload = {
      project_id: req.project_id,
      feature_name: req.judul_request,
      functionality: req.deskripsi_masukan,
      urgency: req.urgensi,
      discussion_reference: requestId.toString(),
      stage: 'Backlog',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }

    const config = { timeout: 10000 }
    await axios.post('/feature_backlog', backlogPayload, config)
  } catch (error) {
    console.error('Error promoting to backlog:', error)
  }
}

const syncBacklogFinish = async (requestId) => {
  try {
    const config = { timeout: 10000 }
    await axios.patch(`/feature_backlog?discussion_reference=eq.${requestId}`, { 
      stage: 'Launched',
      updated_at: new Date().toISOString()
    }, config)
  } catch (error) {
    console.error('Error syncing backlog finish:', error)
  }
}

const deleteRequest = async (id) => {
  if (!['Super Admin', 'Admin', 'Editor'].includes(authStore.user?.role)) {
    alert('Anda tidak memiliki izin untuk menghapus data.')
    return
  }
  if (!confirm('Apakah Anda yakin ingin menghapus pengajuan ini?')) return
  
  try {
    const config = { timeout: 10000 }
    await axios.delete(`/feature_requests?id=eq.${id}`, config)
    
    await fetchRequests()
    showDetailModal.value = false
    alert('Pengajuan berhasil dihapus')
  } catch (error) {
    console.error('Error deleting request:', error)
    const msg = error.code === 'ECONNABORTED' ? 'Request timed out (Check RLS policies)' : (error.response?.data?.message || error.message);
    alert('Gagal menghapus: ' + msg)
  }
}

const resetForm = () => {
  form.value = {
    project_id: projects.value[0]?.id || '',
    component_id: components.value[0]?.id || '',
    reporter_id: authStore.user?.id || '',
    judul_request: '',
    kategori_dev: 'Fitur Baru',
    status_perwakilan: 'Inisiatif Sendiri',
    kode_pesantren: '',
    unit_yayasan: '',
    kategori_modul: '',
    deskripsi_masukan: '',
    masalah: '',
    usulan: '',
    dampak: '',
    urgensi: 'Medium',
    attachment_wa: '',
    attachment_lain: ''
  }
}

const getStatusClass = (status) => {
  switch (status) {
    case 'Baru': return 'bg-gray-600/10 text-gray-600 dark:bg-gray-400/10 dark:text-gray-400 border-gray-600/20 dark:border-gray-400/20'
    case 'Sedang Ditinjau': return 'bg-blue-500/10 text-blue-400 border-blue-400/20'
    case 'Sedang Dipertimbangkan': return 'bg-amber-500/10 text-amber-400 border-amber-400/20'
    case 'Sedang Dikembangkan': return 'bg-emerald-500/10 text-emerald-400 border-emerald-400/20'
    case 'Selesai': return 'bg-purple-500/10 text-purple-400 border-purple-400/20'
    case 'Ditolak': return 'bg-red-500/10 text-red-400 border-red-400/20'
    default: return 'bg-white/5 text-white/40 border-white/10'
  }
}

const getUrgencyClass = (urgency) => {
  const p = urgency?.toLowerCase()
  switch (p) {
    case 'low': return 'bg-yellow-50 text-yellow-600 dark:bg-yellow-900/10 dark:text-yellow-500 border-yellow-200/50'
    case 'medium': return 'bg-orange-100 text-orange-700 dark:bg-orange-900/20 dark:text-orange-400 border-orange-200/50'
    case 'high': return 'bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400 border-red-200/50'
    case 'critical': return 'bg-red-600 text-white dark:bg-red-700 dark:text-red-50 border-red-500'
    default: return 'bg-gray-50 text-gray-600 border-gray-200/50'
  }
}

const getUrgencyText = (urgency) => {
  switch (urgency) {
    case 'Critical': return 'text-white'
    case 'High': return 'text-red-700 dark:text-red-400'
    case 'Medium': return 'text-orange-700 dark:text-orange-400'
    case 'Low': return 'text-yellow-600 dark:text-yellow-500'
    default: return 'text-white/40'
  }
}

const getUrgencyBg = (urgency) => {
  switch (urgency) {
    case 'Critical': return 'bg-red-600 dark:bg-red-700'
    case 'High': return 'bg-red-100 dark:bg-red-900/20'
    case 'Medium': return 'bg-orange-100 dark:bg-orange-900/20'
    case 'Low': return 'bg-yellow-50 dark:bg-yellow-900/10'
    default: return 'bg-white/5'
  }
}

const getUrgencyBorder = (urgency) => {
  switch (urgency) {
    case 'Critical': return 'border-red-500'
    case 'High': return 'border-red-200/50 dark:border-red-800/50'
    case 'Medium': return 'border-orange-200/50 dark:border-orange-800/50'
    case 'Low': return 'border-yellow-200/50 dark:border-yellow-800/50'
    default: return 'border-white/5'
  }
}

const statsCards = computed(() => ({
  'Total Pengajuan': stats.value.total,
  'Dalam Peninjauan': stats.value.reviewing,
  'Disetujui/Dev': stats.value.approved,
  'Ditolak/Arsip': stats.value.rejected
}))

onMounted(async () => {
  await fetchInitialData()
  await fetchProfiles()
  await fetchRequests()

  // Check for detailId query param
  if (route.query.detailId) {
    const reqId = parseInt(route.query.detailId)
    const req = requests.value.find(r => r.id === reqId)
    if (req) {
      openDetail(req)
    } else {
      // Try to fetch specific request if not found in current list
      try {
        const { data } = await axios.get(`/feature_requests?id=eq.${reqId}&select=*,reporter:profiles(full_name,avatar_url),component:app_components(name),project:projects(name)`)
        if (data && data.length > 0) {
          openDetail(data[0])
        }
      } catch (e) {
        console.error('Error fetching specific feature request details:', e)
      }
    }
  }
})

watch(() => form.value.project_id, () => {
  fetchProfiles()
})
</script>

<template>
  <div class="max-w-[1600px] mx-auto space-y-6">
    <!-- Header Section -->
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-white dark:bg-[#141414] p-6 rounded-2xl border border-slate-200 dark:border-gray-800 shadow-sm">
      <div class="flex flex-col">
        <h2 class="text-2xl font-black text-slate-800 dark:text-white leading-tight">Manajemen Penambahan Fitur</h2>
        <p class="text-xs text-slate-500 dark:text-slate-400 mt-1 font-medium">Pesantren Smart Digital • Roadmap System & Feature Requests</p>
      </div>
          <div class="flex items-center gap-4">
            <div class="relative w-64 md:w-80">
              <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-500 text-lg">search</span>
              <input 
                v-model="searchQuery"
                class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl py-2 pl-10 pr-4 text-sm text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-slate-500 focus:ring-2 focus:ring-accent-emerald focus:border-transparent transition-all outline-none" 
                placeholder="Cari judul, unit, atau pelapor..." 
                type="text"
              />
            </div>
            <button 
              v-if="['Super Admin', 'Admin', 'Editor'].includes(authStore.user?.role)"
              @click="showAddModal = true"
              class="bg-emerald-600 hover:bg-emerald-500 dark:bg-emerald-400 dark:hover:bg-emerald-300 text-white dark:text-[#032A28] px-5 py-2.5 rounded-xl text-sm font-bold transition-all flex items-center gap-2 shadow-lg shadow-emerald-600/20 active:scale-95"
            >
              <span class="material-symbols-outlined text-lg">add_circle</span>
              Ajukan Fitur
            </button>
          </div>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <div v-for="(val, label) in statsCards" :key="label"
        class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 rounded-2xl p-5 shadow-sm group hover:border-accent-emerald/50 transition-all"
      >
        <div class="flex justify-between items-start mb-2">
          <span class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider">{{ label }}</span>
          <div class="p-2 bg-slate-50 dark:bg-[#1a1a1a] rounded-lg group-hover:bg-accent-emerald/10 transition-colors">
            <span class="material-symbols-outlined text-slate-400 group-hover:text-accent-emerald transition-colors text-xl">analytics</span>
          </div>
        </div>
        <h4 class="text-3xl font-black text-slate-800 dark:text-white">{{ val }}</h4>
      </div>
    </div>

    <!-- Data Table Section -->
    <div class="bg-white dark:bg-[#141414] border border-slate-200 dark:border-gray-800 rounded-2xl shadow-sm overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-slate-50 dark:bg-[#1a1a1a] border-b border-slate-200 dark:border-gray-800">
              <th class="px-6 py-4 text-[10px] font-black text-slate-500 dark:text-white uppercase tracking-widest">Fitur & Modul</th>
              <th class="px-6 py-4 text-[10px] font-black text-slate-500 dark:text-white uppercase tracking-widest">Pelapor</th>
              <th class="px-6 py-4 text-[10px] font-black text-slate-500 dark:text-white uppercase tracking-widest text-center">Urgensi</th>
              <th class="px-6 py-4 text-[10px] font-black text-slate-500 dark:text-white uppercase tracking-widest text-center">Status</th>
              <th class="px-6 py-4 text-[10px] font-black text-slate-500 dark:text-white uppercase tracking-widest text-right">Aksi</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100 dark:divide-gray-800">
            <tr v-if="loading" class="animate-pulse">
              <td colspan="5" class="px-6 py-12 text-center text-slate-400 dark:text-slate-500 italic text-sm">Memuat data pengajuan...</td>
            </tr>
            <tr v-else-if="filteredRequests.length === 0" class="hover:bg-slate-50 dark:hover:bg-[#1a1a1a]/30 transition-colors">
              <td colspan="5" class="px-6 py-16 text-center">
                <div class="flex flex-col items-center gap-3">
                  <div class="p-4 bg-slate-50 dark:bg-[#1a1a1a] rounded-full">
                    <span class="material-symbols-outlined text-5xl text-slate-200 dark:text-slate-700">inventory_2</span>
                  </div>
                  <p class="text-slate-400 dark:text-slate-500 text-sm font-medium">Tidak ada data pengajuan fitur ditemukan</p>
                </div>
              </td>
            </tr>
            <tr 
              v-for="req in filteredRequests" 
              :key="req.id" 
              @click="openDetail(req)"
              class="group hover:bg-slate-50 dark:hover:bg-[#1a1a1a]/40 transition-all cursor-pointer"
            >
              <td class="px-6 py-5">
                <div class="flex items-center gap-4">
                  <div class="w-1.5 h-8 rounded-full" :class="getUrgencyClass(req.urgensi)"></div>
                  <div>
                    <div class="text-sm font-bold text-slate-800 dark:text-white group-hover:text-accent-emerald transition-colors leading-tight">{{ req.judul_request }}</div>
                    <div class="text-[10px] text-slate-500 dark:text-slate-500 font-bold mt-1 uppercase tracking-wider">{{ req.project?.name }} • {{ req.kategori_modul }}</div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-5">
                <div class="flex items-center gap-3">
                  <img :src="req.reporter?.avatar_url || 'https://ui-avatars.com/api/?name=' + req.reporter?.full_name" class="w-9 h-9 rounded-full border-2 border-white dark:border-gray-800 shadow-sm" alt="Avatar">
                  <div class="flex flex-col">
                    <span class="text-xs font-bold text-slate-700 dark:text-slate-200">{{ req.reporter?.full_name }}</span>
                    <span class="text-[10px] text-slate-500 dark:text-slate-500 font-medium">{{ req.unit_yayasan }}</span>
                  </div>
                </div>
              </td>
              <td class="px-6 py-5 text-center">
                <span 
                  class="text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-tight border shadow-sm transition-all"
                  :class="getUrgencyClass(req.urgensi)"
                >
                  {{ req.urgensi }}
                </span>
              </td>
              <td class="px-6 py-5 text-center relative status-dropdown-container">
                <div class="flex items-center justify-center gap-2">
                  <span class="status-badge shadow-sm" :class="getStatusClass(req.status_lifecycle)">
                    {{ req.status_lifecycle }}
                  </span>
                  <button 
                    v-if="['Super Admin', 'Admin', 'Editor'].includes(authStore.user?.role)"
                    @click.stop="toggleDropdown(req.id)"
                    class="p-1 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 transition-colors"
                  >
                    <span class="material-symbols-outlined text-[16px]">expand_more</span>
                  </button>
                </div>

                <!-- Dropdown Menu -->
                <div 
                  v-if="openDropdownId === req.id"
                  class="absolute right-6 top-12 z-50 w-56 bg-white dark:bg-[#1e1e1e] rounded-lg shadow-xl border border-slate-200 dark:border-gray-700 py-1 animate-in fade-in zoom-in duration-200 text-left"
                >
                  <button
                    v-for="status in availableStatuses"
                    :key="status"
                    @click.stop="updateStatus(req.id, status)"
                    class="w-full text-left px-4 py-2.5 text-xs font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 flex items-center gap-2"
                    :class="{'bg-slate-50 dark:bg-slate-800': req.status_lifecycle === status}"
                  >
                    <span :class="getStatusClass(status)" class="w-2 h-2 rounded-full block border shadow-sm"></span>
                    {{ status }}
                  </button>
                </div>
              </td>
              <td class="px-6 py-5 text-right">
                <button 
                  @click.stop="openDetail(req)"
                  class="bg-slate-100 dark:bg-[#1a1a1a] text-slate-500 dark:text-slate-400 hover:bg-accent-emerald hover:text-[#032A28] p-2.5 rounded-xl transition-all"
                >
                  <span class="material-symbols-outlined text-xl">edit_note</span>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal Add Request -->
    <div v-if="showAddModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" @click="showAddModal = false"></div>
      <div class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 w-full md:w-[70%] max-h-[90vh] rounded-3xl overflow-hidden flex flex-col z-10 shadow-2xl transition-all">
        <div class="p-6 border-b border-slate-100 dark:border-gray-800 flex items-center justify-between bg-slate-50 dark:bg-[#1a1a1a]">
          <div>
            <h3 class="text-xl font-black text-slate-800 dark:text-white">Ajukan Fitur Baru</h3>
            <p class="text-[10px] text-slate-500 dark:text-slate-400 uppercase tracking-widest font-bold mt-1">Formulir Pengusulan Pengembangan</p>
          </div>
          <button @click="showAddModal = false" class="text-slate-400 hover:text-slate-600 dark:text-slate-500 dark:hover:text-white transition-colors p-2 hover:bg-slate-100 dark:hover:bg-white/5 rounded-full">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>
        
        <div class="flex-1 overflow-y-auto custom-scrollbar p-8 bg-white dark:bg-[#111111]">
          <form id="addFeatureForm" @submit.prevent="saveRequest" class="grid grid-cols-2 gap-8">
            <!-- Basic Info -->
            <div class="space-y-6">
              <h4 class="text-xs font-bold text-accent-emerald uppercase tracking-widest border-b border-accent-emerald/20 pb-2 dark:text-white">Informasi Dasar</h4>
              
              <div class="space-y-2">
                <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Judul Request Fitur</label>
                <input v-model="form.judul_request" type="text" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald focus:border-transparent transition-all outline-none" placeholder="Contoh: Modul Absensi Face Recognition" required>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Proyek / Pesantren</label>
                  <select v-model="form.project_id" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none transition-all">
                    <option v-for="p in projects" :key="p.id" :value="p.id">{{ p.name }}</option>
                  </select>
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Komponen Utama</label>
                  <select v-model="form.component_id" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none transition-all">
                    <option v-for="c in components" :key="c.id" :value="c.id">{{ c.name }}</option>
                  </select>
                </div>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Status Perwakilan</label>
                  <select v-model="form.status_perwakilan" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none transition-all">
                    <option value="Inisiatif Sendiri">Inisiatif Sendiri</option>
                    <option value="Mewakili Pesantren">Mewakili Pesantren</option>
                  </select>
                </div>
                <div v-if="form.status_perwakilan === 'Mewakili Pesantren'" class="space-y-2">
                  <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Kode Pesantren</label>
                  <input v-model="form.kode_pesantren" type="text" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none transition-all" placeholder="Masukkan Kode">
                </div>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Unit / Yayasan</label>
                  <input v-model="form.unit_yayasan" type="text" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none transition-all" placeholder="Contoh: Unit Madrasah">
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Kategori Modul</label>
                  <input v-model="form.kategori_modul" type="text" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none transition-all" placeholder="Contoh: Akademik">
                </div>
              </div>
            </div>

            <!-- Technical Detail -->
            <div class="space-y-6">
              <h4 class="text-xs font-bold text-accent-emerald uppercase tracking-widest border-b border-accent-emerald/20 pb-2 dark:text-white">Detail Teknis & Urgensi</h4>
              
              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Tipe Pengembangan</label>
                  <select v-model="form.kategori_dev" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none transition-all">
                    <option value="Fitur Baru">Fitur Baru</option>
                    <option value="Peningkatan Fitur">Peningkatan Fitur</option>
                    <option value="Optimasi Sistem">Optimasi Sistem</option>
                    <option value="UI/UX">UI/UX (Perbaikan Tampilan)</option>
                    <option value="Keamanan">Security (Keamanan)</option>
                  </select>
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Tingkat Urgensi</label>
                  <select v-model="form.urgensi" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none transition-all">
                    <option value="Low">Low (Bisa Nanti)</option>
                    <option value="Medium">Medium (Standar)</option>
                    <option value="High">High (Penting)</option>
                    <option value="Critical">Critical (Sangat Mendesak)</option>
                  </select>
                </div>
              </div>

              <div class="space-y-2">
                <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Deskripsi Masukan</label>
                <textarea v-model="form.deskripsi_masukan" rows="2" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none resize-none transition-all" placeholder="Jelaskan gambaran umum fitur..."></textarea>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Masalah & Dampak</label>
                  <div class="grid grid-cols-2 gap-2">
                    <textarea v-model="form.masalah" rows="2" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-xs text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none resize-none transition-all" placeholder="Masalah..."></textarea>
                    <textarea v-model="form.dampak" rows="2" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-xs text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none resize-none transition-all" placeholder="Dampak..."></textarea>
                  </div>
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Pelapor</label>
                  <select 
                    v-model="form.reporter_id"
                    class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none transition-all"
                  >
                    <option value="" disabled>-- Pilih Pelapor --</option>
                    <option v-for="profile in allProfiles" :key="profile.id" :value="profile.id">
                      {{ profile.full_name || profile.email || 'Tanpa Nama' }} {{ profile.id === authStore.user?.id ? '(Saya)' : '' }}
                    </option>
                  </select>
                </div>
              </div>

              <div class="space-y-2">
                <label class="text-[10px] font-bold text-slate-500 dark:text-slate-300 uppercase tracking-widest">Usulan Solusi & Link Lampiran</label>
                <div class="flex flex-col gap-2">
                  <textarea v-model="form.usulan" rows="1" class="w-full bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-2 text-xs text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none resize-none transition-all" placeholder="Usulan solusi..."></textarea>
                  <div class="flex gap-2">
                    <input v-model="form.attachment_wa" type="url" class="flex-1 bg-slate-50 dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-2 text-xs text-slate-800 dark:text-white focus:ring-2 focus:ring-accent-emerald outline-none transition-all" placeholder="Link lampiran (URL)">
                    <input type="file" ref="modalFileInput" class="hidden" @change="e => modalFile = e.target.files[0]">
                    <button type="button" @click="modalFileInput?.click()" class="bg-slate-100 dark:bg-white/5 hover:bg-slate-200 dark:hover:bg-white/10 p-2 rounded-xl transition-all border border-slate-200 dark:border-white/10 flex items-center gap-2">
                      <span class="material-symbols-outlined text-sm">{{ modalFile ? 'check_circle' : 'attach_file' }}</span>
                      <span class="text-[10px] font-bold truncate max-w-[80px]">{{ modalFile ? modalFile.name : 'File' }}</span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </form>
        </div>

          <div class="p-6 border-t border-slate-100 dark:border-gray-800 bg-slate-50 dark:bg-[#1a1a1a] flex items-center justify-end gap-4 shrink-0">
            <button @click="showAddModal = false" class="text-slate-400 hover:text-slate-600 dark:text-slate-500 dark:hover:text-white text-xs font-bold uppercase tracking-widest transition-colors">Batal</button>
            <button 
              type="submit"
              form="addFeatureForm"
              :disabled="modalLoading"
              class="bg-emerald-600 hover:bg-emerald-500 dark:bg-emerald-500 dark:hover:bg-emerald-400 disabled:opacity-50 text-white px-8 py-3 rounded-xl text-xs font-bold uppercase tracking-widest transition-all flex items-center gap-2 shadow-lg shadow-emerald-600/20 active:scale-95"
            >
              <span v-if="modalLoading" class="material-symbols-outlined animate-spin text-sm">progress_activity</span>
              Kirim Pengajuan
            </button>
          </div>
      </div>
    </div>

    <!-- Detail Modal -->
    <div v-if="showDetailModal && selectedRequest" class="fixed inset-0 z-50 flex items-center justify-center p-0 md:p-4">
      <div class="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" @click="showDetailModal = false"></div>
      
      <div class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 w-full md:max-w-[100vw] h-full md:h-[100vh] md:rounded-none overflow-hidden z-10 flex flex-col shadow-2xl transition-all">
        <!-- Modal Header -->
        <header class="h-20 bg-slate-50 dark:bg-[#1a1a1a]/50 border-b border-slate-200 dark:border-gray-800 flex items-center justify-between px-8 shrink-0">
          <div class="flex flex-col">
            <div class="flex items-center gap-2 text-[10px] font-bold text-slate-500 dark:text-slate-500 uppercase tracking-widest mb-1">
              <span>Feature Request</span>
              <span class="material-symbols-outlined text-[10px]">chevron_right</span>
              <span class="text-accent-emerald">Detail Pengajuan</span>
            </div>
            <div class="flex items-center gap-3">
              <h2 class="text-xl font-black text-slate-800 dark:text-white leading-none">{{ selectedRequest.judul_request }}</h2>
              <span :class="getStatusClass(selectedRequest.status_lifecycle)" class="status-badge px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border shadow-sm">
                {{ selectedRequest.status_lifecycle }}
              </span>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <button v-if="authStore.user?.role === 'Super Admin'" @click="showDetailModal = false" class="flex items-center gap-2 bg-white dark:bg-white/5 hover:bg-slate-50 dark:hover:bg-white/10 text-slate-700 dark:text-white/80 px-4 py-2 rounded-lg font-bold text-sm transition-all border border-slate-200 dark:border-white/10 shadow-sm active:scale-95">
              <span class="material-symbols-outlined text-lg">edit</span>
              Edit Request
            </button>
            <button @click="showDetailModal = false" class="text-slate-400 hover:text-slate-600 dark:text-slate-500 dark:hover:text-white transition-colors p-2 hover:bg-slate-100 dark:hover:bg-white/5 rounded-full">
              <span class="material-symbols-outlined">close</span>
            </button>
          </div>
        </header>

        <!-- Modal Body (Scrollable) -->
        <div class="flex-1 overflow-y-auto custom-scrollbar p-8 bg-slate-50/30 dark:bg-transparent">
          <div class="max-w-[1600px] mx-auto">
            <div class="grid grid-cols-12 gap-6 mb-8">
              <!-- Main Content (Left) -->
              <div class="col-span-8 space-y-6">
                <!-- Identitas & Konteks -->
                <section class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 rounded-xl p-6 shadow-sm">
                  <h3 class="text-sm font-black text-slate-800 dark:text-white flex items-center gap-2 mb-6 pb-4 border-b border-slate-100 dark:border-gray-800">
                    <span class="material-symbols-outlined text-accent-emerald text-xl">fingerprint</span>
                    Identitas & Konteks
                  </h3>
                  <div class="grid grid-cols-3 gap-y-6 gap-x-4">
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Reporter</label>
                      <div class="flex items-center gap-2">
                        <img :src="selectedRequest.reporter?.avatar_url || 'https://ui-avatars.com/api/?name=' + selectedRequest.reporter?.full_name" class="w-6 h-6 rounded-full border border-slate-200 dark:border-white/10" alt="Avatar">
                        <span class="text-sm text-slate-700 dark:text-white/90 font-bold">{{ selectedRequest.reporter?.full_name || 'Unknown' }}</span>
                      </div>
                    </div>
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Tanggal Pengajuan</label>
                      <span class="text-sm text-slate-700 dark:text-white/90 font-bold">{{ new Date(selectedRequest.created_at).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' }) }}</span>
                    </div>
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Status Perwakilan</label>
                      <span class="text-sm text-slate-700 dark:text-white/90 font-bold">{{ selectedRequest.status_perwakilan }} {{ selectedRequest.kode_pesantren ? '(' + selectedRequest.kode_pesantren + ')' : '' }}</span>
                    </div>
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Unit Yayasan</label>
                      <span class="text-sm text-slate-700 dark:text-white/90 font-bold">{{ selectedRequest.unit_yayasan || '-' }}</span>
                    </div>
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">App Name</label>
                      <span class="text-sm text-slate-700 dark:text-white/90 font-bold">{{ selectedRequest.project?.name || '-' }}</span>
                    </div>
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Kategori Modul</label>
                      <span class="text-sm text-slate-700 dark:text-white/90 font-bold">{{ selectedRequest.component?.name || '-' }}</span>
                    </div>
                  </div>
                </section>

                <!-- Detail Ide -->
                <section class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 rounded-xl p-6 shadow-sm">
                  <h3 class="text-sm font-black text-slate-800 dark:text-white flex items-center gap-2 mb-6 pb-4 border-b border-slate-100 dark:border-gray-800">
                    <span class="material-symbols-outlined text-accent-emerald text-xl">lightbulb</span>
                    Detail Ide
                  </h3>
                  <div class="space-y-6">
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Judul Request</label>
                      <p class="text-slate-800 dark:text-white font-black text-lg">{{ selectedRequest.judul_request }}</p>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                      <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Kategori Pengembangan</label>
                      <div class="inline-flex items-center gap-2 px-2.5 py-1 bg-emerald-900/10 dark:bg-emerald-500/10 text-emerald-900 dark:text-emerald-400 rounded text-xs font-bold border border-emerald-900/20 dark:border-emerald-500/20">
                        <span class="material-symbols-outlined text-sm">extension</span> {{ selectedRequest.kategori_dev }}
                      </div>
                    </div>
                    </div>
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Deskripsi Singkat</label>
                      <p class="text-sm text-slate-600 dark:text-white/60 leading-relaxed font-medium">{{ selectedRequest.deskripsi_masukan }}</p>
                    </div>
                  </div>
                </section>

                <!-- Analisis Strategis -->
                <section class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 rounded-xl p-6 shadow-sm">
                  <h3 class="text-sm font-black text-slate-800 dark:text-white flex items-center gap-2 mb-6 pb-4 border-b border-slate-100 dark:border-gray-800">
                    <span class="material-symbols-outlined text-accent-emerald text-xl">analytics</span>
                    Analisis Strategis
                  </h3>
                  <div class="space-y-6">
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Problem Statement</label>
                      <div class="bg-slate-50 dark:bg-black/20 p-4 rounded-lg border border-slate-100 dark:border-white/5">
                        <p class="text-sm text-slate-600 dark:text-white/70 leading-relaxed font-medium">{{ selectedRequest.masalah }}</p>
                      </div>
                    </div>
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Proposed Solution</label>
                      <div class="bg-slate-50 dark:bg-black/20 p-4 rounded-lg border border-slate-100 dark:border-white/5">
                        <p class="text-sm text-slate-600 dark:text-white/70 leading-relaxed font-medium">{{ selectedRequest.usulan }}</p>
                      </div>
                    </div>
                    <div>
                      <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1 block">Analisis Dampak</label>
                      <div class="grid grid-cols-2 gap-4">
                        <div class="p-4 rounded-lg bg-accent-emerald/5 border border-accent-emerald/10">
                          <p class="text-[10px] font-bold text-accent-emerald uppercase mb-1">Impact Analysis</p>
                          <p class="text-sm text-slate-700 dark:text-white/80 font-medium">{{ selectedRequest.dampak }}</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </section>

              </div>

              <!-- Sidebar Content (Right) -->
              <div class="col-span-4 space-y-6">
                <!-- Urgensi -->
                <div class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 rounded-xl p-6 border-t-4 shadow-sm" :class="getUrgencyBorder(selectedRequest.urgensi)">
                  <label class="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-3 block">Tingkat Urgensi</label>
                  <div class="flex items-center gap-3">
                    <div class="w-12 h-12 rounded-xl flex items-center justify-center" :class="getUrgencyBg(selectedRequest.urgensi)">
                      <span class="material-symbols-outlined text-3xl" :class="getUrgencyText(selectedRequest.urgensi)">priority_high</span>
                    </div>
                    <div>
                      <p class="text-xl font-black tracking-tight" :class="getUrgencyText(selectedRequest.urgensi)">{{ selectedRequest.urgensi?.toUpperCase() }}</p>
                      <p class="text-[11px] text-slate-400 dark:text-white/40 font-medium">Tingkat prioritas pengembangan</p>
                    </div>
                  </div>
                </div>

                <!-- Timeline Status -->
                <div class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 rounded-xl p-6 shadow-sm">
                  <h3 class="text-sm font-black text-slate-800 dark:text-white mb-6">Timeline Status</h3>
                  <div class="space-y-6 relative before:absolute before:left-[11px] before:top-2 before:bottom-2 before:w-px before:bg-slate-100 dark:before:bg-white/10">
                    <div class="relative pl-8">
                      <div class="absolute left-0 top-1 w-6 h-6 rounded-full bg-accent-emerald flex items-center justify-center shadow-[0_0_12px_rgba(16,185,129,0.4)]">
                        <span class="material-symbols-outlined text-[14px] text-primary font-bold">check</span>
                      </div>
                      <div>
                        <p class="text-xs font-black text-slate-800 dark:text-white">Pengajuan Dibuat</p>
                        <p class="text-[10px] text-slate-400 dark:text-white/40 font-bold">{{ new Date(selectedRequest.created_at).toLocaleDateString('id-ID') }} • Oleh {{ selectedRequest.reporter?.full_name }}</p>
                      </div>
                    </div>
                    
                    <div v-if="selectedRequest.status_lifecycle !== 'Baru'" class="relative pl-8">
                      <div class="absolute left-0 top-1 w-6 h-6 rounded-full bg-blue-500 flex items-center justify-center shadow-[0_0_12px_rgba(59,130,246,0.4)]">
                        <span class="material-symbols-outlined text-[14px] text-white font-bold">visibility</span>
                      </div>
                      <div>
                        <p class="text-xs font-black text-blue-500 dark:text-blue-400">{{ selectedRequest.status_lifecycle }}</p>
                        <p class="text-[10px] text-slate-400 dark:text-white/40 font-bold">{{ new Date(selectedRequest.updated_at).toLocaleDateString('id-ID') }} • Sistem Auto</p>
                      </div>
                    </div>

                    <div v-if="selectedRequest.status_lifecycle === 'Baru'" class="relative pl-8">
                      <div class="absolute left-0 top-1 w-6 h-6 rounded-full bg-slate-100 dark:bg-white/10 border border-slate-200 dark:border-white/20 flex items-center justify-center">
                        <div class="w-1.5 h-1.5 rounded-full bg-slate-300 dark:bg-white/20"></div>
                      </div>
                      <div>
                        <p class="text-xs font-black text-slate-300 dark:text-white/30">Langkah Berikutnya</p>
                        <p class="text-[10px] text-slate-200 dark:text-white/20 font-bold">Menunggu Peninjauan...</p>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Alasan Penolakan (Jika ada) -->
                <div v-if="selectedRequest.status_lifecycle === 'Ditolak'" class="bg-white dark:bg-[#111111] border border-red-500/20 rounded-xl p-6 shadow-sm">
                  <h3 class="text-sm font-black text-red-500 dark:text-red-400 mb-3 flex items-center gap-2">
                    <span class="material-symbols-outlined text-sm">error</span> Alasan Penolakan
                  </h3>
                  <p class="text-xs text-slate-600 dark:text-white/60 leading-relaxed bg-red-50 dark:bg-red-500/5 p-3 rounded-lg border border-red-100 dark:border-red-500/10 italic font-medium">
                    {{ selectedRequest.alasan_penolakan || 'Tidak ada alasan yang diberikan.' }}
                  </p>
                </div>

                <!-- Action Panel (Management Only) -->
                <div v-if="['Super Admin', 'Admin', 'Editor'].includes(authStore.user?.role)" class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 rounded-xl p-6 shadow-sm">
                  <h3 class="text-sm font-black text-slate-800 dark:text-white mb-4">Manajemen Status</h3>
                  <div class="grid grid-cols-1 gap-2">
                    <button 
                      v-for="status in ['Baru', 'Sedang Ditinjau', 'Sedang Dipertimbangkan', 'Sedang Dikembangkan', 'Selesai']" 
                      :key="status"
                      @click="updateStatus(selectedRequest.id, status)"
                      class="w-full px-4 py-2 rounded-lg text-xs font-black transition-all text-left flex items-center justify-between group"
                      :class="selectedRequest.status_lifecycle === status 
                        ? 'bg-accent-emerald text-[#032A28]' 
                        : (status === 'Baru' 
                        ? 'bg-gray-600/10 text-gray-600 dark:bg-gray-400/10 dark:text-gray-400' 
                        : 'bg-slate-50 dark:bg-white/5 text-slate-500 dark:text-white/60 hover:bg-slate-100 dark:hover:bg-white/10')"
                    >
                      {{ status }}
                      <span v-if="selectedRequest.status_lifecycle === status" class="material-symbols-outlined text-sm">check_circle</span>
                    </button>
                    <button 
                      @click="updateStatus(selectedRequest.id, 'Ditolak')"
                      class="w-full px-4 py-2 rounded-lg text-xs font-black transition-all text-left flex items-center justify-between mt-2 bg-red-50 dark:bg-red-500/10 text-red-500 hover:bg-red-500 hover:text-white"
                    >
                      Tolak / Arsip
                      <span class="material-symbols-outlined text-sm">cancel</span>
                    </button>
                    
                    <button 
                      @click="deleteRequest(selectedRequest.id)"
                      class="w-full px-4 py-2 rounded-lg text-xs font-black transition-all text-left flex items-center justify-between mt-4 border border-red-200 dark:border-red-500/20 text-red-400 dark:text-red-500/60 hover:bg-red-500 hover:text-white"
                    >
                      Hapus Permanen
                      <span class="material-symbols-outlined text-sm">delete</span>
                    </button>
                  </div>
                </div>
              </div>
              
              <!-- Full Width Content (Moved) -->
              <div class="col-span-12 space-y-6">
                <!-- Lampiran Pendukung -->
                <section class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 rounded-xl p-6 shadow-sm">
                  <h3 class="text-sm font-black text-slate-800 dark:text-white flex items-center gap-2 mb-6 pb-4 border-b border-slate-100 dark:border-gray-800">
                    <span class="material-symbols-outlined text-accent-emerald text-xl">attachment</span>
                    Lampiran Pendukung
                  </h3>
                  <div class="grid grid-cols-4 gap-4">
                    <a v-for="(att, idx) in allAttachments" :key="idx" :href="att.url" target="_blank" class="group relative">
                      <div class="aspect-video rounded-lg overflow-hidden border border-slate-200 dark:border-white/10 bg-slate-50 dark:bg-white/5 flex items-center justify-center group-hover:border-accent-emerald/50 transition-all">
                        <span class="material-symbols-outlined text-slate-300 dark:text-white/20 text-3xl">
                          {{ att.type === 'link' ? 'link' : 'description' }}
                        </span>
                      </div>
                      <p class="mt-2 text-[10px] text-slate-400 dark:text-white/40 font-bold truncate">{{ att.name }}</p>
                      <p v-if="att.user" class="text-[8px] text-slate-500 dark:text-white/20 truncate">Oleh: {{ att.user }}</p>
                    </a>
                    
                    <div v-if="allAttachments.length === 0" class="col-span-4 text-center py-8 border border-dashed border-slate-200 dark:border-white/10 rounded-xl">
                      <span class="material-symbols-outlined text-slate-300 dark:text-white/10 text-3xl">inventory_2</span>
                      <p class="mt-2 text-[10px] text-slate-400 dark:text-white/20 font-bold uppercase tracking-widest">Tidak ada lampiran</p>
                    </div>
                  </div>
                </section>

                <!-- Forum Diskusi Terpadu -->
                <section class="bg-white dark:bg-[#111111] border border-slate-200 dark:border-gray-800 rounded-xl p-6 flex flex-col h-[750px] shadow-sm overflow-hidden">
                  <h3 class="text-sm font-black text-slate-800 dark:text-white flex items-center gap-2 mb-6 pb-4 border-b border-slate-100 dark:border-gray-800 shrink-0">
                    <span class="material-symbols-outlined text-accent-emerald">forum</span>
                    Forum Diskusi Terpadu ({{ comments.length }} Komentar)
                  </h3>
                  
                  <div class="flex-1 overflow-y-auto custom-scrollbar pr-2 space-y-6 mb-6">
                    <div v-for="comment in comments" :key="comment.id" 
                      :class="['flex gap-3', comment.user_id === authStore.user?.id ? 'flex-row-reverse' : 'flex-row']">
                      
                      <img :src="comment.user?.avatar_url || 'https://ui-avatars.com/api/?name=' + comment.user?.full_name" 
                        class="w-8 h-8 rounded-full border border-slate-200 dark:border-white/10 shrink-0 self-end mb-1" alt="User">
                      
                      <div :class="['max-w-[80%] flex flex-col', comment.user_id === authStore.user?.id ? 'items-end' : 'items-start']">
                        <div class="flex items-center gap-2 mb-1 px-1">
                          <span class="text-[10px] font-bold text-slate-400 dark:text-white/40">{{ comment.user?.full_name }}</span>
                          <span class="text-[8px] bg-slate-100 dark:bg-white/5 text-slate-500 dark:text-white/40 px-1.5 py-0.5 rounded uppercase tracking-wider font-bold">{{ comment.user?.role }}</span>
                        </div>
                        
                        <div :class="[
                          'px-4 py-2.5 rounded-2xl text-sm shadow-sm relative group',
                          comment.user_id === authStore.user?.id 
                            ? 'bg-accent-emerald text-[#032A28] rounded-br-none font-bold' 
                            : 'bg-slate-50 dark:bg-white/5 text-slate-700 dark:text-white/90 border border-slate-100 dark:border-white/5 rounded-bl-none font-medium'
                        ]">
                          <!-- Attachment Display (WhatsApp Style: Media on top) -->
                          <div v-if="comment.attachment_url" class="mb-2 -mx-1 -mt-1 overflow-hidden rounded-xl border border-black/5 dark:border-white/5 bg-black/5 dark:bg-black/20">
                            <a :href="comment.attachment_url" target="_blank" class="block group/media relative">
                              <img 
                                v-if="comment.attachment_url.match(/\.(jpg|jpeg|png|gif|webp)$/i)" 
                                :src="comment.attachment_url" 
                                class="w-full h-auto max-h-[300px] object-cover group-hover/media:scale-105 transition-transform duration-500" 
                              />
                              <div v-else class="p-3 flex items-center gap-3">
                                <div class="w-10 h-10 rounded-lg bg-white/20 dark:bg-white/5 flex items-center justify-center">
                                  <span class="material-symbols-outlined text-2xl">description</span>
                                </div>
                                <div class="flex-1 min-w-0">
                                  <p class="text-[11px] font-black truncate">Lampiran File</p>
                                  <p class="text-[9px] opacity-60 font-bold uppercase tracking-tight">Klik untuk membuka</p>
                                </div>
                                <span class="material-symbols-outlined text-sm opacity-40">open_in_new</span>
                              </div>
                            </a>
                          </div>

                          <p class="leading-relaxed whitespace-pre-wrap">{{ comment.comment_text }}</p>
                          
                          <span :class="['text-[9px] mt-1 block opacity-60 font-bold', comment.user_id === authStore.user?.id ? 'text-[#032A28]' : 'text-slate-400 dark:text-white/60']">
                            {{ new Date(comment.created_at).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) }}
                          </span>
                        </div>
                      </div>
                    </div>
                    
                    <div v-if="comments.length === 0" class="h-full flex flex-col items-center justify-center opacity-40">
                      <span class="material-symbols-outlined text-6xl text-slate-200 dark:text-white/10">chat_bubble</span>
                      <p class="text-xs mt-4 italic font-bold text-slate-400 dark:text-white/20">Belum ada diskusi untuk pengajuan ini.</p>
                    </div>
                  </div>

                  <!-- Chat Input Area -->
                  <div class="mt-auto shrink-0">
                    <!-- File Preview -->
                    <div v-if="selectedFile" class="mb-3 p-2 bg-accent-emerald/10 border border-accent-emerald/20 rounded-xl flex items-center justify-between">
                      <div class="flex items-center gap-2">
                        <span class="material-symbols-outlined text-accent-emerald">description</span>
                        <div class="flex flex-col">
                          <span class="text-[10px] font-bold text-slate-700 dark:text-white truncate max-w-[200px]">{{ selectedFile.name }}</span>
                          <span class="text-[9px] text-slate-500 dark:text-white/40 font-bold">{{ (selectedFile.size / 1024).toFixed(1) }} KB</span>
                        </div>
                      </div>
                      <button @click="removeFile" class="text-slate-400 hover:text-red-500 transition-colors">
                        <span class="material-symbols-outlined text-lg">close</span>
                      </button>
                    </div>

                    <div class="relative flex items-end gap-2">
                      <div class="flex-1 bg-slate-50 dark:bg-black/40 border border-slate-200 dark:border-white/10 rounded-2xl focus-within:border-accent-emerald/50 transition-all p-2">
                        <textarea 
                          v-model="newComment"
                          rows="1"
                          @input="e => { e.target.style.height = 'auto'; e.target.style.height = e.target.scrollHeight + 'px' }"
                          class="w-full bg-transparent border-none px-3 py-2 text-sm text-slate-700 dark:text-white focus:ring-0 outline-none resize-none max-h-32 custom-scrollbar font-medium"
                          placeholder="Tulis tanggapan atau pertanyaan..."
                          @keyup.ctrl.enter="sendComment"
                        ></textarea>
                        
                        <div class="flex items-center justify-between px-2 pt-1 mt-1 border-t border-slate-100 dark:border-white/5">
                          <div class="flex items-center gap-1">
                            <input 
                              type="file" 
                              ref="fileInput" 
                              class="hidden" 
                              @change="handleFileChange"
                              accept="image/*,.pdf,.doc,.docx,.xls,.xlsx"
                            >
                            <button 
                              @click="triggerFileInput"
                              class="p-1.5 rounded-lg text-slate-400 dark:text-white/30 hover:text-accent-emerald hover:bg-accent-emerald/10 transition-all"
                              title="Unggah Media"
                            >
                              <span class="material-symbols-outlined text-xl">attach_file</span>
                            </button>
                            <span class="text-[9px] text-slate-400 dark:text-white/20 ml-2 font-bold uppercase tracking-tight">Ctrl + Enter untuk kirim</span>
                          </div>
                          
                          <button 
                            @click="sendComment"
                            :disabled="commentLoading || (!newComment.trim() && !selectedFile)"
                            class="bg-emerald-800 hover:bg-emerald-900 dark:bg-emerald-500 dark:hover:bg-emerald-400 disabled:opacity-30 text-white px-4 py-1.5 rounded-xl text-[10px] font-bold uppercase transition-all flex items-center gap-2 shadow-lg shadow-emerald-700/20 active:scale-95"
                          >
                            <span v-if="commentLoading" class="material-symbols-outlined animate-spin text-sm">progress_activity</span>
                            <span v-else class="material-symbols-outlined text-sm">send</span>
                            Kirim
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </section>
              </div>
            </div>
          </div>
        </div>

        <!-- Modal Footer -->
        <footer class="p-6 border-t border-slate-200 dark:border-gray-800 bg-slate-50 dark:bg-[#1a1a1a]/50 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <span class="material-symbols-outlined text-slate-400 dark:text-white/20 text-sm">history</span>
            <span class="text-[10px] text-slate-400 dark:text-white/30 italic font-bold">Terakhir diperbarui: {{ new Date(selectedRequest.updated_at).toLocaleString('id-ID') }}</span>
          </div>
          <button @click="showDetailModal = false" class="bg-slate-200 dark:bg-white/10 hover:bg-slate-300 dark:hover:bg-white/20 text-slate-700 dark:text-white px-8 py-2.5 rounded-xl text-xs font-bold transition-all shadow-sm active:scale-95">Tutup Detail</button>
        </footer>
      </div>
    </div>

    <!-- Rejection Modal -->
    <div v-if="showRejectionModal" class="fixed inset-0 z-[60] flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" @click="showRejectionModal = false"></div>
      <div class="bg-white dark:bg-[#141414] border border-slate-200 dark:border-gray-800 w-full max-w-md rounded-2xl overflow-hidden z-10 shadow-2xl transition-all">
        <div class="p-6 border-b border-slate-100 dark:border-gray-800 bg-slate-50 dark:bg-[#1a1a1a]/50">
          <h3 class="text-lg font-black text-slate-800 dark:text-white flex items-center gap-2">
            <span class="material-symbols-outlined text-red-500">cancel</span>
            Alasan Penolakan
          </h3>
          <p class="text-[10px] text-slate-500 dark:text-slate-400 uppercase tracking-widest font-bold mt-1">Berikan alasan mengapa pengajuan ini ditolak</p>
        </div>
        <div class="p-6 space-y-4">
          <textarea 
            v-model="rejectionReason" 
            rows="4" 
            class="w-full bg-slate-50 dark:bg-black/20 border border-slate-200 dark:border-gray-700 rounded-xl px-4 py-3 text-sm text-slate-800 dark:text-white focus:ring-2 focus:ring-red-500 outline-none resize-none transition-all font-medium" 
            placeholder="Contoh: Fitur sudah ada, tidak sesuai roadmap, atau keterbatasan resource..."
          ></textarea>
        </div>
        <div class="p-6 border-t border-slate-100 dark:border-gray-800 bg-slate-50 dark:bg-[#1a1a1a]/50 flex justify-end gap-3">
          <button @click="showRejectionModal = false" class="text-slate-400 hover:text-slate-600 dark:text-slate-500 dark:hover:text-white text-xs font-bold uppercase tracking-widest transition-colors">Batal</button>
          <button 
            @click="updateStatus(selectedRequest.id, 'Ditolak')"
            :disabled="!rejectionReason.trim()"
            class="bg-red-500 hover:bg-red-600 disabled:opacity-50 text-white px-6 py-2 rounded-xl text-xs font-bold transition-all shadow-lg shadow-red-500/20 active:scale-95"
          >
            Konfirmasi Tolak
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.custom-scrollbar::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(16, 185, 129, 0.2);
  border-radius: 10px;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: rgba(16, 185, 129, 0.4);
}

.status-badge {
  @apply px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border;
}

.urgency-indicator {
  width: 4px;
  height: 24px;
  border-radius: 2px;
}
</style>
