<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const searchQuery = ref('')
const roles = ref([])
const modules = ref([])
const permissions = ref([])
const loading = ref(true)

// Modals State
const showEditModal = ref(false)
const showRoleModal = ref(false)
const showModuleModal = ref(false)
const modalLoading = ref(false)

const editForm = ref({
  roleId: null,
  roleName: '',
  moduleId: null,
  moduleName: '',
  can_create: false,
  can_read: false,
  can_update: false,
  can_delete: false,
  can_verify: false
})

const roleForm = ref({ role_name: '', role_code: '' })
const moduleForm = ref({ name: '' })
const editingRoleId = ref(null)
const editingModuleId = ref(null)
const currentUserProfile = ref(null)

const isSuperAdmin = computed(() => currentUserProfile.value?.role === 'Super Admin')

const fetchCurrentUser = async () => {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return
  try {
    const { data } = await supabase.from('profiles').select('*').eq('id', user.id).single()
    if (data) {
      currentUserProfile.value = data
    }
  } catch (error) {
    console.error('Error fetching current user profile:', error)
  }
}

const fetchAccessData = async () => {
  loading.value = true
  try {
    const projectId = authStore.user?.project_id || 1
    const [rolesRes, componentsRes, permsRes] = await Promise.all([
      supabase.from('access_roles').select('*').order('role_code'),
      supabase.from('app_components').select('*').eq('project_id', projectId).order('name'),
      supabase.from('access_permissions').select('*')
    ])

    if (rolesRes.error) throw rolesRes.error
    if (componentsRes.error) throw componentsRes.error
    if (permsRes.error) throw permsRes.error

    const colors = ['blue', 'purple', 'orange', 'teal', 'slate', 'red', 'green', 'indigo']
    
    // Natural Sort for Role Codes (e.g., R9 comes before R11)
    const naturalSorter = new Intl.Collator(undefined, { numeric: true, sensitivity: 'base' })
    const sortedRoles = rolesRes.data.sort((a, b) => 
      naturalSorter.compare(a.role_code || '', b.role_code || '')
    )

    roles.value = sortedRoles.map((r, i) => ({
      ...r,
      code: r.role_code || `R${i+1}`,
      name: r.role_name,
      color: colors[i % colors.length]
    }))

    permissions.value = permsRes.data

    modules.value = componentsRes.data.map(comp => {
      const compPerms = {}
      roles.value.forEach(role => {
        const perm = permissions.value.find(p => p.role_id === role.id && p.component_id === comp.id)
        compPerms[role.id] = perm || { role_id: role.id, component_id: comp.id, can_create: false, can_read: false, can_update: false, can_delete: false, can_verify: false }
      })

      return {
        id: comp.id,
        name: comp.name,
        icon: 'extension',
        permissions: compPerms
      }
    })

  } catch (error) {
    console.error('Error fetching access matrix:', error.message)
  } finally {
    loading.value = false
  }
}

const openEditModal = (mod, roleId) => {
  if (!isSuperAdmin.value && currentUserProfile.value?.role !== 'Editor') {
    alert('Anda tidak memiliki izin untuk mengubah hak akses.')
    return
  }
  const perm = mod.permissions[roleId]
  const role = roles.value.find(r => r.id === roleId)
  
  editForm.value = {
    roleId,
    roleName: role.name,
    moduleId: mod.id,
    moduleName: mod.name,
    can_create: perm.can_create || false,
    can_read: perm.can_read || false,
    can_update: perm.can_update || false,
    can_delete: perm.can_delete || false,
    can_verify: perm.can_verify || false
  }
  showEditModal.value = true
}

const savePermissions = async () => {
  modalLoading.value = true
  try {
    // Exclude UI-only fields (roleName, moduleName) before sending to Supabase
    const { roleId, moduleId, roleName, moduleName, ...perms } = editForm.value
    
    // Check if permission exists
    const existing = permissions.value.find(p => p.role_id === roleId && p.component_id === moduleId)
    
    if (existing) {
      const { error } = await supabase
        .from('access_permissions')
        .update({
          ...perms,
          updated_at: new Date().toISOString()
        })
        .match({ role_id: roleId, component_id: moduleId })
      if (error) throw error
    } else {
      const { error } = await supabase
        .from('access_permissions')
        .insert([{ 
          role_id: roleId, 
          component_id: moduleId, 
          ...perms 
        }])
      if (error) throw error
    }

    showEditModal.value = false
    fetchAccessData()
  } catch (error) {
    alert('Error saving: ' + error.message)
  } finally {
    modalLoading.value = false
  }
}

const handleAddRole = async () => {
  if (!isSuperAdmin.value && currentUserProfile.value?.role !== 'Editor') {
    alert('Anda tidak memiliki izin untuk menambah/mengedit role.')
    return
  }
  modalLoading.value = true
  try {
    if (editingRoleId.value) {
      const { error } = await supabase
        .from('access_roles')
        .update(roleForm.value)
        .eq('id', editingRoleId.value)
      if (error) throw error
    } else {
      const { error } = await supabase
        .from('access_roles')
        .insert([roleForm.value])
      if (error) throw error
    }
    showRoleModal.value = false
    editingRoleId.value = null
    roleForm.value = { role_name: '', role_code: '' }
    fetchAccessData()
  } catch (error) { alert(error.message) } finally { modalLoading.value = false }
}

const openEditRoleModal = (role) => {
  editingRoleId.value = role.id
  roleForm.value = { role_name: role.role_name, role_code: role.role_code }
  showRoleModal.value = true
}

const handleDeleteRole = async (id) => {
  if (!isSuperAdmin.value && currentUserProfile.value?.role !== 'Editor') {
    alert('Anda tidak memiliki izin untuk menghapus role.')
    return
  }
  if (!confirm('Hapus role ini? Seluruh matriks hak akses untuk role ini akan hilang.')) return
  modalLoading.value = true
  try {
    const { error } = await supabase.from('access_roles').delete().eq('id', id)
    if (error) throw error
    fetchAccessData()
  } catch (error) { alert(error.message) } finally { modalLoading.value = false }
}

const handleAddModule = async () => {
  if (!isSuperAdmin.value && currentUserProfile.value?.role !== 'Editor') {
    alert('Anda tidak memiliki izin untuk menambah/mengedit modul.')
    return
  }
  modalLoading.value = true
  try {
    if (editingModuleId.value) {
      const { error } = await supabase
        .from('app_components')
        .update(moduleForm.value)
        .eq('id', editingModuleId.value)
      if (error) throw error
    } else {
      const { error } = await supabase
        .from('app_components')
        .insert([moduleForm.value])
      if (error) throw error
    }
    showModuleModal.value = false
    editingModuleId.value = null
    moduleForm.value = { name: '' }
    fetchAccessData()
  } catch (error) { alert(error.message) } finally { modalLoading.value = false }
}

const openEditModuleModal = (mod) => {
  editingModuleId.value = mod.id
  moduleForm.value = { name: mod.name }
  showModuleModal.value = true
}

const handleDeleteModule = async (id) => {
  if (!isSuperAdmin.value && currentUserProfile.value?.role !== 'Editor') {
    alert('Anda tidak memiliki izin untuk menghapus modul.')
    return
  }
  if (!confirm('Hapus modul ini? Seluruh matriks hak akses untuk modul ini akan hilang.')) return
  modalLoading.value = true
  try {
    const { error } = await supabase.from('app_components').delete().eq('id', id)
    if (error) throw error
    fetchAccessData()
  } catch (error) { alert(error.message) } finally { modalLoading.value = false }
}

onMounted(() => {
  fetchCurrentUser()
  fetchAccessData()
})

const filteredModules = computed(() => {
  return modules.value.filter(m => 
    m.name.toLowerCase().includes(searchQuery.value.toLowerCase())
  )
})

const renderPermissionChars = (perm) => {
  return [
    { char: 'C', isActive: perm.can_create },
    { char: 'R', isActive: perm.can_read },
    { char: 'U', isActive: perm.can_update },
    { char: 'D', isActive: perm.can_delete },
    { char: 'V', isActive: perm.can_verify },
  ]
}

const getRoleBadgeClass = (color) => {
  switch (color) {
    case 'blue': return 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400'
    case 'purple': return 'bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400'
    case 'orange': return 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400'
    case 'teal': return 'bg-teal-100 text-teal-700 dark:bg-teal-900/30 dark:text-teal-400'
    case 'red': return 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400'
    case 'green': return 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400'
    case 'indigo': return 'bg-indigo-100 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-400'
    default: return 'bg-slate-100 text-slate-700 dark:bg-slate-900/30 dark:text-slate-400'
  }
}
</script>

<template>
  <div class="max-w-[1600px] mx-auto flex flex-col h-[calc(100vh-140px)] gap-6">
    <!-- Actions -->
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h3 class="text-xl font-bold text-slate-900 dark:text-white">Matriks Hak Akses</h3>
        <div class="flex flex-wrap gap-3" v-if="isSuperAdmin || currentUserProfile?.role === 'Editor'">
          <button 
            @click="showModuleModal = true"
            class="inline-flex items-center gap-2 bg-white dark:bg-[#141414] hover:bg-emerald-50 dark:hover:bg-emerald-900/20 text-emerald-600 border border-emerald-200 dark:border-emerald-800 px-4 py-2 rounded-lg text-sm font-bold shadow-sm transition-all"
          >
            <span class="material-symbols-outlined text-lg">add</span>
            Tambah Modul
          </button>
          <button 
            @click="showRoleModal = true"
            class="inline-flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white px-4 py-2 rounded-lg text-sm font-bold shadow-lg shadow-emerald-900/20 transition-all"
          >
            <span class="material-symbols-outlined text-lg">add</span>
            Tambah Role Baru
          </button>
        </div>
      </div>

      <!-- Matrix Table -->
      <div class="bg-white dark:bg-[#141414] rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm overflow-hidden flex flex-col flex-1 min-h-0">
            <div class="border-b border-slate-200 dark:border-gray-800 px-6 py-4 flex flex-wrap items-center justify-between bg-slate-50/50 dark:bg-[#1a1a1a]/50 gap-4">
          <div class="flex items-center gap-4 flex-1 min-w-0">
            <div class="relative w-full sm:w-64">
              <span class="material-symbols-outlined absolute left-3 top-2 text-slate-400 text-lg">search</span>
              <input 
                v-model="searchQuery"
                type="text" 
                placeholder="Filter modul..." 
                class="pl-10 pr-4 py-1.5 w-full text-sm bg-white dark:bg-[#1a1a1a] border border-slate-200 dark:border-gray-700 rounded-md focus:ring-2 focus:ring-emerald-500 outline-none transition-all dark:text-slate-200"
              />
            </div>
            <div class="hidden sm:flex items-center gap-4 text-[10px] font-bold uppercase tracking-wider text-slate-500">
              <div class="flex items-center gap-1.5">
                <span class="size-2 rounded-full bg-slate-900 dark:bg-white"></span>
                <span>Aktif</span>
              </div>
              <div class="flex items-center gap-1.5">
                <div class="w-[13px] h-[5px] bg-slate-600 dark:bg-slate-400 rounded-full"></div>
                <span>Tidak Aktif</span>
              </div>
            </div>
          </div>
        </div>

        <div class="overflow-auto flex-1 custom-scrollbar">
          <table class="w-full border-collapse text-left min-w-[1000px]">
            <thead class="bg-slate-50 dark:bg-slate-900 sticky top-0 z-20 shadow-sm">
              <tr>
                <th class="sticky left-0 z-30 border-b border-r border-slate-200 dark:border-slate-700 px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 w-[280px] min-w-[280px] bg-slate-50 dark:bg-slate-900">
                  Modul & Entitas Data
                </th>
                <th v-for="role in roles" :key="role.id" class="border-b border-slate-200 dark:border-slate-700 px-4 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 text-center w-[120px] group/role">
                  <div class="flex flex-col items-center gap-2">
                    <span class="inline-flex items-center justify-center bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 px-2 py-1 rounded text-[10px] font-black shadow-sm uppercase whitespace-nowrap border border-slate-200 dark:border-slate-700">
                      {{ role.role_code || role.id.substring(0,2) }}
                    </span>
                    <span class="truncate max-w-[100px]">{{ role.name }}</span>
                    <!-- Action Icons for Role -->
                    <div class="flex gap-2 opacity-0 group-hover/role:opacity-100 transition-opacity" v-if="isSuperAdmin || currentUserProfile?.role === 'Editor'">
                      <button @click.stop="openEditRoleModal(role)" class="size-6 flex items-center justify-center rounded-md bg-blue-50 dark:bg-blue-900/20 text-blue-600 hover:bg-blue-600 hover:text-white transition-all">
                        <span class="material-symbols-outlined text-[14px]">edit</span>
                      </button>
                      <button @click.stop="handleDeleteRole(role.id)" class="size-6 flex items-center justify-center rounded-md bg-rose-50 dark:bg-rose-900/20 text-rose-600 hover:bg-rose-600 hover:text-white transition-all">
                        <span class="material-symbols-outlined text-[14px]">delete</span>
                      </button>
                    </div>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-200 dark:divide-slate-700 text-sm bg-white dark:bg-slate-800">
              <!-- Loading State -->
              <tr v-if="loading">
                <td :colspan="roles.length + 1" class="px-6 py-20 text-center">
                  <div class="flex flex-col items-center gap-3">
                    <div class="animate-spin size-8 border-4 border-emerald-500/30 border-t-emerald-500 rounded-full"></div>
                    <span class="text-slate-500 font-bold animate-pulse">Menghubungkan ke Database...</span>
                  </div>
                </td>
              </tr>

              <!-- Empty State -->
              <tr v-else-if="filteredModules.length === 0">
                <td :colspan="roles.length + 1" class="px-6 py-20 text-center">
                  <div class="flex flex-col items-center gap-3 opacity-40">
                    <span class="material-symbols-outlined text-4xl">inventory_2</span>
                    <span class="text-slate-500 font-bold">Tidak ada modul yang ditemukan</span>
                  </div>
                </td>
              </tr>

              <!-- Data Rows -->
              <tr v-else v-for="mod in filteredModules" :key="mod.id" class="hover:bg-slate-50 dark:hover:bg-slate-700/30 group transition-colors">
                <td class="sticky left-0 z-10 border-r border-slate-200 dark:border-slate-700 px-6 py-4 font-medium text-slate-900 dark:text-slate-200 bg-white dark:bg-slate-800 group-hover:bg-slate-50 dark:group-hover:bg-slate-700/30 transition-colors shadow-[4px_0_8px_-4px_rgba(0,0,0,0.05)] group/module">
                  <div class="flex items-center justify-between gap-3">
                    <div class="flex items-center gap-3">
                      <span class="material-symbols-outlined text-slate-400 text-lg">{{ mod.icon }}</span>
                      {{ mod.name }}
                    </div>
                    <!-- Action Icons for Module -->
                    <div class="flex gap-2 opacity-0 group-hover/module:opacity-100 transition-opacity" v-if="isSuperAdmin || currentUserProfile?.role === 'Editor'">
                      <button @click.stop="openEditModuleModal(mod)" class="size-6 flex items-center justify-center rounded-md bg-blue-50 dark:bg-blue-900/20 text-blue-600 hover:bg-blue-600 hover:text-white transition-all">
                        <span class="material-symbols-outlined text-[14px]">edit</span>
                      </button>
                      <button @click.stop="handleDeleteModule(mod.id)" class="size-6 flex items-center justify-center rounded-md bg-rose-50 dark:bg-rose-900/20 text-rose-600 hover:bg-rose-600 hover:text-white transition-all">
                        <span class="material-symbols-outlined text-[14px]">delete</span>
                      </button>
                    </div>
                  </div>
                </td>
                <td 
                  v-for="role in roles" 
                  :key="role.id" 
                  @click="openEditModal(mod, role.id)"
                  class="px-2 py-4 text-center cursor-pointer hover:bg-emerald-50/50 dark:hover:bg-emerald-900/10 transition-colors border-r border-slate-100 dark:border-slate-700"
                >
                  <div class="flex justify-center items-center gap-1.5 h-full">
                    <template v-for="(p, i) in renderPermissionChars(mod.permissions[role.id])" :key="i">
                      <span v-if="p.isActive" 
                        class="text-[11px] w-3 text-slate-900 dark:text-white font-black"
                      >
                        {{ p.char }}
                      </span>
                      <div v-else 
                        class="w-[13px] h-[5px] bg-slate-600 dark:bg-slate-500 rounded-full opacity-60"
                      ></div>
                    </template>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Modals -->
      <!-- Add Role Modal -->
      <div v-if="showRoleModal" class="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
        <div class="bg-white dark:bg-[#141414] w-full max-w-md rounded-2xl shadow-2xl border border-slate-200 dark:border-gray-800 overflow-hidden animate-in zoom-in duration-200">
          <div class="px-6 py-4 border-b border-slate-100 dark:border-gray-800 flex items-center justify-between bg-slate-50 dark:bg-[#1a1a1a]/50">
            <h4 class="font-bold text-slate-800 dark:text-white">{{ editingRoleId ? 'Edit Role' : 'Tambah Role Baru' }}</h4>
            <button @click="showRoleModal = false, editingRoleId = null" class="text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors">
              <span class="material-symbols-outlined">close</span>
            </button>
          </div>
          <div class="p-6 space-y-4">
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase">Nama Role</label>
              <input v-model="roleForm.role_name" type="text" placeholder="e.g. Project Manager" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none" />
            </div>
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase">Kode Role (Singkatan)</label>
              <input v-model="roleForm.role_code" type="text" placeholder="e.g. PM" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none uppercase" />
            </div>
          </div>
          <div class="px-6 py-4 border-t border-slate-100 dark:border-gray-800 flex justify-end gap-3 bg-slate-50 dark:bg-[#1a1a1a]/50">
            <button @click="showRoleModal = false" class="px-4 py-2 text-sm font-bold text-slate-600 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-colors">Batal</button>
            <button @click="handleAddRole" :disabled="modalLoading" class="px-6 py-2 text-sm font-bold text-white bg-emerald-600 rounded-lg hover:bg-emerald-700 transition-all disabled:opacity-50">
              <span v-if="modalLoading" class="animate-spin size-4 border-2 border-white/30 border-t-white rounded-full inline-block align-middle mr-2"></span>
              Simpan Role
            </button>
          </div>
        </div>
      </div>

      <!-- Add Module Modal -->
      <div v-if="showModuleModal" class="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
        <div class="bg-white dark:bg-[#141414] w-full max-w-md rounded-2xl shadow-2xl border border-slate-200 dark:border-gray-800 overflow-hidden animate-in zoom-in duration-200">
          <div class="px-6 py-4 border-b border-slate-100 dark:border-gray-800 flex items-center justify-between bg-slate-50 dark:bg-[#1a1a1a]/50">
            <h4 class="font-bold text-slate-800 dark:text-white">{{ editingModuleId ? 'Edit Modul' : 'Tambah Modul/Entitas' }}</h4>
            <button @click="showModuleModal = false, editingModuleId = null" class="text-slate-400 hover:text-slate-600 dark:hover:text-white transition-colors">
              <span class="material-symbols-outlined">close</span>
            </button>
          </div>
          <div class="p-6 space-y-4">
            <div class="space-y-1.5">
              <label class="text-xs font-bold text-slate-500 uppercase">Nama Modul</label>
              <input v-model="moduleForm.name" type="text" placeholder="e.g. Inventaris Barang" class="w-full bg-slate-50 dark:bg-[#1c1c1c] border border-slate-200 dark:border-gray-800 rounded-lg py-2 px-3 text-sm focus:ring-2 focus:ring-emerald-500 outline-none" />
            </div>
          </div>
          <div class="px-6 py-4 border-t border-slate-100 dark:border-gray-800 flex justify-end gap-3 bg-slate-50 dark:bg-[#1a1a1a]/50">
            <button @click="showModuleModal = false" class="px-4 py-2 text-sm font-bold text-slate-600 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-colors">Batal</button>
            <button @click="handleAddModule" :disabled="modalLoading" class="px-6 py-2 text-sm font-bold text-white bg-emerald-600 rounded-lg hover:bg-emerald-700 transition-all disabled:opacity-50">
              <span v-if="modalLoading" class="animate-spin size-4 border-2 border-white/30 border-t-white rounded-full inline-block align-middle mr-2"></span>
              Simpan Modul
            </button>
          </div>
        </div>
      </div>

      <!-- Edit Permissions Modal -->
      <div v-if="showEditModal" class="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
        <div class="bg-white dark:bg-[#141414] w-full max-w-md rounded-2xl shadow-2xl border border-slate-200 dark:border-gray-800 overflow-hidden animate-in zoom-in duration-200">
          <div class="px-6 py-4 border-b border-slate-100 dark:border-gray-800 bg-slate-50 dark:bg-[#1a1a1a]/50">
            <h4 class="font-bold text-slate-800 dark:text-white text-sm">Update Izin: {{ editForm.roleName }}</h4>
            <p class="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Modul: {{ editForm.moduleName }}</p>
          </div>
          <div class="p-6 grid grid-cols-2 gap-4">
            <label v-for="(val, key) in { can_create: 'Create (C)', can_read: 'Read (R)', can_update: 'Update (U)', can_delete: 'Delete (D)', can_verify: 'Verify (V)' }" :key="key" 
              class="flex items-center justify-between p-3 rounded-xl border border-slate-100 dark:border-gray-800 bg-slate-50 dark:bg-[#1c1c1c] cursor-pointer hover:border-emerald-500/50 transition-all"
            >
              <span class="text-xs font-bold text-slate-700 dark:text-slate-300">{{ val }}</span>
              <input type="checkbox" v-model="editForm[key]" class="size-4 accent-emerald-600 cursor-pointer" />
            </label>
          </div>
          <div class="px-6 py-4 border-t border-slate-100 dark:border-gray-800 flex justify-end gap-3 bg-slate-50 dark:bg-[#1a1a1a]/50">
            <button @click="showEditModal = false" class="px-4 py-2 text-sm font-bold text-slate-600 dark:text-slate-400 hover:text-slate-800 dark:hover:text-white transition-colors">Batal</button>
            <button @click="savePermissions" :disabled="modalLoading" class="px-6 py-2 text-sm font-bold text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-all disabled:opacity-50 shadow-lg shadow-blue-500/20">
              <span v-if="modalLoading" class="animate-spin size-4 border-2 border-white/30 border-t-white rounded-full inline-block align-middle mr-2"></span>
              Update Akses
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
  background: #cbd5e1;
  border-radius: 10px;
}
.dark .custom-scrollbar::-webkit-scrollbar-thumb {
  background: #475569;
}
</style>
