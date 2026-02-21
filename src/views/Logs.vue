<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import axios from '../lib/axios'
import { useAuthStore } from '../stores/auth'
import { supabase } from '../lib/supabase' // Keep for auth session check fallback
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement
} from 'chart.js'
import { Pie, Bar } from 'vue-chartjs'

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  ArcElement,
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement
)

// --- PENTING UNTUK USER ---
// Pastikan tabel 'activities' sudah dibuat di Supabase agar fitur history log berjalan lancar.
// Gunakan script RAW/CREATE_ACTIVITIES_TABLE.sql jika belum ada.

const props = defineProps({
  isDarkMode: Boolean
})

const emit = defineEmits(['toggleDarkMode'])
const route = useRoute()

// --- APP STATE ---
const logs = ref([])
const projects = ref([])
const loading = ref(true)
const currentView = ref('all') // 'all', 'add', 'edit', 'detail', 'import'
const selectedLog = ref(null)
const authStore = useAuthStore()
const currentUser = ref(null)
const currentUserRole = ref(authStore.user?.role || 'Viewer')
const comments = ref([])
const activities = ref([])
const defaultProjectId = ref(1)
const isSubmitting = ref(false)
const showCharts = ref(true)
const allProfiles = ref([]) // Untuk pilihan pelapor

const currentUserId = computed(() => currentUser.value?.id || authStore.user?.id)

// Form State
const logForm = ref({
  project_id: 1, 
  no_lap: 0,
  module: '',
  version: '',
  found_date: '',
  priority: 'medium',
  status: 'report',
  actual_behavior: '',
  expected_behavior: '',
  severity_details: '',
  attachment_link: '',
  reporter_id: null // Field baru
})

const commentContent = ref('')
const commentAttachment = ref(null)
const attachmentPreview = ref(null)
const fileInput = ref(null)

// Popup State
const popup = ref({
  show: false,
  title: '',
  message: '',
  type: 'success', // 'success', 'error', 'warning'
  confirmCallback: null,
  confirmText: 'OK',
  cancelText: 'Batal',
  showCancel: false
})

const triggerPopup = (title, message, type = 'success', onConfirm = null, showCancel = false) => {
  popup.value = {
    show: true,
    title,
    message,
    type,
    confirmCallback: onConfirm,
    confirmText: onConfirm ? 'Ya, Lanjutkan' : 'OK',
    cancelText: 'Batal',
    showCancel
  }
}

const closePopup = () => {
  popup.value.show = false
}

const handlePopupConfirm = () => {
  if (popup.value.confirmCallback) {
    popup.value.confirmCallback()
  }
  closePopup()
}

const openDropdownId = ref(null) // Track which dropdown is open

const toggleDropdown = (id) => {
  openDropdownId.value = openDropdownId.value === id ? null : id
}

// Close dropdown when clicking outside
onMounted(() => {
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.status-dropdown-container')) {
      openDropdownId.value = null
    }
  })
})

const updateLogStatus = async (logId, newStatus) => {
  if (!['Super Admin', 'Admin', 'Editor'].includes(currentUserRole.value)) {
    triggerPopup('Akses Ditolak', 'Anda tidak memiliki izin untuk mengubah status.', 'error')
    return
  }

  try {
    // Map status for DB if needed (though existing mapping logic handles form data)
    let dbStatus = newStatus
    if (dbStatus === 'on progress') dbStatus = 'on progres'
    if (dbStatus === 'todo') dbStatus = 'to do'

    await axios.patch(`/logs?id=eq.${logId}`, { 
      status: dbStatus,
      updated_at: new Date().toISOString()
    })

    // Update local state
    const log = logs.value.find(l => l.id === logId)
    if (log) {
      log.status = dbStatus
    }
    
    openDropdownId.value = null
    triggerPopup('Berhasil!', `Status berhasil diubah menjadi ${newStatus}`, 'success')
  } catch (error) {
    console.error('Error updating status:', error)
    triggerPopup('Gagal!', 'Gagal memperbarui status: ' + error.message, 'error')
  }
}

// Filters & Pagination
const searchQuery = ref('')
const filterStatus = ref('All')
const filterPriority = ref('All')
const filterProject = ref('All')
const filterMyLogs = ref(false)
const sortBy = ref('newest')
const currentPage = ref(1)
const rowsPerPage = ref(20)

// Constants
const statuses = ['All', 'report', 'to do', 'on progres', 'pending', 'done', 'reject']
const priorities = ['All', 'low', 'medium', 'high', 'critical']

// 1. Mapping Priority & Status agar sesuai dengan database (termasuk typo)
const mapToDbValues = (formData) => {
  let dbPriority = formData.priority
  if (dbPriority === 'high') dbPriority = 'hight'
  if (dbPriority === 'critical') dbPriority = 'critikal'
  
  let dbStatus = formData.status
  if (dbStatus === 'on progress') dbStatus = 'on progres'
  if (dbStatus === 'todo') dbStatus = 'to do'
  
  return { dbPriority, dbStatus }
}

// --- WATCHERS ---
watch([filterProject, sortBy], () => {
  currentPage.value = 1
  fetchLogs()
})

watch(() => logForm.value.project_id, () => {
  fetchProfiles()
})

watch([searchQuery, filterStatus, filterPriority, filterMyLogs], () => {
  currentPage.value = 1
})

// --- AUTH & RBAC ---
const checkAuth = async () => {
  const user = authStore.user
  if (user) {
    if (user.role) {
      currentUserRole.value = user.role
    }
    
    try {
      // Use Axios to fetch profile
      const response = await axios.get(`/profiles?id=eq.${user.id}&select=*`)
      const profile = response.data?.[0]
      
      if (profile) {
        currentUser.value = profile
        currentUserRole.value = profile.role || user.role || 'Viewer'
      } else if (user.email === 'editor@psd.com') {
        currentUserRole.value = 'Editor'
        currentUser.value = {
          full_name: 'Editor Manager',
          email: 'editor@psd.com',
          role: 'Editor'
        }
      }
    } catch (error) {
      console.error('Error fetching profile:', error)
      if (user.email === 'editor@psd.com') {
        currentUserRole.value = 'Editor'
      }
    }
  }
}

// --- DATA FETCHING ---
const fetchProjects = async () => {
  try {
    const isSuperAdmin = ['Super Admin', 'Admin'].includes(authStore.user?.role)
    const projectId = authStore.user?.project_id || 1
    
    let url = '/projects?select=id,name'
    // Strict filtering: Always filter by project_id regardless of role
    url += `&id=eq.${projectId}`
    
    const response = await axios.get(url)
    projects.value = response.data || []
  } catch (error) {
    console.error('Error fetching projects:', error)
  }
}

const fetchProfiles = async () => {
  console.log('--- fetchProfiles Started ---')
  try {
    // Ambil role dengan lebih aman
    const role = (currentUserRole.value || authStore.user?.role || 'Viewer').toString()
    const isSuperAdmin = ['Super Admin', 'Admin'].includes(role)
    const currentUserIdLocal = authStore.user?.id || currentUser.value?.id
    
    // Project ID fallback
    const projectId = logForm.value.project_id || authStore.user?.project_id || 1
    
    console.log('Debug fetchProfiles:', { role, isSuperAdmin, projectId, currentUserIdLocal })
    
    let url = '/profiles?select=id,full_name,avatar_url,project_id,email'
    
    // Strict filtering: Always filter by project_id regardless of role
    if (projectId) {
      url += `&project_id=eq.${projectId}`
    }
    
    console.log('Final URL:', url)
    const response = await axios.get(url)
    const data = Array.isArray(response.data) ? response.data : []
    
    console.log('Data from DB:', data.length)
    
    // Pastikan user login ada dalam list
    if (currentUserIdLocal && !data.find(p => p.id === currentUserIdLocal)) {
      console.log('Adding current user to list manually')
      data.unshift({
        id: currentUserIdLocal,
        full_name: currentUser.value?.full_name || authStore.user?.email || 'Saya',
        avatar_url: currentUser.value?.avatar_url,
        email: authStore.user?.email
      })
    }
    
    allProfiles.value = data
    
    // Auto-select jika reporter_id masih kosong
    if (!logForm.value.reporter_id && currentUserIdLocal) {
      logForm.value.reporter_id = currentUserIdLocal
    }
    
    console.log('fetchProfiles Success. Count:', allProfiles.value.length)
  } catch (error) {
    console.error('fetchProfiles Error:', error)
    // Fallback darurat agar dropdown tidak kosong
    const fallbackId = authStore.user?.id || currentUser.value?.id
    if (fallbackId) {
      allProfiles.value = [{
        id: fallbackId,
        full_name: currentUser.value?.full_name || authStore.user?.email || 'Saya (Fallback)',
        email: authStore.user?.email
      }]
      logForm.value.reporter_id = fallbackId
    }
  }
}

const fetchDefaultProject = async () => {
  try {
    const isSuperAdmin = ['Super Admin', 'Admin'].includes(authStore.user?.role)
    const idToFetch = authStore.user?.project_id || 1
    
    if (projects.value.length === 0) {
      await fetchProjects()
    }

    if (projects.value.length > 0) {
      const defaultProj = isSuperAdmin ? projects.value[0] : projects.value.find(p => p.id === idToFetch)
      defaultProjectId.value = defaultProj?.id || projects.value[0].id
      logForm.value.project_id = defaultProjectId.value
    }
  } catch (error) {
    console.error('Error fetching project:', error)
  }
}

const getNextNoLap = async () => {
  console.log('getNextNoLap started')
  try {
    const projectId = logForm.value.project_id || defaultProjectId.value
    if (!projectId) {
      console.warn('Project ID is missing for getNextNoLap, defaulting to 101')
      return 101
    }
    console.log('Fetching next no_lap for project:', projectId)
    
    // Explicitly select only no_lap to minimize data transfer
    const response = await axios.get(`/logs?project_id=eq.${projectId}&select=no_lap&order=no_lap.desc&limit=1`)
    
    console.log('getNextNoLap response:', response.data)
    if (response.data && response.data.length > 0) {
      const lastNoLap = response.data[0].no_lap
      return (typeof lastNoLap === 'number' ? lastNoLap : 100) + 1
    }
    return 101
  } catch (error) {
    console.error('Error fetching next no_lap:', error)
    // Return a safe default if fetch fails, but log it clearly
    return 101
  }
}

const fetchLogs = async () => {
  loading.value = true
  try {
    const isSuperAdmin = ['Super Admin', 'Admin'].includes(authStore.user?.role)
    const userProjectId = authStore.user?.project_id
    
    // Explicitly join with profiles using the foreign key reporter_id
    let url = `/logs?select=*,reporter:profiles!reporter_id(full_name,avatar_url)`
    
    // Project Filtering Logic
    if (filterProject.value !== 'All') {
      url += `&project_id=eq.${filterProject.value}`
    } else {
      // Strict filtering: Always default to user's project
      url += `&project_id=eq.${userProjectId || 1}`
    }
    
    // Sort
    const sortDir = sortBy.value === 'newest' ? 'desc' : 'asc'
    url += `&order=created_at.${sortDir}`

    console.log('Fetching logs from URL:', url)
    const response = await axios.get(url)
    
    logs.value = response.data || []
    console.log('Logs state updated, count:', logs.value.length)
  } catch (error) {
    console.error('Error fetching logs:', error)
    // Fallback: fetch without join if there's a schema issue
    try {
      let fallbackUrl = '/logs?select=*'
      if (filterProject.value !== 'All') {
        fallbackUrl += `&project_id=eq.${filterProject.value}`
      } else {
        fallbackUrl += `&project_id=eq.${userProjectId || 1}`
      }
      fallbackUrl += '&order=created_at.desc'
      const response = await axios.get(fallbackUrl)
      logs.value = response.data || []
    } catch (e) {
      console.error('Fallback fetch logs failed:', e.message)
    }
  } finally {
    loading.value = false
  }
}

const fetchComments = async (logId) => {
  try {
    // Menggunakan metode polimorfik: parent_id & parent_type
    const response = await axios.get(`/discussion_forum?parent_id=eq.${logId}&parent_type=eq.LOG&select=*,user:profiles!discussion_forum_user_id_fkey(full_name,avatar_url,role)&order=created_at.asc`)
    comments.value = response.data || []
  } catch (error) {
    console.error('Error fetching comments:', error.message)
    // Fallback: fetch tanpa join
    try {
      const response = await axios.get(`/discussion_forum?parent_id=eq.${logId}&parent_type=eq.LOG&select=*&order=created_at.asc`)
      comments.value = response.data || []
    } catch (e) {
      console.error('Fallback fetch comments failed:', e.message)
    }
  }
}

const fetchActivities = async (logId) => {
  try {
    const response = await axios.get(`/activities?log_id=eq.${logId}&order=created_at.desc`)
    activities.value = response.data || []
  } catch (error) {
    console.error('Error fetching activities:', error.message)
    activities.value = []
  }
}

// --- ACTIONS ---
const navigateTo = (view, log = null) => {
  // RBAC Check
  if (['add', 'edit', 'import'].includes(view) && !['Editor', 'Admin', 'Super Admin'].includes(currentUserRole.value)) {
    triggerPopup('Akses Ditolak', 'Anda tidak memiliki izin untuk mengakses halaman ini.', 'error')
    return
  }

  currentView.value = view
  if (log) {
    selectedLog.value = { ...log }
    if (view === 'edit') {
      logForm.value = {
        project_id: log.project_id || defaultProjectId.value,
        no_lap: log.no_lap || 0,
        module: log.module || '',
        version: log.version || '',
        found_date: log.found_date ? log.found_date.slice(0, 16) : '',
        priority: log.priority || 'medium',
        status: log.status || 'report',
        actual_behavior: log.actual_behavior || '',
        expected_behavior: log.expected_behavior || '',
        severity_details: log.severity_details || '',
        attachment_link: log.attachment_link || '',
        reporter_id: log.reporter_id || null
      }
      fetchProfiles() // Ambil profil untuk project log ini
    } else if (view === 'detail') {
      fetchComments(log.id)
      fetchActivities(log.id)
    }
  } else {
    selectedLog.value = null
    if (view === 'add') {
      logForm.value = {
        project_id: defaultProjectId.value, 
        no_lap: 0, // Will be fetched on save
        module: '',
        version: '',
        found_date: new Date().toISOString().slice(0, 16),
        priority: 'medium',
        status: 'report',
        actual_behavior: '',
        expected_behavior: '',
        severity_details: '',
        attachment_link: '',
        reporter_id: currentUserId.value // Default ke user login
      }
      fetchProfiles() // Ambil profil untuk project default
    }
  }
  window.scrollTo(0, 0)
}

const handleSaveLog = async () => {
  console.log('handleSaveLog called')
  // Manual Validation to ensure user sees error even if fields are off-screen
  const errors = []
  if (!logForm.value.version) errors.push('Versi')
  if (!logForm.value.found_date) errors.push('Tanggal Temuan')
  if (!logForm.value.module) errors.push('Modul / Area')
  if (!logForm.value.actual_behavior) errors.push('Hasil Aktual')
  if (!logForm.value.expected_behavior) errors.push('Harapan')
  if (!logForm.value.severity_details) errors.push('Tingkat Keparahan / Detail Teknis')

  if (errors.length > 0) {
    console.log('Validation errors:', errors)
    triggerPopup('Validasi Gagal', 'Mohon lengkapi data berikut: ' + errors.join(', '), 'warning')
    return
  }

  isSubmitting.value = true
  try {
    if (currentView.value === 'add') {
      await saveNewLog(logForm.value)
    } else if (currentView.value === 'edit') {
      await updateLog(logForm.value)
    }
  } catch (e) {
    console.error('Unexpected error in handleSaveLog:', e)
  } finally {
    isSubmitting.value = false
  }
}

const saveNewLog = async (formData) => {
  try {
    // Get next no_lap from DB
    const nextNoLap = await getNextNoLap()
    console.log('Next No Lap:', nextNoLap)

    const { dbPriority, dbStatus } = mapToDbValues(formData)
    
    // Ensure date is in ISO format
    let formattedDate = formData.found_date
    if (formattedDate && !formattedDate.includes('Z')) {
      formattedDate = new Date(formattedDate).toISOString()
    }

    // Prepare complete data object according to schema
    const dataToInsert = {
      project_id: parseInt(formData.project_id || defaultProjectId.value),
      no_lap: parseInt(nextNoLap),
      module: formData.module,
      version: formData.version,
      found_date: formattedDate,
      priority: dbPriority,
      status: dbStatus,
      reporter_id: formData.reporter_id || currentUser.value?.id || null,
      actual_behavior: formData.actual_behavior,
      expected_behavior: formData.expected_behavior,
      severity_details: formData.severity_details,
      attachment_link: formData.attachment_link || null
      // created_at and updated_at are handled by DB defaults and triggers
    }
    
    console.log('Sending Payload:', dataToInsert)

    // Axios POST
    const response = await axios.post('/logs', dataToInsert, {
      headers: { 'Prefer': 'return=representation' }
    })
    
    console.log('Save response:', response)

    await fetchLogs()
    
    navigateTo('all')
    triggerPopup('Berhasil!', 'Log bug baru telah berhasil disimpan ke sistem.', 'success')
  } catch (error) {
    console.error('Error saving log:', error.response?.data || error)
    const dbError = error.response?.data?.message || error.response?.data?.hint || error.message
    triggerPopup('Gagal!', 'Terjadi kesalahan saat menyimpan log: ' + dbError, 'error')
  }
}

const updateLog = async (formData) => {
  try {
    const { dbPriority, dbStatus } = mapToDbValues(formData)
    
    // Prepare update data (exclude id, created_at, updated_at - they're managed by DB)
    const dataToUpdate = {
      project_id: parseInt(formData.project_id),
      no_lap: parseInt(formData.no_lap),
      module: formData.module,
      version: formData.version,
      found_date: formData.found_date,
      priority: dbPriority,
      status: dbStatus,
      reporter_id: formData.reporter_id,
      actual_behavior: formData.actual_behavior,
      expected_behavior: formData.expected_behavior,
      severity_details: formData.severity_details,
      attachment_link: formData.attachment_link || null,
      updated_at: new Date().toISOString()
    }
    
    // Axios PATCH
    await axios.patch(`/logs?id=eq.${selectedLog.value.id}`, dataToUpdate)
    
    await fetchLogs()
    
    navigateTo('all')
    triggerPopup('Berhasil!', 'Data log bug telah diperbarui.', 'success')
  } catch (error) {
    console.error('Error updating log:', error.response?.data || error)
    const dbError = error.response?.data?.message || error.message
    triggerPopup('Gagal!', 'Gagal memperbarui log: ' + dbError, 'error')
  }
}

const deleteLog = async (id) => {
  if (!['Editor', 'Admin', 'Super Admin'].includes(currentUserRole.value)) {
    triggerPopup('Akses Ditolak', 'Anda tidak memiliki izin untuk menghapus data.', 'error')
    return
  }
  triggerPopup(
    'Hapus Log?', 
    'Apakah Anda yakin ingin menghapus log ini secara permanen?', 
    'error', 
    async () => {
      try {
        // Axios DELETE
        await axios.delete(`/logs?id=eq.${id}`)
        
        await fetchLogs()
        triggerPopup('Berhasil!', 'Log bug telah dihapus dari sistem.', 'success')
      } catch (error) {
        console.error('Error deleting log:', error.message)
        triggerPopup('Gagal!', 'Gagal menghapus log: ' + error.message, 'error')
      }
    },
    true
  )
}

const postComment = async (content) => {
  const text = content ? content.toString() : ''
  if ((!text.trim() && !commentAttachment.value) || !selectedLog.value) return

  // Validate User
  const userId = currentUserId.value
  if (!userId) {
    triggerPopup('Gagal!', 'Anda harus login untuk mengirim komentar.', 'error')
    return
  }

  isSubmitting.value = true

  try {
    let attachmentUrl = null
    
    // Upload file if exists
    if (commentAttachment.value) {
      const file = commentAttachment.value
      const fileExt = file.name.split('.').pop()
      const fileName = `${Date.now()}_${Math.random().toString(36).substring(2)}.${fileExt}`
      const filePath = `forum/${selectedLog.value.id}/${fileName}`
      
      const { error: uploadError } = await supabase.storage
        .from('forum-attachments')
        .upload(filePath, file)
        
      if (uploadError) throw uploadError
      
      const { data: { publicUrl } } = supabase.storage
        .from('forum-attachments')
        .getPublicUrl(filePath)
        
      attachmentUrl = publicUrl
    }

    // Axios POST for comment
    console.log('Posting comment with payload:', {
      parent_id: selectedLog.value.id,
      parent_type: 'LOG',
      user_id: userId,
      comment_text: text,
      attachment_url: attachmentUrl
    })

    await axios.post('/discussion_forum', {
      parent_id: selectedLog.value.id,
      parent_type: 'LOG',
      user_id: userId,
      comment_text: text,
      attachment_url: attachmentUrl,
      created_at: new Date().toISOString()
    })

    commentContent.value = ''
    commentAttachment.value = null
    attachmentPreview.value = null
    fetchComments(selectedLog.value.id)
  } catch (error) {
    console.error('Error posting comment:', error)
    let errorMessage = error.message
    if (error.response?.data) {
      errorMessage = error.response.data.message || JSON.stringify(error.response.data)
    }
    triggerPopup('Gagal!', 'Gagal mengirim komentar: ' + errorMessage, 'error')
  } finally {
    isSubmitting.value = false
  }
}

const handleFileSelect = (event) => {
  const file = event.target.files[0]
  if (!file) return
  processFile(file)
}

const handlePaste = (event) => {
  const items = (event.clipboardData || event.originalEvent.clipboardData).items
  for (const item of items) {
    if (item.type.indexOf('image') !== -1) {
      const file = item.getAsFile()
      processFile(file)
      event.preventDefault() // Prevent default paste if image
      return
    }
  }
}

const processFile = (file) => {
  // Validate file size (max 5MB)
  if (file.size > 5 * 1024 * 1024) {
    triggerPopup('File Terlalu Besar', 'Maksimal ukuran file adalah 5MB.', 'error')
    return
  }
  
  commentAttachment.value = file
  
  // Create preview
  const reader = new FileReader()
  reader.onload = (e) => {
    attachmentPreview.value = e.target.result
  }
  reader.readAsDataURL(file)
}

const removeAttachment = () => {
  commentAttachment.value = null
  attachmentPreview.value = null
  if (fileInput.value) fileInput.value.value = ''
}

const handleFileUpload = async (event) => {
  if (!['Editor', 'Admin', 'Super Admin'].includes(currentUserRole.value)) {
    triggerPopup('Akses Ditolak', 'Anda tidak memiliki izin untuk mengimpor data.', 'error')
    return
  }
  const file = event.target.files[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = async (e) => {
    try {
      const content = e.target.result
      const lines = content.split('\n')
      const headers = lines[0].split(',').map(h => h.trim().toLowerCase())
      
      const requiredHeaders = ['module', 'version', 'found_date', 'priority', 'status', 'actual_behavior', 'expected_behavior', 'severity_details']
      const missingHeaders = requiredHeaders.filter(h => !headers.includes(h))
      
      if (missingHeaders.length > 0) {
        throw new Error(`Format file tidak valid. Header berikut hilang: ${missingHeaders.join(', ')}`)
      }

      const logsToInsert = []
      // Get starting no_lap
      let currentMaxNoLap = await getNextNoLap() - 1 // Start from last known
      
      for (let i = 1; i < lines.length; i++) {
        if (!lines[i].trim()) continue
        
        const values = lines[i].split(',').map(v => v.trim())
        const log = {}
        headers.forEach((header, index) => {
          log[header] = values[index]
        })
        
        const { dbPriority, dbStatus } = mapToDbValues(log)
        currentMaxNoLap++

        logsToInsert.push({
          project_id: parseInt(log.project_id || defaultProjectId.value),
          no_lap: parseInt(currentMaxNoLap),
          module: log.module,
          version: log.version,
          found_date: log.found_date,
          priority: dbPriority,
          status: dbStatus,
          reporter_id: currentUser.value?.id || null,
          actual_behavior: log.actual_behavior,
          expected_behavior: log.expected_behavior,
          severity_details: log.severity_details,
          attachment_link: log.attachment_link || null
        })
      }

      if (logsToInsert.length === 0) {
        throw new Error('File kosong atau tidak ada data untuk diimpor.')
      }

      triggerPopup(
        'Konfirmasi Import', 
        `Anda akan mengimpor ${logsToInsert.length} data log. Lanjutkan?`, 
        'warning', 
        async () => {
          loading.value = true
          try {
            await axios.post('/logs', logsToInsert)
            
            triggerPopup('Berhasil!', `${logsToInsert.length} data log telah berhasil diimpor.`, 'success')
            navigateTo('all')
            await fetchLogs()
          } catch (error) {
            console.error('Error importing logs:', error.message)
            triggerPopup('Gagal!', 'Gagal mengimpor data: ' + error.message, 'error')
          } finally {
            loading.value = false
          }
        },
        true
      )
    } catch (error) {
      console.error('Error reading file:', error.message)
      triggerPopup('Error!', error.message, 'error')
    }
  }
  reader.readAsText(file)
}

const exportLogs = () => {
  const headers = ['no_lap', 'module', 'version', 'found_date', 'priority', 'status', 'actual_behavior', 'expected_behavior', 'severity_details', 'attachment_link', 'reporter']
  const csvRows = logs.value.map(log => [
    log.no_lap,
    log.module,
    log.version,
    log.found_date,
    log.priority,
    log.status,
    `"${(log.actual_behavior || '').replace(/"/g, '""')}"`,
    `"${(log.expected_behavior || '').replace(/"/g, '""')}"`,
    `"${(log.severity_details || '').replace(/"/g, '""')}"`,
    log.attachment_link || '',
    log.reporter?.full_name || 'Unknown'
  ].join(','))
  
  const csvContent = "data:text/csv;charset=utf-8," + headers.join(",") + "\n" + csvRows.join("\n")
  const encodedUri = encodeURI(csvContent)
  const link = document.createElement("a")
  link.setAttribute("href", encodedUri)
  link.setAttribute("download", `logs_export_${new Date().toISOString().split('T')[0]}.csv`)
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

const downloadTemplate = () => {
  const headers = ['module', 'version', 'found_date', 'priority', 'status', 'actual_behavior', 'expected_behavior', 'severity_details', 'attachment_link']
  const csvContent = "data:text/csv;charset=utf-8," + headers.join(",") + "\n" +
    "Auth & Login,v2.4.2," + new Date().toISOString() + ",high,report,User cannot login with valid credentials,User should be redirected to dashboard,Critical login blocker issue,https://drive.google.com/example"
  
  const encodedUri = encodeURI(csvContent)
  const link = document.createElement("a")
  link.setAttribute("href", encodedUri)
  link.setAttribute("download", "log_template.csv")
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

// --- COMPUTED ---
const statusStats = computed(() => {
  const stats = {
    report: 0,
    'to do': 0,
    'on progres': 0,
    pending: 0,
    done: 0,
    reject: 0
  }
  logs.value.forEach(log => {
    let s = log.status?.toLowerCase()
    if (s === 'on progress') s = 'on progres' // Normalize typo
    if (s === 'todo') s = 'to do' // Normalize todo
    if (stats[s] !== undefined) {
      stats[s]++
    }
  })
  return stats
})

const myLogsCount = computed(() => {
  if (!currentUserId.value) return 0
  return logs.value.filter(log => log.reporter_id === currentUserId.value).length
})

const handleStatusClick = (status) => {
  filterMyLogs.value = false
  if (filterStatus.value === status) {
    filterStatus.value = 'All'
  } else {
    filterStatus.value = status
  }
}

const handleMyLogsClick = () => {
  filterStatus.value = 'All'
  filterMyLogs.value = !filterMyLogs.value
}

const chartData = computed(() => ({
  labels: ['Report', 'To Do', 'On Progress', 'Pending', 'Done', 'Reject'],
  datasets: [
    {
      backgroundColor: ['#EAB308', '#3B82F6', '#A855F7', '#F97316', '#22C55E', '#EF4444'],
      data: [
        statusStats.value.report,
        statusStats.value['to do'],
        statusStats.value['on progres'],
        statusStats.value.pending,
        statusStats.value.done,
        statusStats.value.reject
      ]
    }
  ]
}))

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        usePointStyle: true,
        padding: 20,
        font: { size: 12 }
      }
    },
    tooltip: {
      callbacks: {
        label: (context) => {
          const label = context.label || ''
          const value = context.raw || 0
          const total = context.dataset.data.reduce((a, b) => a + b, 0)
          const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0
          return `${label}: ${value} (${percentage}%)`
        }
      }
    }
  }
}

const filteredLogs = computed(() => {
  return logs.value.filter(log => {
    // 1. Search Filter
    if (searchQuery.value) {
      const q = searchQuery.value.toLowerCase()
      const inModule = log.module?.toLowerCase().includes(q)
      const inActual = log.actual_behavior?.toLowerCase().includes(q)
      const inExpected = log.expected_behavior?.toLowerCase().includes(q)
      if (!inModule && !inActual && !inExpected) return false
    }

    // 2. Status Filter
    if (filterStatus.value !== 'All') {
      let sValue = filterStatus.value
      if (sValue === 'on progress') sValue = 'on progres'
      if (sValue === 'todo') sValue = 'to do'
      
      let logStatus = log.status?.toLowerCase()
      if (logStatus === 'on progress') logStatus = 'on progres'
      if (logStatus === 'todo') logStatus = 'to do'
      
      if (logStatus !== sValue) return false
    }

    // 3. Priority Filter
    if (filterPriority.value !== 'All') {
      let pValue = filterPriority.value
      if (pValue === 'high') pValue = 'hight'
      if (pValue === 'critical') pValue = 'critikal'

      let logPriority = log.priority?.toLowerCase()
      if (logPriority === 'high') logPriority = 'hight'
      if (logPriority === 'critical') logPriority = 'critikal'

      if (logPriority !== pValue) return false
    }

    // 4. My Logs Filter
    if (filterMyLogs.value) {
      if (log.reporter_id !== currentUserId.value) return false
    }

    return true
  })
})

const paginatedLogs = computed(() => {
  const start = (currentPage.value - 1) * rowsPerPage.value
  const end = start + rowsPerPage.value
  return filteredLogs.value.slice(start, end)
})

// --- HELPERS ---
const getStatusBadgeClass = (status) => {
  const s = status?.toLowerCase()
  switch (s) {
    case 'report': return 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400 border-yellow-200'
    case 'todo':
    case 'to do': return 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 border-blue-200'
    case 'on progres':
    case 'on progress': return 'bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400 border-purple-200'
    case 'pending': return 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400 border-orange-200'
    case 'done': return 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400 border-green-200'
    case 'reject': return 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400 border-red-200'
    default: return 'bg-gray-100 text-gray-700 dark:bg-gray-900/30 dark:text-gray-400 border-gray-200'
  }
}

const getPriorityBadgeClass = (priority) => {
  const p = priority?.toLowerCase()
  switch (p) {
    case 'low': return 'bg-yellow-50 text-yellow-600 dark:bg-yellow-900/10 dark:text-yellow-500 border-yellow-200/50'
    case 'medium': return 'bg-orange-100 text-orange-700 dark:bg-orange-900/20 dark:text-orange-400 border-orange-200/50'
    case 'high':
    case 'hight': return 'bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400 border-red-200/50'
    case 'critical':
    case 'critikal': return 'bg-red-600 text-white dark:bg-red-700 dark:text-red-50 border-red-500'
    default: return 'bg-gray-50 text-gray-600 border-gray-200/50'
  }
}

const formatDate = (date) => {
  if (!date) return { date: '-', time: '-' }
  const d = new Date(date)
  return {
    date: d.toLocaleDateString('id-ID', { 
      day: '2-digit', 
      month: 'short', 
      year: 'numeric' 
    }),
    time: d.toLocaleTimeString('id-ID', {
      hour: '2-digit',
      minute: '2-digit'
    })
  }
}

onMounted(async () => {
  if (authStore.loading) {
    await authStore.initialize()
  }
  await checkAuth()
  await fetchDefaultProject()
  await fetchProfiles() // Load profiles for default project
  await fetchLogs()

  // Check for detailId query param
  if (route.query.detailId) {
    const logId = parseInt(route.query.detailId)
    const log = logs.value.find(l => l.id === logId)
    if (log) {
      navigateTo('detail', log)
    } else {
      // Try to fetch specific log if not found in current list
      try {
        const { data } = await axios.get(`/logs?id=eq.${logId}&select=*,reporter:profiles!reporter_id(full_name,avatar_url)`)
        if (data && data.length > 0) {
          navigateTo('detail', data[0])
        }
      } catch (e) {
        console.error('Error fetching specific log details:', e)
      }
    }
  }
})
</script>

<template>
  <div class="max-w-[1600px] mx-auto space-y-6">
    <!-- ALL LOGS VIEW -->
    <div v-if="currentView === 'all'" class="animate-in fade-in duration-500">
      <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
        <div class="flex flex-col gap-1">
          <h2 class="text-[#121417] dark:text-white text-2xl font-extrabold tracking-tight">
            All Logs Management
          </h2>
          <p class="text-gray-500 dark:text-gray-400 text-sm">
            Comprehensive list of all tracked bugs, errors, and system logs.
          </p>
        </div>
        <div class="flex gap-3">
          <button 
            @click="exportLogs"
            class="flex items-center justify-center gap-2 h-10 px-4 rounded-lg bg-white dark:bg-[#252525] border border-gray-200 dark:border-gray-700 text-[#121417] dark:text-white text-sm font-semibold shadow-sm hover:bg-gray-50 dark:hover:bg-[#2a2a2a] transition-all"
          >
            <span class="material-symbols-outlined text-[20px]">download</span>
            <span>Export CSV</span>
          </button>
          <button 
            v-if="['Editor', 'Admin', 'Super Admin'].includes(currentUserRole)"
            @click="navigateTo('import')"
            class="flex items-center justify-center gap-2 h-10 px-4 rounded-lg bg-white dark:bg-[#252525] border border-gray-200 dark:border-gray-700 text-[#121417] dark:text-white text-sm font-semibold shadow-sm hover:bg-gray-50 dark:hover:bg-[#2a2a2a] transition-all"
          >
            <span class="material-symbols-outlined text-[20px]">file_upload</span>
            <span>Import New Log</span>
          </button>
          <button 
            v-if="['Editor', 'Admin', 'Super Admin'].includes(currentUserRole)"
            @click="navigateTo('add')"
            class="flex items-center justify-center gap-2 h-10 px-5 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-sm font-semibold shadow-md transition-all"
          >
            <span class="material-symbols-outlined text-[20px]">add</span>
            <span>Add New Log</span>
          </button>
        </div>
      </div>

      <!-- SEARCH & FILTER BAR -->
      <div class="flex flex-col md:flex-row gap-4 mb-6">
        <div class="flex-1 relative">
          <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
            <span class="material-symbols-outlined text-gray-500 text-[22px]">search</span>
          </div>
          <input 
            v-model="searchQuery"
            type="text" 
            placeholder="Search logs by ID, module, or keyword..." 
            class="w-full h-12 pl-12 pr-4 bg-white dark:bg-[#1e1e1e] border border-gray-200 dark:border-gray-800 rounded-lg text-sm focus:ring-2 focus:ring-emerald-500/20 transition-all dark:text-white outline-none"
          />
        </div>
        <div class="flex flex-wrap gap-2">
          <button 
            @click="showCharts = !showCharts"
            class="flex items-center justify-center gap-2 h-12 px-4 rounded-lg bg-white dark:bg-[#1e1e1e] border border-gray-200 dark:border-gray-800 text-gray-700 dark:text-gray-300 text-sm font-semibold shadow-sm hover:bg-gray-50 dark:hover:bg-[#252525] transition-all"
            :class="{'ring-2 ring-emerald-500/20 border-emerald-500/50': showCharts}"
          >
            <span class="material-symbols-outlined text-[20px]">{{ showCharts ? 'bar_chart_off' : 'bar_chart' }}</span>
            <span>Stats</span>
          </button>
          <!-- Project Filter (Super Admin/Admin Only) HILANGKAN SAJA KARENA TIDAK BERGUNA-->
          <!-- <div v-if="['Super Admin', 'Admin'].includes(currentUserRole)" class="relative h-12 min-w-[160px]">
            <select 
              v-model="filterProject"
              class="w-full h-full pl-10 pr-8 bg-white dark:bg-[#1e1e1e] border border-gray-200 dark:border-gray-800 rounded-lg text-sm font-semibold text-gray-700 dark:text-gray-300 focus:ring-2 focus:ring-emerald-500/20 appearance-none transition-all cursor-pointer outline-none"
            >
              <option value="All">All Projects</option>
              <option v-for="project in projects" :key="project.id" :value="project.id">{{ project.name }}</option>
            </select>
            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[20px] text-gray-500 pointer-events-none">folder_open</span>
            <span class="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-[18px] text-gray-400 pointer-events-none">expand_more</span>
          </div> --> 
          <div class="relative h-12 min-w-[140px]">
            <select 
              v-model="filterStatus"
              class="w-full h-full pl-10 pr-8 bg-white dark:bg-[#1e1e1e] border border-gray-200 dark:border-gray-800 rounded-lg text-sm font-semibold text-gray-700 dark:text-gray-300 focus:ring-2 focus:ring-emerald-500/20 appearance-none transition-all cursor-pointer outline-none"
            >
              <option v-for="status in statuses" :key="status" :value="status">{{ status === 'All' ? 'All Status' : status }}</option>
            </select>
            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[20px] text-gray-500 pointer-events-none">filter_list</span>
            <span class="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-[18px] text-gray-400 pointer-events-none">expand_more</span>
          </div>
          <div class="relative h-12 min-w-[140px]">
            <select 
              v-model="filterPriority"
              class="w-full h-full pl-10 pr-8 bg-white dark:bg-[#1e1e1e] border border-gray-200 dark:border-gray-800 rounded-lg text-sm font-semibold text-gray-700 dark:text-gray-300 focus:ring-2 focus:ring-emerald-500/20 appearance-none transition-all cursor-pointer outline-none"
            >
              <option v-for="prio in priorities" :key="prio" :value="prio">{{ prio === 'All' ? 'All Priority' : prio }}</option>
            </select>
            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[20px] text-gray-500 pointer-events-none">priority_high</span>
            <span class="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-[18px] text-gray-400 pointer-events-none">expand_more</span>
          </div>
          <div class="relative h-12 min-w-[140px]">
            <select 
              v-model="sortBy"
              class="w-full h-full pl-10 pr-8 bg-white dark:bg-[#1e1e1e] border border-gray-200 dark:border-gray-800 rounded-lg text-sm font-semibold text-gray-700 dark:text-gray-300 focus:ring-2 focus:ring-emerald-500/20 appearance-none transition-all cursor-pointer outline-none"
            >
              <option value="newest">Terbaru</option>
              <option value="oldest">Terlama</option>
            </select>
            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[20px] text-gray-500 pointer-events-none">sort</span>
            <span class="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-[18px] text-gray-400 pointer-events-none">expand_more</span>
          </div>
        </div>
      </div>

      <!-- CHARTS SECTION -->
      <div v-if="showCharts" class="grid grid-cols-1 md:grid-cols-12 gap-6 mb-6 animate-in fade-in zoom-in duration-300">
        <!-- Status Distribution -->
        <div class="md:col-span-3 bg-white dark:bg-[#1e1e1e] p-6 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm flex flex-col">
          <h4 class="text-sm font-bold text-slate-700 dark:text-gray-300 mb-4 flex items-center gap-2">
            <span class="material-symbols-outlined text-emerald-500">pie_chart</span>
            Status Distribution
          </h4>
          <div class="h-[200px] flex-1">
            <Pie :data="chartData" :options="chartOptions" />
          </div>
        </div>

        <!-- Summary Count -->
        <div class="md:col-span-6 bg-white dark:bg-[#1e1e1e] p-6 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm">
          <h4 class="text-sm font-bold text-slate-700 dark:text-gray-300 mb-4 flex items-center gap-2">
            <span class="material-symbols-outlined text-blue-500">bar_chart</span>
            Summary Count
          </h4>
          <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
            <div v-for="(count, status) in statusStats" :key="status" 
              @click="handleStatusClick(status)"
              class="flex flex-col items-center justify-center p-4 rounded-lg border transition-all cursor-pointer group"
              :class="[
                filterStatus === status 
                  ? 'bg-blue-50 border-blue-200 dark:bg-blue-900/20 dark:border-blue-800 ring-2 ring-blue-500/20' 
                  : 'border-slate-100 dark:border-gray-800/50 bg-slate-50/50 dark:bg-gray-800/20 hover:bg-white dark:hover:bg-gray-800/40 hover:shadow-md'
              ]"
            >
              <span class="text-2xl font-black transition-transform group-hover:scale-110" 
                :class="filterStatus === status ? 'text-blue-600 dark:text-blue-400' : 'text-slate-800 dark:text-white'"
              >
                {{ count }}
              </span>
              <span :class="getStatusBadgeClass(status)" class="mt-2 px-2 py-0.5 rounded text-[9px] font-bold uppercase tracking-wider border">
                {{ status }}
              </span>
            </div>
          </div>
        </div>

        <!-- My Log Section -->
        <div class="md:col-span-3 bg-white dark:bg-[#1e1e1e] p-6 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm flex flex-col">
          <h4 class="text-sm font-bold text-slate-700 dark:text-gray-300 mb-4 flex items-center gap-2">
            <span class="material-symbols-outlined text-purple-500">person</span>
            My Activity
          </h4>
          <div 
            @click="handleMyLogsClick"
            class="flex-1 flex flex-col items-center justify-center p-6 rounded-xl border transition-all cursor-pointer group"
            :class="[
              filterMyLogs 
                ? 'bg-purple-50 border-purple-200 dark:bg-purple-900/20 dark:border-purple-800 ring-2 ring-purple-500/20' 
                : 'border-slate-100 dark:border-gray-800/50 bg-slate-50/50 dark:bg-gray-800/20 hover:bg-white dark:hover:bg-gray-800/40 hover:shadow-md'
            ]"
          >
            <div class="relative mb-3">
              <span class="text-4xl font-black transition-transform group-hover:scale-110 block"
                :class="filterMyLogs ? 'text-purple-600 dark:text-purple-400' : 'text-slate-800 dark:text-white'"
              >
                {{ myLogsCount }}
              </span>
              <div v-if="filterMyLogs" class="absolute -top-1 -right-1 w-2 h-2 bg-purple-500 rounded-full animate-ping"></div>
            </div>
            <span class="px-3 py-1 rounded-full bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 text-[10px] font-bold uppercase tracking-widest border border-purple-200 dark:border-purple-800">
              MY LOGS
            </span>
            <p class="mt-4 text-[11px] text-slate-500 dark:text-gray-400 text-center leading-relaxed">
              {{ filterMyLogs ? 'Menampilkan log yang Anda laporkan' : 'Klik untuk melihat log yang Anda laporkan' }}
            </p>
          </div>
        </div>
      </div>

      <!-- TABLE CONTENT -->
      <div class="bg-white dark:bg-[#1e1e1e] rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm overflow-hidden flex flex-col">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-sm border-collapse">
            <thead class="bg-slate-50 dark:bg-[#1a1a1a]/50 text-slate-500 dark:text-slate-400 text-[11px] uppercase font-bold tracking-wider">
              <tr class="border-b border-gray-100 dark:border-gray-800">
                <th class="px-6 py-4">No</th>
                <th class="px-6 py-4">Tanggal</th>
                <th class="px-6 py-4">Modul</th>
                <th class="px-6 py-4">Status</th>
                <th class="px-6 py-4">Prioritas</th>
                <th class="px-6 py-4">Pelapor</th>
                <th class="px-6 py-4 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 dark:divide-gray-800/50">
              <tr v-if="loading" v-for="i in 5" :key="i" class="animate-pulse">
                <td v-for="j in 7" :key="j" class="px-6 py-4">
                  <div class="h-4 bg-slate-100 dark:bg-[#252525] rounded w-full"></div>
                </td>
              </tr>
              <tr v-else-if="filteredLogs.length === 0" class="text-center">
                <td colspan="7" class="px-6 py-12">
                  <div class="flex flex-col items-center gap-2 text-slate-400">
                    <span class="material-symbols-outlined text-4xl">search_off</span>
                    <p class="font-medium">Tidak ada log yang ditemukan</p>
                  </div>
                </td>
              </tr>
              <tr v-for="(log, index) in paginatedLogs" :key="log.id" 
                @click="navigateTo('detail', log)"
                class="hover:bg-slate-50 dark:hover:bg-[#1a1a1a]/50 transition-colors group cursor-pointer"
              >
                <td class="px-6 py-4 font-medium text-slate-500 dark:text-slate-400">
                  {{ (currentPage - 1) * rowsPerPage + index + 1 }}
                </td>
                <td class="px-6 py-4">
                  <div class="text-black dark:text-white font-medium">{{ formatDate(log.created_at).date }}</div>
                  <div class="text-[10px] text-gray-500 dark:text-gray-400">{{ formatDate(log.created_at).time }}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="font-bold text-black dark:text-white mb-0.5 truncate max-w-[200px]">
                    {{ log.module }}
                  </div>
                  <div class="text-[10px] text-gray-500 dark:text-gray-400 font-medium">ID: #{{ log.id.toString().slice(0,8) }}</div>
                </td>
                <td class="px-6 py-4 relative status-dropdown-container">
                  <div class="flex items-center gap-2">
                    <span :class="getStatusBadgeClass(log.status)" class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold border uppercase tracking-wider">
                      {{ log.status }}
                    </span>
                    <button 
                      v-if="['Super Admin', 'Admin', 'Editor'].includes(currentUserRole)"
                      @click.stop="toggleDropdown(log.id)"
                      class="p-1 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 transition-colors"
                    >
                      <span class="material-symbols-outlined text-[16px]">expand_more</span>
                    </button>
                  </div>
                  
                  <!-- Dropdown Menu -->
                  <div 
                    v-if="openDropdownId === log.id"
                    class="absolute left-6 top-10 z-50 w-40 bg-white dark:bg-[#1e1e1e] rounded-lg shadow-xl border border-slate-200 dark:border-gray-700 py-1 animate-in fade-in zoom-in duration-200"
                  >
                    <button
                      v-for="status in statuses.filter(s => s !== 'All')"
                      :key="status"
                      @click.stop="updateLogStatus(log.id, status)"
                      class="w-full text-left px-4 py-2 text-xs text-slate-700 dark:text-slate-300 hover:bg-slate-50 dark:hover:bg-slate-800 flex items-center gap-2"
                      :class="{'bg-slate-50 dark:bg-slate-800 font-medium': log.status === status}"
                    >
                      <span :class="getStatusBadgeClass(status)" class="w-2 h-2 rounded-full block border-0"></span>
                      {{ status }}
                    </button>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <span :class="getPriorityBadgeClass(log.priority)" class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold border uppercase tracking-wider">
                    {{ log.priority }}
                  </span>
                </td>
                <td class="px-6 py-4">
                  <div class="flex items-center gap-2">
                    <img 
                      v-if="log.reporter?.avatar_url" 
                      :src="log.reporter.avatar_url" 
                      class="w-6 h-6 rounded-full border border-gray-200 dark:border-gray-700"
                    />
                    <div v-else class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center text-[10px] font-bold text-emerald-600">
                      {{ log.reporter?.full_name?.charAt(0) || '?' }}
                    </div>
                    <span class="text-black dark:text-white font-medium">{{ log.reporter?.full_name || 'System' }}</span>
                  </div>
                </td>
                <td class="px-6 py-4 text-right">
                  <div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button 
                      v-if="['Editor', 'Admin', 'Super Admin'].includes(currentUserRole)"
                      @click.stop="navigateTo('edit', log)"
                      class="p-2 text-slate-400 hover:text-blue-800 hover:bg-blue-200 dark:hover:bg-blue-900/20 rounded-lg transition-all"
                      title="Edit Log"
                    >
                      <span class="material-symbols-outlined text-lg">edit</span>
                    </button>
                    <button 
                      v-if="['Editor', 'Admin', 'Super Admin'].includes(currentUserRole)"
                      @click.stop="deleteLog(log.id)"
                      class="p-2 text-slate-400 hover:text-red-600 hover:bg-red-200 dark:hover:bg-red-900/20 rounded-lg transition-all"
                      title="Hapus Log"
                    >
                      <span class="material-symbols-outlined text-lg">delete</span>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- PAGINATION -->
        <div class="px-6 py-4 border-t border-gray-100 dark:border-gray-800 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div class="flex items-center gap-4">
            <p class="text-xs text-gray-500">
              Showing {{ (currentPage - 1) * rowsPerPage + 1 }} to {{ Math.min(currentPage * rowsPerPage, filteredLogs.length) }} of {{ filteredLogs.length }} logs
            </p>
            <div class="flex items-center gap-2">
              <span class="text-xs text-gray-500">Rows:</span>
              <select v-model="rowsPerPage" class="bg-transparent border-none text-xs font-bold text-gray-500 focus:ring-0 cursor-pointer outline-none">
                <option :value="20">20</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>
          <div class="flex gap-2">
            <button 
              @click="currentPage--" 
              :disabled="currentPage === 1"
              class="px-4 py-2 rounded-lg border border-gray-200 dark:border-gray-800 text-xs font-bold text-gray-500 hover:bg-gray-50 dark:hover:bg-gray-800 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Previous
            </button>
            <button 
              @click="currentPage++" 
              :disabled="currentPage * rowsPerPage >= filteredLogs.length"
              class="px-4 py-2 rounded-lg border border-gray-200 dark:border-gray-800 text-xs font-bold text-gray-500 hover:bg-gray-50 dark:hover:bg-gray-800 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Next
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ADD / EDIT LOG VIEW -->
    <div v-else-if="currentView === 'add' || currentView === 'edit'" class="max-w-5xl mx-auto animate-in slide-in-from-top-4 duration-300">
      <button 
        @click="navigateTo('all')"
        class="flex items-center gap-2 text-sm text-gray-500 hover:text-emerald-600 mb-6 transition-colors"
      >
        <span class="material-symbols-outlined text-sm">arrow_back</span>
        <span>Kembali ke Daftar Log</span>
      </button>
      
      <form 
        @submit.prevent="handleSaveLog"
        novalidate
        class="space-y-8 bg-white dark:bg-[#1e1e1e] rounded-lg border border-gray-200 dark:border-gray-800 shadow-sm overflow-hidden"
      >
        <div class="bg-gray-50 dark:bg-[#252525] px-8 py-6 border-b border-gray-200 dark:border-gray-800">
          <h3 class="text-lg font-bold text-black dark:text-white">
            {{ currentView === 'add' ? 'Formulir Log Bug Baru' : 'Edit Data Log Bug' }}
          </h3>
          <p class="text-sm text-gray-700 dark:text-gray-300">
            Isi detail lengkap bug untuk membantu tim pengembang dalam proses perbaikan.
          </p>
        </div>

        <div class="p-8 space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div class="space-y-2">
              <label class="text-sm font-semibold text-black dark:text-white">No. Laporan</label>
              <input 
                type="text" 
                :value="currentView === 'add' ? 'Otomatis' : logForm.no_lap"
                class="w-full rounded-lg border-gray-200 bg-gray-50 dark:bg-[#1a1a1a] dark:border-gray-700 text-black dark:text-gray-400 cursor-not-allowed text-sm"
                disabled
              />
            </div>
            <div class="space-y-2">
              <label class="text-sm font-semibold text-black dark:text-white">Versi</label>
              <input 
                v-model="logForm.version"
                type="text" 
                placeholder="v2.4.2" 
                class="w-full rounded-lg border-gray-200 bg-white dark:bg-[#121417] dark:border-gray-700 text-black dark:text-white text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                required
              />
            </div>
            <div class="space-y-2">
              <label class="text-sm font-semibold text-black dark:text-white">Tanggal Temuan</label>
              <input 
                v-model="logForm.found_date"
                type="datetime-local" 
                class="w-full rounded-lg border-gray-200 bg-white dark:bg-[#121417] dark:border-gray-700 text-black dark:text-white text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                required
              />
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="space-y-2">
              <label class="text-sm font-semibold text-black dark:text-white">Modul / Area</label>
              <input 
                v-model="logForm.module"
                type="text" 
                placeholder="Contoh: Modul Pembayaran" 
                class="w-full rounded-lg border-gray-200 bg-white dark:bg-[#121417] dark:border-gray-700 text-black dark:text-white text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                required
              />
            </div>
            <div class="space-y-2">
              <label class="text-sm font-semibold text-black dark:text-white">Prioritas</label>
              <select 
                v-model="logForm.priority"
                class="w-full rounded-lg border-gray-200 bg-white dark:bg-[#121417] dark:border-gray-700 text-black dark:text-white text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
              >
                <option value="low">🟡 Low</option>
                <option value="medium">🟠 Medium</option>
                <option value="high">🔴 High</option>
                <option value="critical">🔥 Critical</option>
              </select>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="space-y-2">
              <label class="text-sm font-semibold text-black dark:text-white">Hasil Aktual</label>
              <textarea 
                v-model="logForm.actual_behavior"
                rows="4" 
                placeholder="Jelaskan apa yang sebenarnya terjadi..." 
                class="w-full rounded-lg border-gray-200 bg-white dark:bg-[#121417] dark:border-gray-700 text-black dark:text-white text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                required
              ></textarea>
            </div>
            <div class="space-y-2">
              <label class="text-sm font-semibold text-black dark:text-white">Harapan</label>
              <textarea 
                v-model="logForm.expected_behavior"
                rows="4" 
                placeholder="Jelaskan apa yang seharusnya terjadi..." 
                class="w-full rounded-lg border-gray-200 bg-white dark:bg-[#121417] dark:border-gray-700 text-black dark:text-white text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                required
              ></textarea>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="space-y-6">
              <div class="space-y-2">
                <label class="text-sm font-semibold text-black dark:text-white">Status</label>
                <select 
                  v-model="logForm.status"
                  class="w-full rounded-lg border-gray-200 bg-white dark:bg-[#121417] dark:border-gray-700 text-black dark:text-white text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                >
                  <option value="report">🟡 Report</option>
                  <option value="to do">🔵 To Do</option>
                  <option value="on progres">🟣 In Progress</option>
                  <option value="pending">🟠 Pending</option>
                  <option value="done">🟢 Done</option>
                  <option value="reject">🔴 Reject</option>
                </select>
              </div>
              <div class="space-y-2">
                <label class="text-sm font-semibold text-black dark:text-white">Lampiran (Link G-Drive/Image)</label>
                <input 
                  v-model="logForm.attachment_link"
                  type="url" 
                  placeholder="https://..." 
                  class="w-full rounded-lg border-gray-200 bg-white dark:bg-[#121417] dark:border-gray-700 text-gray-600 dark:text-white text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                />
              </div>

              <!-- Field Pelapor Baru -->
              <div class="space-y-2">
                <label class="text-sm font-semibold text-black dark:text-white flex items-center gap-2">
                  <span class="material-symbols-outlined text-xs">person</span>
                  Pelapor
                </label>
                <select 
                  v-model="logForm.reporter_id"
                  class="w-full rounded-lg border-gray-200 bg-white dark:bg-[#121417] dark:border-gray-700 text-black dark:text-white text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                >
                  <option value="" disabled>-- Pilih Pelapor --</option>
                  <option v-for="profile in allProfiles" :key="profile.id" :value="profile.id">
                    {{ profile.full_name || profile.email || 'Tanpa Nama' }} {{ profile.id === currentUserId ? '(Saya)' : '' }}
                  </option>
                </select>
                <p class="text-[10px] text-gray-400 italic">
                  * Pilih user yang melaporkan bug ini (Default: Akun Login)
                </p>
              </div>
            </div>
            <div class="space-y-2">
              <label class="text-sm font-semibold text-black dark:text-white">Tingkat Keparahan / Detail Teknis</label>
              <textarea 
                v-model="logForm.severity_details"
                rows="12" 
                placeholder="Jelaskan tingkat keparahan atau detail teknis tambahan..." 
                class="w-full rounded-lg border-gray-200 bg-white dark:bg-[#121417] dark:border-gray-700 text-black dark:text-white text-sm focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all"
                required
              ></textarea>
            </div>
          </div>

          <div class="flex justify-end gap-3 pt-6 border-t border-gray-100 dark:border-gray-800">
            <button 
              type="button" 
              @click="navigateTo('all')"
              class="px-6 py-2.5 rounded-lg border border-gray-200 dark:border-gray-700 text-gray-600 dark:text-gray-400 text-sm font-semibold hover:bg-gray-50 dark:hover:bg-gray-800 transition-all"
            >
              Batal
            </button>
            <button 
              type="submit"
              :disabled="isSubmitting"
              class="px-8 py-2.5 rounded-lg bg-emerald-600 text-white text-sm font-semibold shadow-lg hover:bg-emerald-500 transition-all flex items-center justify-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed"
            >
              <span v-if="isSubmitting" class="material-symbols-outlined animate-spin text-sm">progress_activity</span>
              {{ currentView === 'add' ? 'Simpan Log Bug' : 'Update Log Bug' }}
            </button>
          </div>
        </div>
      </form>
    </div>

    <!-- DETAIL LOG VIEW -->
    <div v-else-if="currentView === 'detail' && selectedLog" class="max-w-7xl mx-auto space-y-6 animate-in slide-in-from-right-4 duration-300">
      <div class="flex items-center justify-between">
        <button 
          @click="navigateTo('all')"
          class="flex items-center gap-2 text-sm text-gray-500 hover:text-emerald-600 transition-colors"
        >
          <span class="material-symbols-outlined text-sm">arrow_back</span>
          <span>Kembali</span>
        </button>
        <div v-if="['Editor', 'Admin', 'Super Admin'].includes(currentUserRole)" class="flex gap-2">
          <button 
            @click="navigateTo('edit', selectedLog)"
            class="flex items-center gap-2 px-4 py-2 bg-white dark:bg-[#252525] border border-gray-200 dark:border-gray-700 rounded-lg text-sm font-semibold dark:text-white hover:bg-gray-50 dark:hover:bg-[#2a2a2a] transition-all"
          >
            <span class="material-symbols-outlined text-black dark:text-white text-sm">edit</span>
            <span class="text-black dark:text-white">Edit Log</span>
          </button>
        </div>
      </div>

      <!-- Log Header Card -->
      <div class="bg-white dark:bg-[#1e1e1e] rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm overflow-hidden">
        <div class="bg-gray-50 dark:bg-[#252525] px-6 py-4 border-b border-gray-200 dark:border-gray-800 flex flex-wrap items-center gap-4">
          <div class="flex items-center gap-3 mr-auto">
            <span class="text-xl font-black text-emerald-600">#{{ selectedLog.no_lap || selectedLog.id.toString().slice(0,8) }}</span>
            <h2 class="text-xl font-bold dark:text-white">{{ selectedLog.module }}</h2>
          </div>
          <span :class="getStatusBadgeClass(selectedLog.status)" class="px-3 py-1 rounded-full text-xs font-bold uppercase border">
            {{ selectedLog.status }}
          </span>
        </div>
        
        <div class="p-6 grid grid-cols-1 md:grid-cols-3 gap-6 border-b border-gray-100 dark:border-gray-800">
          <div class="space-y-1">
            <p class="text-[10px] uppercase tracking-widest text-gray-700 dark:text-gray-300 font-bold">Versi Sistem</p>
            <p class="text-sm font-semibold text-black dark:text-white">{{ selectedLog.version || '-' }}</p>
          </div>
          <div class="space-y-1">
            <p class="text-[10px] uppercase tracking-widest text-gray-700 dark:text-gray-300 font-bold">Tanggal Ditemukan</p>
            <p class="text-sm font-semibold text-black dark:text-white">{{ formatDate(selectedLog.found_date).date }} {{ formatDate(selectedLog.found_date).time }}</p>
          </div>
          <div class="space-y-1">
            <p class="text-[10px] uppercase tracking-widest text-gray-700 dark:text-gray-300 font-bold">Pelapor</p>
            <div class="flex items-center gap-2">
              <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center text-[10px] font-bold text-emerald-600">
                {{ selectedLog.reporter?.full_name?.charAt(0) || '?' }}
              </div>
              <p class="text-sm font-semibold text-black dark:text-white">{{ selectedLog.reporter?.full_name || 'System' }}</p>
            </div>
          </div>
        </div>

        <div class="p-6 space-y-6">
          <div v-if="selectedLog.severity_details" class="p-4 bg-orange-50/30 dark:bg-orange-900/10 rounded-lg border border-orange-100 dark:border-orange-900/20">
            <h4 class="text-xs font-bold text-orange-600 flex items-center gap-2 mb-2">
              <span class="material-symbols-outlined text-sm">warning</span>
              Tingkat Keparahan / Detail Teknis
            </h4>
            <p class="text-sm text-black dark:text-white leading-relaxed">{{ selectedLog.severity_details }}</p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div class="p-4 bg-red-50/30 dark:bg-red-900/10 rounded-lg border border-red-100 dark:border-red-900/20">
              <h4 class="text-xs font-bold text-red-600 flex items-center gap-2 mb-2">
                <span class="material-symbols-outlined text-sm">error</span>
                Hasil Aktual
              </h4>
              <p class="text-sm text-black dark:text-white leading-relaxed italic">{{ selectedLog.actual_behavior }}</p>
            </div>
            <div class="p-4 bg-emerald-50/30 dark:bg-emerald-900/10 rounded-lg border border-emerald-100 dark:border-emerald-900/20">
              <h4 class="text-xs font-bold text-emerald-600 flex items-center gap-2 mb-2">
                <span class="material-symbols-outlined text-sm">check_circle</span>
                Hasil yang Diharapkan
              </h4>
              <p class="text-sm text-black dark:text-white leading-relaxed italic">{{ selectedLog.expected_behavior }}</p>
            </div>
          </div>
        </div>

        <div v-if="selectedLog.attachment_link" class="px-6 py-4 bg-gray-50/50 dark:bg-[#252525]/50 flex items-center justify-between border-t border-gray-200 dark:border-gray-800">
          <div class="flex items-center gap-2 text-sm text-gray-500">
            <span class="material-symbols-outlined text-sm">attachment</span>
            <span>Lampiran Bukti:</span>
            <a :href="selectedLog.attachment_link" target="_blank" class="text-blue-500 font-medium hover:underline">Lihat Lampiran</a>
          </div>
        </div>
      </div>

      <!-- FORUM & ACTIVITY AREA -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2 space-y-4">
          <div class="flex items-center gap-2 mb-2">
            <h3 class="text-lg font-bold text-black dark:text-white">Forum Diskusi</h3>
            <span class="px-2 py-0.5 bg-gray-200 dark:bg-gray-700 rounded-md text-[10px] font-bold text-black dark:text-gray-300">
              {{ comments.length }} Pesan
            </span>
          </div>

          <div class="space-y-6 flex flex-col">
            <div v-for="comment in comments" :key="comment.id" :class="['flex gap-4', comment.user_id === currentUserId ? 'flex-row-reverse' : '']">
              <div class="w-10 h-10 rounded-full bg-emerald-600 shrink-0 flex items-center justify-center text-white font-bold text-sm shadow-sm overflow-hidden">
                <img v-if="comment.user?.avatar_url" :src="comment.user.avatar_url" class="w-full h-full object-cover" />
                <span v-else>{{ comment.user?.full_name?.charAt(0) || '?' }}</span>
              </div>
              <div :class="['flex-1 max-w-[85%]', comment.user_id === currentUserId ? 'text-right' : '']">
                <div :class="['flex items-center gap-2 mb-1', comment.user_id === currentUserId ? 'justify-end' : '']">
                  <span class="text-sm font-bold dark:text-white">{{ comment.user?.full_name || 'User' }}</span>
                  <span class="text-[10px] text-gray-400">{{ formatDate(comment.created_at).date }} {{ formatDate(comment.created_at).time }}</span>
                </div>
                <div :class="[
                  'p-3 rounded-2xl shadow-sm text-sm text-black dark:text-white inline-block text-left overflow-hidden',
                  comment.user_id === currentUserId 
                    ? 'bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-100 dark:border-emerald-800 rounded-tr-none' 
                    : 'bg-white dark:bg-[#1e1e1e] border border-gray-100 dark:border-gray-800 rounded-tl-none'
                ]">
                  <!-- Attachment Display (WhatsApp Style: Media on top) -->
                  <div v-if="comment.attachment_url" class="mb-2 -mx-3 -mt-3 overflow-hidden border-b border-gray-100 dark:border-gray-800">
                    <a :href="comment.attachment_url" target="_blank" class="block group/media relative">
                      <img 
                        v-if="comment.attachment_url.match(/\.(jpg|jpeg|png|gif|webp)$/i)" 
                        :src="comment.attachment_url" 
                        class="w-full h-auto max-h-[300px] object-cover hover:scale-105 transition-transform duration-500" 
                      />
                      <div v-else class="p-3 flex items-center gap-3 bg-gray-50/50 dark:bg-black/20">
                        <span class="material-symbols-outlined text-emerald-600">description</span>
                        <div class="text-left">
                          <p class="text-xs font-bold text-black dark:text-white">Lampiran File</p>
                          <p class="text-[10px] text-gray-500 truncate max-w-[150px]">Klik untuk melihat</p>
                        </div>
                        <span class="material-symbols-outlined text-sm ml-auto opacity-40">open_in_new</span>
                      </div>
                    </a>
                  </div>

                  <p class="whitespace-pre-wrap break-words">{{ comment.comment_text }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Comment Input -->
          <div class="bg-white dark:bg-[#1e1e1e] p-4 rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm mt-8 sticky bottom-0 z-10">
            <!-- Attachment Preview -->
            <div v-if="attachmentPreview" class="mb-3 p-3 bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 flex items-start justify-between animate-in slide-in-from-bottom-2">
              <div class="flex items-center gap-3">
                <div class="w-16 h-16 rounded overflow-hidden border border-gray-300 dark:border-gray-600 bg-gray-200 dark:bg-gray-700">
                  <img v-if="commentAttachment?.type?.startsWith('image/')" :src="attachmentPreview" class="w-full h-full object-cover" />
                  <div v-else class="w-full h-full flex items-center justify-center text-gray-500">
                    <span class="material-symbols-outlined">description</span>
                  </div>
                </div>
                <div class="text-sm">
                  <p class="font-bold dark:text-white truncate max-w-[200px]">{{ commentAttachment?.name }}</p>
                  <p class="text-xs text-gray-500">{{ (commentAttachment?.size / 1024 / 1024).toFixed(2) }} MB</p>
                </div>
              </div>
              <button @click="removeAttachment" class="p-1 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-full transition-colors">
                <span class="material-symbols-outlined text-gray-500 text-sm">close</span>
              </button>
            </div>

            <div class="flex gap-4">
              <div class="w-10 h-10 rounded-full bg-emerald-600 shrink-0 flex items-center justify-center text-white font-bold text-sm overflow-hidden">
                <img v-if="currentUser?.avatar_url" :src="currentUser.avatar_url" class="w-full h-full object-cover" />
                <span v-else>{{ currentUser?.full_name?.charAt(0) || '?' }}</span>
              </div>
              <div class="flex-1 space-y-3">
                <div class="relative">
                  <textarea 
                    v-model="commentContent"
                    @paste="handlePaste"
                    rows="3" 
                    placeholder="Tulis komentar" 
                    class="w-full bg-gray-50 dark:bg-gray-800 border-gray-100 dark:border-gray-700 rounded-lg text-sm dark:text-white focus:ring-2 focus:ring-emerald-500/20 p-3 outline-none resize-none"
                  ></textarea>
                </div>
                
                <div class="flex justify-between items-center">
                  <div>
                    <input 
                      type="file" 
                      ref="fileInput" 
                      class="hidden" 
                      @change="handleFileSelect"
                      accept="image/*,video/*,application/pdf" 
                    />
                    <button 
                      @click="$refs.fileInput.click()"
                      class="p-2 text-gray-500 hover:text-emerald-600 hover:bg-emerald-50 dark:hover:bg-emerald-900/20 rounded-lg transition-all flex items-center gap-2"
                      title="Lampirkan File/Gambar"
                    >
                      <span class="material-symbols-outlined rotate-45">attach_file</span>
                      <span class="text-xs font-semibold">Lampirkan</span>
                    </button>
                  </div>
                  <button 
                    @click="postComment(commentContent)"
                    :disabled="(!commentContent.trim() && !commentAttachment) || isSubmitting"
                    class="bg-emerald-700 hover:bg-emerald-800 dark:bg-emerald-600 dark:hover:bg-emerald-500 disabled:opacity-100 disabled:cursor-not-allowed text-white px-6 py-2 rounded-lg text-sm font-bold shadow-lg transition-all flex items-center gap-2"
                  >
                    <span v-if="isSubmitting" class="material-symbols-outlined animate-spin text-sm">progress_activity</span>
                    <span v-else>Kirim</span>
                    <span v-if="!isSubmitting" class="material-symbols-outlined text-sm">send</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Activity History Sidebar -->
        <div class="space-y-6">
          <div class="bg-white dark:bg-[#1e1e1e] p-6 rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm">
            <h3 class="text-sm font-bold dark:text-white mb-4 flex items-center gap-2">
              <span class="material-symbols-outlined text-sm">history</span>
              Riwayat Aktivitas
            </h3>
            <div class="space-y-6 relative before:absolute before:inset-0 before:left-3 before:border-l-2 before:border-gray-100 dark:before:border-gray-800">
              <div v-if="activities.length === 0" class="text-xs text-gray-400 italic pl-8 py-4">Belum ada riwayat aktivitas</div>
              <div v-for="activity in activities" :key="activity.id" class="relative pl-8">
                <span :class="[
                  'absolute left-0 top-1.5 w-6 h-6 rounded-full bg-white dark:bg-[#1e1e1e] border-2 flex items-center justify-center z-10',
                  activity.type === 'Update Status' ? 'border-blue-500 text-blue-500' :
                  activity.type === 'Log Baru' ? 'border-emerald-500 text-emerald-500' :
                  'border-gray-400 text-gray-400'
                ]">
                  <span class="material-symbols-outlined text-[12px]">
                    {{ 
                      activity.type === 'Update Status' ? 'sync' : 
                      activity.type === 'Log Baru' ? 'add_circle' : 
                      'info' 
                    }}
                  </span>
                </span>
                <p class="text-xs font-bold text-black dark:text-white">{{ activity.type }}</p>
                <p class="text-[10px] text-gray-400 mb-1">{{ formatDate(activity.created_at).date }} {{ formatDate(activity.created_at).time }}</p>
                <p class="text-[11px] text-black dark:text-white leading-relaxed">{{ activity.description }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- IMPORT LOG VIEW -->
    <div v-else-if="currentView === 'import'" class="max-w-4xl mx-auto animate-in zoom-in-95 duration-300">
      <div class="flex flex-col gap-1 mb-6">
        <button 
          @click="navigateTo('all')"
          class="flex items-center gap-2 text-sm text-gray-500 hover:text-emerald-600 mb-2 transition-colors"
        >
          <span class="material-symbols-outlined text-sm">arrow_back</span>
          <span>Kembali</span>
        </button>
        <h1 class="text-[#121417] dark:text-white text-3xl font-extrabold">
          Import File Log
        </h1>
        <p class="text-gray-500">
          Unggah file .xlsx atau .csv untuk memproses log massal.
        </p>
      </div>

      <div class="bg-white dark:bg-[#1e1e1e] rounded-xl p-12 text-center border-2 border-dashed border-gray-200 dark:border-gray-800 hover:border-emerald-500/50 transition-all group relative">
        <input 
          type="file" 
          accept=".csv, .xlsx"
          class="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
          @change="handleFileUpload"
        />
        <div class="w-20 h-20 bg-emerald-50 dark:bg-emerald-900/20 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform">
          <span class="material-symbols-outlined text-emerald-600 text-4xl">upload_file</span>
        </div>
        <h3 class="text-xl font-bold dark:text-white mb-2">
          Pilih file untuk diunggah
        </h3>
        <p class="text-sm text-gray-500 mb-8 max-w-sm mx-auto">
          Seret dan lepas file di sini, atau klik untuk menelusuri file komputer Anda (.csv atau .xlsx)
        </p>
        <div class="flex justify-center gap-4">
          <button class="px-8 py-3 bg-emerald-600 text-white rounded-lg text-sm font-bold shadow-lg shadow-emerald-900/20 hover:bg-emerald-500 transition-all">
            Pilih File
          </button>
          <button 
            @click="downloadTemplate"
            class="px-8 py-3 border border-gray-200 dark:border-gray-700 dark:text-white rounded-lg text-sm font-bold hover:bg-gray-50 dark:hover:bg-gray-800 transition-all"
          >
            Download Template
          </button>
        </div>
      </div>
    </div>
  </div>

    <!-- POPUP NOTIFICATION -->
    <div v-if="popup.show" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div 
        @click="closePopup"
        class="absolute inset-0 bg-black/40 backdrop-blur-sm animate-in fade-in duration-300"
      ></div>
      <div class="relative bg-white dark:bg-[#1e1e1e] rounded-2xl shadow-2xl border border-gray-100 dark:border-gray-800 w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-300">
        <div class="p-8 text-center">
          <div 
            :class="[
              'w-20 h-20 rounded-full mx-auto mb-6 flex items-center justify-center shadow-lg',
              popup.type === 'success' ? 'bg-emerald-100 text-emerald-600 dark:bg-emerald-900/30' : 
              popup.type === 'error' ? 'bg-red-100 text-red-600 dark:bg-red-900/30' : 
              'bg-amber-100 text-amber-600 dark:bg-amber-900/30'
            ]"
          >
            <span class="material-symbols-outlined text-[40px]">
              {{ popup.type === 'success' ? 'check_circle' : popup.type === 'error' ? 'error' : 'warning' }}
            </span>
          </div>
          <h3 class="text-xl font-bold dark:text-white mb-2">{{ popup.title }}</h3>
          <p class="text-gray-500 dark:text-gray-400 text-sm leading-relaxed mb-8">
            {{ popup.message }}
          </p>
          <div class="flex gap-3">
            <button 
              v-if="popup.showCancel"
              @click="closePopup"
              class="flex-1 px-6 py-3 rounded-xl border border-gray-200 dark:border-gray-700 text-sm font-bold text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800 transition-all"
            >
              {{ popup.cancelText }}
            </button>
            <button 
              @click="handlePopupConfirm"
              :class="[
                'flex-1 px-6 py-3 rounded-xl text-sm font-bold text-white shadow-lg transition-all',
                popup.type === 'success' ? 'bg-emerald-600 hover:bg-emerald-500 shadow-emerald-900/20' : 
                popup.type === 'error' ? 'bg-red-600 hover:bg-red-500 shadow-red-900/20' : 
                'bg-amber-600 hover:bg-amber-500 shadow-amber-900/20'
              ]"
            >
              {{ popup.confirmText }}
            </button>
          </div>
        </div>
      </div>
    </div>
</template>
