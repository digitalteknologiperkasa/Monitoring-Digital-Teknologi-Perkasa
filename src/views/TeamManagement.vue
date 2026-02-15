<script setup>
import { ref, onMounted, computed } from 'vue'
import { supabase, supabaseAdmin } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const teamMembers = ref([])
const rolesList = ref(['Viewer', 'Editor', 'Super Admin'])
const projects = ref([]) // Daftar projek untuk pilihan
const currentUserProfile = ref(null)
const isLoading = ref(true)
const searchQuery = ref('')
const roleFilter = ref('all')

// Role access check
const isSuperAdmin = computed(() => currentUserProfile.value?.role === 'Super Admin')

// Modal & Form State
const isModalOpen = ref(false)
const isEditing = ref(false)
const showPassword = ref(false)
const formLoading = ref(false)
const showSuccessModal = ref(false)
const successMessage = ref('')
const form = ref({
  id: '',
  full_name: '',
  email: '',
  password: '',
  role: 'Viewer',
  description: '',
  project_id: null // Tambahkan project_id
})

const fetchProjects = async () => {
  try {
    const { data, error } = await supabase.from('projects').select('id, name').order('name')
    if (error) throw error
    projects.value = data || []
  } catch (error) {
    console.error('Error fetching projects:', error)
  }
}

const fetchCurrentUser = async () => {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()
    if (data) {
      currentUserProfile.value = data
    }
  } catch (error) {
    console.error('Error fetching current user profile:', error)
  }
}

const fetchTeamMembers = async () => {
  isLoading.value = true
  try {
    // Ambil semua profil tanpa join
    const { data: profiles, error: profilesError } = await supabase
      .from('profiles')
      .select('*')
      .order('full_name', { ascending: true })
    
    if (profilesError) throw profilesError
    
    // Ambil semua projects untuk mapping
    const { data: projectsList } = await supabase
      .from('projects')
      .select('id, name')
    
    // Map project names ke profiles
    teamMembers.value = (profiles || []).map(profile => ({
      ...profile,
      projects: projectsList?.find(p => p.id === profile.project_id) || null
    }))
  } catch (error) {
    console.error('Error fetching team members:', error.message)
  } finally {
    isLoading.value = false
  }
}

const filteredMembers = computed(() => {
  return teamMembers.value.filter(member => {
    const matchesSearch = (member.full_name || '').toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                         (member.email || '').toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchesRole = roleFilter.value === 'all' || member.role === roleFilter.value
    return matchesSearch && matchesRole
  })
})

const openModal = (member = null) => {
  if (!isSuperAdmin.value) {
    alert('Hanya Super Admin yang dapat menambah atau mengedit anggota!')
    return
  }
  if (member) {
    isEditing.value = true
    form.value = {
      id: member.id,
      full_name: member.full_name || '',
      email: member.email || '',
      password: '', 
      role: member.role || 'Viewer',
      description: member.description || '',
      project_id: member.project_id
    }
  } else {
    isEditing.value = false
    form.value = {
      id: '',
      full_name: '',
      email: '',
      password: '',
      role: 'Viewer',
      description: '',
      project_id: projects.value.length > 0 ? projects.value[0].id : 1
    }
  }
  isModalOpen.value = true
}

const closeModal = () => {
  isModalOpen.value = false
  showPassword.value = false
}

const handleSubmit = async () => {
  if (!isSuperAdmin.value) {
    alert('Hanya Super Admin yang dapat menambah atau mengedit anggota!')
    return
  }
  
  formLoading.value = true
  try {
    if (isEditing.value) {
      // Logic UPDATE
      const { error } = await supabase
        .from('profiles')
        .update({
          full_name: form.value.full_name,
          role: form.value.role,
          description: form.value.description,
          project_id: form.value.project_id || 1, // Simpan project_id, default ke 1
          updated_at: new Date().toISOString()
        })
        .eq('id', form.value.id)
        
      if (error) throw error
      successMessage.value = 'Profil anggota berhasil diperbarui!'
    } else {
      // Logic CREATE (Signup)
      let signUpData, signUpError;

      // Gunakan supabaseAdmin jika tersedia agar session Super Admin tidak berubah
      if (supabaseAdmin) {
        console.log('Using Admin SDK to create user (prevents session swap)...');
        const { data, error } = await supabaseAdmin.auth.admin.createUser({
          email: form.value.email,
          password: form.value.password,
          email_confirm: true,
          user_metadata: {
            full_name: form.value.full_name,
            role: form.value.role,
            description: form.value.description,
            project_id: form.value.project_id || 1
          }
        })
        signUpData = data;
        signUpError = error;
      } else {
        // Fallback ke signUp biasa jika Service Role Key tidak ada
        console.warn('Service Role Key not found, falling back to standard signUp (session may swap)...');
        const { data, error } = await supabase.auth.signUp({
          email: form.value.email,
          password: form.value.password,
          options: {
            data: {
              full_name: form.value.full_name,
              role: form.value.role,
              description: form.value.description,
              project_id: form.value.project_id || 1
            }
          }
        })
        signUpData = data;
        signUpError = error;
      }

      if (signUpError) throw signUpError
      if (!signUpData.user) throw new Error('Gagal mendaftarkan user baru')

      // Upsert profile record menggunakan admin jika tersedia untuk bypass RLS
      const client = supabaseAdmin || supabase
      const { error: profileError } = await client
        .from('profiles')
        .upsert({
          id: signUpData.user.id,
          full_name: form.value.full_name,
          email: form.value.email,
          role: form.value.role,
          description: form.value.description,
          project_id: form.value.project_id || 1,
          updated_at: new Date().toISOString()
        })
      
      if (profileError) throw profileError
      successMessage.value = 'Anggota tim berhasil ditambahkan!'
    }
    
    await fetchTeamMembers()
    closeModal()
    showSuccessModal.value = true
  } catch (error) {
    console.error('Error saving member:', error)
    const errorMsg = error.message || error.details || 'Error tidak diketahui'
    alert('Gagal menyimpan data: ' + errorMsg)
  } finally {
    formLoading.value = false
  }
}

const deleteMember = async (id) => {
  if (!isSuperAdmin.value) {
    alert('Hanya Super Admin yang dapat menghapus anggota!')
    return
  }
  
  const { data: { user } } = await supabase.auth.getUser()
  if (id === user?.id) {
    alert('Anda tidak bisa menghapus akun Anda sendiri!')
    return
  }

  if (!confirm('Apakah Anda yakin ingin menghapus akses anggota ini?')) return
  
  try {
    const { error } = await supabase
      .from('profiles')
      .delete()
      .eq('id', id)
      
    if (error) throw error
    await fetchTeamMembers()
    alert('Akses anggota telah dicabut dari sistem.')
  } catch (error) {
    alert('Gagal menghapus data: ' + error.message)
  }
}

onMounted(() => {
  fetchCurrentUser()
  fetchTeamMembers()
  fetchProjects()
})
</script>

<template>
  <div class="max-w-7xl mx-auto space-y-8">
    <!-- Header Section -->
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div class="flex flex-col gap-1">
        <h2 class="text-[#121417] dark:text-white text-3xl font-extrabold leading-tight tracking-tight">
          Team Access Management
        </h2>
        <p class="text-[#646f82] dark:text-gray-400 text-base font-normal">
          Manage roles and permissions for the development team.
        </p>
      </div>
      <div class="flex gap-3" v-if="isSuperAdmin">
        <button
          @click="openModal()"
          class="flex items-center justify-center gap-2 h-11 px-5 rounded-lg bg-[#001D1A] dark:bg-emerald-600 hover:opacity-90 text-white text-sm font-semibold shadow-lg shadow-black/10 transition-all"
        >
          <span class="material-symbols-outlined text-[20px]">person_add</span>
          <span>Tambah Anggota</span>
        </button>
      </div>
    </div>

    <!-- Search & Filter -->
    <div class="bg-white dark:bg-[#141414] p-3 rounded-lg border border-gray-200 dark:border-gray-800 shadow-sm flex flex-col md:flex-row gap-3 items-center">
      <div class="flex-1 w-full relative group">
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <span class="material-symbols-outlined text-gray-500 text-[20px]">search</span>
        </div>
        <input
          v-model="searchQuery"
          class="block w-full pl-10 pr-3 py-2 bg-gray-50 dark:bg-[#1a1a1a] border-transparent rounded-lg text-sm text-[#121417] dark:text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-emerald-500/10 transition-all"
          placeholder="Cari anggota tim..."
          type="text"
        />
      </div>
      <div class="flex gap-2 w-full md:w-auto">
        <select
          v-model="roleFilter"
          class="bg-gray-50 dark:bg-[#1a1a1a] border-transparent rounded-lg text-sm text-gray-700 dark:text-gray-300 focus:ring-2 focus:ring-emerald-500/10 cursor-pointer min-w-[140px] py-2 px-3 outline-none"
        >
          <option value="all">Semua Role</option>
          <option v-for="role in rolesList" :key="role" :value="role">{{ role }}</option>
        </select>
      </div>
    </div>

    <!-- Table -->
    <div class="bg-white dark:bg-[#141414] rounded-lg border border-gray-200 dark:border-gray-800 shadow-sm overflow-hidden">
      <div class="overflow-x-auto custom-scrollbar">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-gray-50 dark:bg-[#1a1a1a] border-b border-gray-100 dark:border-gray-800">
              <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Nama & Deskripsi
              </th>
              <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Email
              </th>
              <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Role
              </th>
              <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Projek
              </th>
              <th class="px-6 py-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-right" v-if="isSuperAdmin">
                Aksi
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100 dark:divide-gray-800">
            <tr v-if="isLoading" v-for="i in 3" :key="i" class="animate-pulse">
              <td class="px-6 py-4"><div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-24"></div></td>
              <td class="px-6 py-4"><div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-48"></div></td>
              <td class="px-6 py-4"><div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-16"></div></td>
              <td class="px-6 py-4 text-right" v-if="isSuperAdmin"><div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-8 ml-auto"></div></td>
            </tr>
            <tr v-else-if="filteredMembers.length === 0">
              <td :colspan="isSuperAdmin ? 4 : 3" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">
                Tidak ada anggota tim ditemukan.
              </td>
            </tr>
            <tr v-for="member in filteredMembers" :key="member.id" class="hover:bg-gray-50 dark:hover:bg-[#1a1a1a] transition-colors">
              <td class="px-6 py-4 resize-none">
                <div class="flex items-center gap-3">
                  <img :src="member.avatar_url || `https://ui-avatars.com/api/?name=${member.full_name || 'User'}&background=random`" class="w-8 h-8 rounded-full border border-gray-200 dark:border-gray-700" alt="" />
                  <div class="flex flex-col">
                    <span class="font-medium text-gray-900 dark:text-white">{{ member.full_name || 'N/A' }}</span>
                    <span class="text-[10px] text-gray-500 dark:text-gray-500 line-clamp-1 italic" v-if="member.description">"{{ member.description }}"</span>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 text-gray-600 dark:text-gray-400">
                {{ member.email || '-' }}
              </td>
              <td class="px-6 py-4">
                <span 
                  :class="[
                    'px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider',
                    member.role === 'Super Admin' ? 'bg-rose-100 text-rose-700 dark:bg-rose-900/30 dark:text-rose-400' :
                    member.role === 'Editor' ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400' : 
                    'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400'
                  ]"
                >
                  {{ member.role }}
                </span>
              </td>
              <td class="px-6 py-4">
                <div class="flex items-center gap-2">
                  <span class="material-symbols-outlined text-[14px] text-gray-400">deployed_code</span>
                  <span class="text-sm text-gray-600 dark:text-gray-400">{{ member.projects?.name || 'No Project' }}</span>
                </div>
              </td>
              <td class="px-6 py-4 text-right" v-if="isSuperAdmin">
                <div class="flex items-center justify-end gap-2">
                  <button 
                    @click="openModal(member)"
                    class="p-2 text-gray-400 hover:text-emerald-600 dark:hover:text-emerald-400 transition-colors rounded-lg hover:bg-emerald-50 dark:hover:bg-emerald-900/20"
                  >
                    <span class="material-symbols-outlined text-[20px]">edit</span>
                  </button>
                  <button 
                    v-if="member.id !== authStore.user?.id"
                    @click="deleteMember(member.id)"
                    class="p-2 text-gray-400 hover:text-red-600 dark:hover:text-red-400 transition-colors rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20"
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

    <!-- TEAM ACCESS MODAL (ADD/EDIT) -->
    <div
      v-if="isModalOpen"
      class="fixed inset-0 z-[100] flex items-center justify-center p-4"
    >
      <div class="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" @click="closeModal"></div>
      <div
        class="relative bg-white dark:bg-[#141414] w-full max-w-2xl rounded-lg shadow-2xl shadow-black/20 overflow-hidden transform transition-all border border-gray-200 dark:border-gray-800"
      >
        <div class="flex items-center justify-between px-8 py-6 border-b border-gray-100 dark:border-gray-800 bg-slate-50 dark:bg-slate-900/30">
          <div>
            <h3 class="text-xl font-bold text-slate-900 dark:text-white">
              {{ isEditing ? 'Edit Akses Anggota' : 'Tambah Anggota Tim' }}
            </h3>
            <p class="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
              {{ isEditing ? 'Perbarui hak akses anggota tim Anda.' : 'Berikan akses ke anggota baru untuk bergabung.' }}
            </p>
          </div>
          <button
            class="w-10 h-10 flex items-center justify-center rounded-full text-slate-400 hover:bg-gray-100 dark:hover:bg-gray-800 hover:text-slate-600 transition-all font-bold"
            @click="closeModal"
          >
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>
        <form class="p-8 space-y-6" @submit.prevent="handleSubmit">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-4">
            <!-- Left Column -->
            <div class="space-y-4">
              <div>
                <label class="block text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider mb-2">Nama Lengkap</label>
                <div class="relative">
                  <span class="material-symbols-outlined absolute left-3 top-2.5 text-slate-400 text-[20px]">person</span>
                  <input
                    v-model="form.full_name"
                    required
                    class="w-full pl-10 pr-4 py-2.5 bg-gray-50 dark:bg-[#1a1a1a] border border-gray-200 dark:border-gray-800 rounded-lg text-sm text-[#121417] dark:text-white focus:ring-2 focus:ring-emerald-500/10 focus:border-emerald-500 outline-none transition-all"
                    placeholder="Masukkan nama lengkap"
                    type="text"
                  />
                </div>
              </div>
              <div>
                <label class="block text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider mb-2">Alamat Email</label>
                <div class="relative">
                  <span class="material-symbols-outlined absolute left-3 top-2.5 text-slate-400 text-[20px]">mail</span>
                  <input
                    v-model="form.email"
                    required
                    :disabled="isEditing"
                    class="w-full pl-10 pr-4 py-2.5 bg-gray-50 dark:bg-[#1a1a1a] border border-gray-200 dark:border-gray-800 rounded-lg text-sm text-[#121417] dark:text-white focus:ring-2 focus:ring-emerald-500/10 focus:border-emerald-500 outline-none transition-all disabled:opacity-50"
                    placeholder="contoh@pesantren.digital"
                    type="email"
                  />
                </div>
              </div>
              <div v-if="!isEditing">
                <label class="block text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider mb-2">Kata Sandi</label>
                <div class="relative">
                  <span class="material-symbols-outlined absolute left-3 top-2.5 text-slate-400 text-[20px]">lock</span>
                  <input
                    v-model="form.password"
                    :required="!isEditing"
                    class="w-full pl-10 pr-12 py-2.5 bg-gray-50 dark:bg-[#1a1a1a] border border-gray-200 dark:border-gray-800 rounded-lg text-sm text-[#121417] dark:text-white focus:ring-2 focus:ring-emerald-500/10 focus:border-emerald-500 outline-none transition-all"
                    placeholder="••••••••"
                    :type="showPassword ? 'text' : 'password'"
                  />
                  <button
                    class="absolute right-3 top-2.5 text-slate-400 hover:text-slate-600"
                    type="button"
                    @click="showPassword = !showPassword"
                  >
                    <span class="material-symbols-outlined text-[20px]">
                      {{ showPassword ? 'visibility_off' : 'visibility' }}
                    </span>
                  </button>
                </div>
              </div>
            </div>

            <!-- Right Column -->
            <div class="space-y-4">
              <!-- Role Description Field -->
              <div>
                <label class="block text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider mb-2">Keterangan Role / Posisi</label>
                <div class="relative">
                  <span class="material-symbols-outlined absolute left-3 top-2.5 text-slate-400 text-[20px]">info</span>
                  <input
                    v-model="form.description"
                    class="w-full pl-10 pr-4 py-2.5 bg-gray-50 dark:bg-[#1a1a1a] border border-gray-200 dark:border-gray-800 rounded-lg text-sm text-[#121417] dark:text-white focus:ring-2 focus:ring-emerald-500/10 focus:border-emerald-500 outline-none transition-all"
                    placeholder="e.g. Lead Developer, QA Specialist"
                    type="text"
                  />
                </div>
              </div>

              <!-- Project Assignment Field -->
              <div>
                <label class="block text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider mb-2">Penugasan Projek</label>
                <div class="relative">
                  <span class="material-symbols-outlined absolute left-3 top-2.5 text-slate-400 text-[20px]">deployed_code</span>
                  <select
                    v-model="form.project_id"
                    required
                    class="w-full pl-10 pr-4 py-2.5 bg-gray-50 dark:bg-[#1a1a1a] border border-gray-200 dark:border-gray-800 rounded-lg text-sm text-[#121417] dark:text-white focus:ring-2 focus:ring-emerald-500/10 focus:border-emerald-500 outline-none transition-all appearance-none"
                  >
                    <option v-for="proj in projects" :key="proj.id" :value="proj.id">
                      {{ proj.name }}
                    </option>
                  </select>
                  <div class="absolute right-3 top-2.5 pointer-events-none text-slate-400 font-bold">
                    <span class="material-symbols-outlined text-[20px]">expand_more</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="border-t border-gray-100 dark:border-gray-800 pt-6">
            <label class="block text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider mb-3">Pilih Role Akses</label>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
              <label
                v-for="roleName in rolesList"
                :key="roleName"
                :class="[
                  'relative flex items-center gap-3 p-3 border-2 rounded-xl cursor-pointer transition-all',
                  form.role === roleName ? 'bg-emerald-50 dark:bg-emerald-900/10 border-emerald-500 ring-2 ring-emerald-500/5' : 'bg-gray-50 dark:bg-white/5 border-transparent hover:border-gray-200 dark:hover:border-gray-800'
                ]"
              >
                <input v-model="form.role" class="sr-only" name="member-role" type="radio" :value="roleName" />
                <div 
                  class="size-5 flex-shrink-0 rounded-full border-2 flex items-center justify-center transition-all"
                  :class="form.role === roleName ? 'border-emerald-500 bg-emerald-500' : 'border-gray-300 dark:border-gray-700'"
                >
                  <div v-if="form.role === roleName" class="size-2 rounded-full bg-white"></div>
                </div>
                <div class="min-w-0">
                  <span class="text-sm font-bold block truncate" :class="form.role === roleName ? 'text-emerald-700 dark:text-emerald-400' : 'text-slate-700 dark:text-slate-300'">{{ roleName }}</span>
                  <p class="text-[10px] text-slate-500 dark:text-slate-500 truncate">
                    <span v-if="roleName === 'Viewer'">Hanya melihat</span>
                    <span v-else-if="roleName === 'Editor'">Bisa edit konten</span>
                    <span v-else-if="roleName === 'Super Admin'">Akses penuh</span>
                  </p>
                </div>
                <span v-if="roleName === 'Super Admin' && form.role === roleName" class="material-symbols-outlined text-rose-500 text-xs absolute top-2 right-2">verified_user</span>
              </label>
            </div>
          </div>

          <div class="flex gap-3 pt-4 border-t border-gray-100 dark:border-gray-800">
            <button
              class="flex-1 py-2.5 px-4 text-sm font-bold text-slate-500 dark:text-slate-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-all"
              @click="closeModal"
              type="button"
            >
              Batal
            </button>
            <button
              class="flex-1 py-2.5 px-4 text-sm font-bold bg-[#001D1A] dark:bg-emerald-600 text-white hover:opacity-95 rounded-lg transition-all shadow-lg shadow-black/10 flex items-center justify-center gap-2 disabled:opacity-70"
              type="submit"
              :disabled="formLoading"
            >
              <span v-if="formLoading" class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
              {{ isEditing ? 'Update User' : 'Simpan User' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- SUCCESS NOTIFICATION MODAL -->
    <Transition
      enter-active-class="transition duration-300 ease-out"
      enter-from-class="transform scale-95 opacity-0"
      enter-to-class="transform scale-100 opacity-100"
      leave-active-class="transition duration-200 ease-in"
      leave-from-class="transform scale-100 opacity-100"
      leave-to-class="transform scale-95 opacity-0"
    >
      <div v-if="showSuccessModal" class="fixed inset-0 z-[110] flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" @click="showSuccessModal = false"></div>
        <div class="relative bg-white dark:bg-[#1a1a1a] w-full max-w-sm rounded-2xl shadow-2xl border border-gray-100 dark:border-gray-800 p-8 text-center overflow-hidden">
          <!-- Decorative Background -->
          <div class="absolute -top-12 -right-12 w-32 h-32 bg-emerald-500/10 rounded-full blur-3xl"></div>
          <div class="absolute -bottom-12 -left-12 w-32 h-32 bg-blue-500/10 rounded-full blur-3xl"></div>
          
          <div class="relative">
            <div class="mx-auto w-16 h-16 bg-emerald-100 dark:bg-emerald-500/20 rounded-full flex items-center justify-center mb-6 ring-8 ring-emerald-50 dark:ring-emerald-500/5">
              <span class="material-symbols-outlined text-emerald-600 dark:text-emerald-400 text-3xl font-bold">check_circle</span>
            </div>
            
            <h3 class="text-xl font-bold text-slate-900 dark:text-white mb-2">Berhasil!</h3>
            <p class="text-sm text-slate-500 dark:text-slate-400 mb-8 leading-relaxed">
              {{ successMessage }}
            </p>
            
            <button
              @click="showSuccessModal = false"
              class="w-full py-3 px-6 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-semibold transition-all shadow-lg shadow-emerald-500/20 active:scale-[0.98]"
            >
              Selesai
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>
