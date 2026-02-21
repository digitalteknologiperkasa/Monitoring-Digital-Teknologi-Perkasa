<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import axios from '../lib/axios'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()
const loading = ref(true)

// Stats State
const stats = ref({
  totalLogs: 0,
  criticalLogs: 0,
  currentVersion: 'v0.0.0',
  totalCommits: 0,
  totalRoles: 0,
  activeModules: 0,
  featureReview: 0,
  featureDev: 0
})

// Charts Data
const logTrendData = ref([
  { day: 'Mon', logs: 0 },
  { day: 'Tue', logs: 0 },
  { day: 'Wed', logs: 0 },
  { day: 'Thu', logs: 0 },
  { day: 'Fri', logs: 0 },
  { day: 'Sat', logs: 0 },
  { day: 'Sun', logs: 0 }
])

const myRecentLogs = ref([])
const recentActivities = ref([])
const severityStats = ref({
  critical: 0,
  high: 0,
  medium: 0,
  low: 0,
  total: 0
})

const rolesSummary = ref([])

// Utility functions
const getStatusClass = (status) => {
  const s = status?.toLowerCase()
  if (s === 'on progres' || s === 'on progress') return 'bg-orange-100 text-orange-700'
  if (s === 'report' || s === 'to do') return 'bg-slate-100 text-slate-600'
  if (s === 'critikal' || s === 'critical') return 'bg-rose-100 text-rose-700'
  if (s === 'done') return 'bg-emerald-100 text-emerald-700'
  return 'bg-blue-100 text-blue-700'
}

const getSeverityClass = (severity) => {
  const s = severity?.toLowerCase()
  if (s === 'critikal' || s === 'critical') return 'text-rose-600'
  if (s === 'hight' || s === 'high') return 'text-rose-500'
  if (s === 'medium') return 'text-orange-500'
  return 'text-emerald-600'
}

const formatTime = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  const now = new Date()
  const diff = Math.floor((now - date) / 1000)
  
  if (diff < 60) return 'Baru saja'
  if (diff < 3600) return `${Math.floor(diff / 60)} menit yang lalu`
  if (diff < 86400) return `${Math.floor(diff / 3600)} jam yang lalu`
  return date.toLocaleDateString('id-ID')
}

// Data Fetching
const handleActivityClick = (activity) => {
  if (activity.parent_type === 'LOG') {
    router.push({ path: '/logs', query: { detailId: activity.parent_id } })
  } else if (activity.parent_type === 'FEATURE') {
    router.push({ path: '/features', query: { detailId: activity.parent_id } })
  }
}

const fetchData = async () => {
  loading.value = true
  try {
    const isSuperAdmin = ['Super Admin', 'Admin'].includes(authStore.user?.role)
    const projectId = authStore.user?.project_id || 1
    const userId = authStore.user?.id

    // 1. Fetch Logs Stats
    let logsUrl = '/logs?select=id,priority,status,created_at,reporter_id'
    // Strict filtering: Always filter by project_id regardless of role
    logsUrl += `&project_id=eq.${projectId}`
    const { data: logsData } = await axios.get(logsUrl)
    
    if (logsData) {
      stats.value.totalLogs = logsData.length
      stats.value.criticalLogs = logsData.filter(l => ['critikal', 'critical'].includes(l.priority?.toLowerCase())).length
      
      // My Recent Logs (Limit 5)
      myRecentLogs.value = logsData
        .filter(l => l.reporter_id === userId)
        .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
        .slice(0, 5)

      // Trend Data (Simple last 7 days count)
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
      const trend = {}
      days.forEach(d => trend[d] = 0)
      
      const oneWeekAgo = new Date()
      oneWeekAgo.setDate(oneWeekAgo.getDate() - 7)
      
      logsData.forEach(l => {
        const d = new Date(l.created_at)
        if (d >= oneWeekAgo) {
          const dayName = days[d.getDay()]
          trend[dayName]++
        }
      })
      
      // Reorder to start from Mon to Sun for display if needed, or just follow the array
      logTrendData.value = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map(day => ({
        day,
        logs: trend[day]
      }))
    }

    // 2. Fetch Feature Stats
    let featuresUrl = '/feature_requests?select=id,status_lifecycle,urgensi'
    featuresUrl += `&project_id=eq.${projectId}`
    const { data: featuresData } = await axios.get(featuresUrl)
    
    if (featuresData) {
      stats.value.featureReview = featuresData.filter(f => f.status_lifecycle === 'Sedang Ditinjau').length
      stats.value.featureDev = featuresData.filter(f => f.status_lifecycle === 'Sedang Dikembangkan').length
    }

    // 3. Version Control Stats
    let versionsUrl = '/version_logs?select=version_number,release_date&order=release_date.desc'
    versionsUrl += `&project_id=eq.${projectId}`
    const { data: versionsData } = await axios.get(versionsUrl)
    
    if (versionsData && versionsData.length > 0) {
      stats.value.currentVersion = versionsData[0].version_number
      stats.value.totalCommits = versionsData.length // Assuming each log is a release/commit point
    }

    // 4. Access Control Stats
    const [rolesRes, modulesRes] = await Promise.all([
      supabase.from('access_roles').select('id,role_name,role_code', { count: 'exact' }).eq('project_id', projectId),
      supabase.from('app_components').select('id,name', { count: 'exact' }).eq('project_id', projectId)
    ])
    
    stats.value.totalRoles = rolesRes.count || 0
    stats.value.activeModules = modulesRes.count || 0

    if (rolesRes.data) {
      const colors = ['blue', 'emerald', 'slate', 'indigo', 'amber']
      rolesSummary.value = rolesRes.data.slice(0, 5).map((r, i) => ({
        name: r.role_name,
        status: r.role_code,
        count: '-', // Placeholder as user count is removed
        percentage: 0, // Removed percentage
        color: colors[i % colors.length]
      }))
    }

    // 5. Severity Total (Logs + Features)
    const allItems = [
      ...(logsData || []).map(l => ({ priority: l.priority?.toLowerCase() })),
      ...(featuresData || []).map(f => ({ priority: f.urgensi?.toLowerCase() }))
    ]
    
    const sev = { critical: 0, high: 0, medium: 0, low: 0, total: allItems.length }
    allItems.forEach(item => {
      if (['critikal', 'critical'].includes(item.priority)) sev.critical++
      else if (['hight', 'high'].includes(item.priority)) sev.high++
      else if (item.priority === 'medium') sev.medium++
      else sev.low++
    })
    severityStats.value = sev

    // 6. Recent Activities (Discussions) - Filtered by Project
    // Fetch larger batch to allow for filtering
    const { data: discData } = await axios.get('/discussion_forum?select=*,user:profiles(full_name,avatar_url)&order=created_at.desc&limit=50')
    
    if (discData && discData.length > 0) {
      // 1. Identify parent IDs by type
      const logIds = [...new Set(discData.filter(d => d.parent_type === 'LOG').map(d => d.parent_id))]
      const featureIds = [...new Set(discData.filter(d => d.parent_type === 'FEATURE').map(d => d.parent_id))]
      
      let validLogIds = []
      let validFeatureIds = []

      // 2. Check which parents belong to current project
      if (logIds.length > 0) {
        try {
          const { data: logs } = await axios.get(`/logs?id=in.(${logIds.join(',')})&project_id=eq.${projectId}&select=id`)
          if (logs) validLogIds = logs.map(l => l.id)
        } catch (e) {
          console.error('Error verifying logs project:', e)
        }
      }

      if (featureIds.length > 0) {
        try {
          const { data: features } = await axios.get(`/feature_requests?id=in.(${featureIds.join(',')})&project_id=eq.${projectId}&select=id`)
          if (features) validFeatureIds = features.map(f => f.id)
        } catch (e) {
          console.error('Error verifying features project:', e)
        }
      }

      // 3. Filter discussions based on valid parents
      const filteredDiscussions = discData.filter(d => {
        if (d.parent_type === 'LOG') return validLogIds.includes(d.parent_id)
        if (d.parent_type === 'FEATURE') return validFeatureIds.includes(d.parent_id)
        return false
      })

      // 4. Map to display format (limit to 10)
      recentActivities.value = filteredDiscussions.slice(0, 10).map(d => ({
        user: d.user?.full_name || 'User',
        action: `mengomentari di forum ${d.parent_type}`,
        time: formatTime(d.created_at),
        avatar: d.user?.avatar_url || `https://ui-avatars.com/api/?name=${d.user?.full_name || 'User'}&background=random`,
        preview: d.comment_text,
        parent_id: d.parent_id,
        parent_type: d.parent_type
      }))
    }

  } catch (error) {
    console.error('Error fetching dashboard data:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchData()
})
</script>

<template>
  <div class="max-w-[1600px] mx-auto space-y-6">
    <!-- Main Content -->
    <div class="flex flex-col lg:flex-row gap-6">
      <!-- Left Column -->
      <div class="flex-1 flex flex-col gap-6 min-w-0">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <!-- Total Log & Bug -->
          <router-link to="/logs" class="bg-white dark:bg-[#141414] p-5 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm flex items-start justify-between hover:border-rose-500/50 transition-all group">
            <div>
              <p class="text-xs font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1">Total Log & Bug</p>
              <h3 class="text-3xl font-black text-slate-800 dark:text-white">{{ stats.totalLogs }}</h3>
              <div class="flex items-center gap-1 mt-2 text-rose-500 text-xs font-medium">
                <span class="material-symbols-outlined text-sm">warning</span>
                <span>{{ stats.criticalLogs }} Critical Logs</span>
              </div>
            </div>
            <div class="p-3 bg-rose-50 dark:bg-rose-900/20 rounded-lg text-rose-500 group-hover:scale-110 transition-transform">
              <span class="material-symbols-outlined text-2xl">bug_report</span>
            </div>
          </router-link>

          <!-- Total Version Control -->
          <router-link to="/version-control" class="bg-white dark:bg-[#141414] p-5 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm flex items-start justify-between hover:border-emerald-500/50 transition-all group">
            <div>
              <p class="text-xs font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1">Total Version Control</p>
              <h3 class="text-3xl font-black text-slate-800 dark:text-white">{{ stats.currentVersion }}</h3>
              <div class="flex items-center gap-1 mt-2 text-emerald-600 text-xs font-medium">
                <span class="material-symbols-outlined text-sm">commit</span>
                <span>{{ stats.totalCommits }} Versions</span>
              </div>
            </div>
            <div class="p-3 bg-emerald-50 dark:bg-emerald-900/20 rounded-lg text-emerald-600 group-hover:scale-110 transition-transform">
              <span class="material-symbols-outlined text-2xl">history</span>
            </div>
          </router-link>

          <!-- Total Access Control -->
          <router-link to="/access-control" class="bg-white dark:bg-[#141414] p-5 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm flex items-start justify-between hover:border-blue-500/50 transition-all group">
            <div>
              <p class="text-xs font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-1">Total Access Control</p>
              <h3 class="text-3xl font-black text-slate-800 dark:text-white">{{ stats.totalRoles }} Roles</h3>
              <div class="flex items-center gap-1 mt-2 text-blue-500 text-xs font-medium">
                <span class="material-symbols-outlined text-sm">view_module</span>
                <span>{{ stats.activeModules }} Real Modules</span>
              </div>
            </div>
            <div class="p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg text-blue-500 group-hover:scale-110 transition-transform">
              <span class="material-symbols-outlined text-2xl">admin_panel_settings</span>
            </div>
          </router-link>
        </div>

        <!-- Summary Section -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Log Error Trend (Line Chart) -->
          <router-link to="/logs" class="bg-white dark:bg-[#141414] p-6 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm flex flex-col hover:border-rose-500/30 transition-all">
            <div class="flex items-center justify-between mb-6">
              <h3 class="font-bold text-slate-800 dark:text-white flex items-center gap-2">
                <span class="material-symbols-outlined text-rose-500">trending_up</span>
                Tren Log Error Mingguan
              </h3>
              <div class="flex items-center gap-2">
                <span class="size-2 rounded-full bg-rose-500"></span>
                <span class="text-[10px] font-bold text-slate-400 uppercase">Total Logs</span>
              </div>
            </div>
            <div class="flex-1 h-[150px] w-full relative group/chart">
              <svg class="w-full h-full overflow-visible" viewBox="0 0 700 150" preserveAspectRatio="none">
                <defs>
                  <linearGradient id="logGradient" x1="0" x2="0" y1="0" y2="1">
                    <stop offset="0%" stop-color="#f43f5e" stop-opacity="0.2"></stop>
                    <stop offset="100%" stop-color="#f43f5e" stop-opacity="0"></stop>
                  </linearGradient>
                </defs>
                <path :d="`M0,${150 - (logTrendData[0].logs * 5)} L100,${150 - (logTrendData[1].logs * 5)} L200,${150 - (logTrendData[2].logs * 5)} L300,${150 - (logTrendData[3].logs * 5)} L400,${150 - (logTrendData[4].logs * 5)} L500,${150 - (logTrendData[5].logs * 5)} L600,${150 - (logTrendData[6].logs * 5)} L600,150 L0,150 Z`" fill="url(#logGradient)" />
                <path :d="`M0,${150 - (logTrendData[0].logs * 5)} L100,${150 - (logTrendData[1].logs * 5)} L200,${150 - (logTrendData[2].logs * 5)} L300,${150 - (logTrendData[3].logs * 5)} L400,${150 - (logTrendData[4].logs * 5)} L500,${150 - (logTrendData[5].logs * 5)} L600,${150 - (logTrendData[6].logs * 5)}`" fill="none" stroke="#f43f5e" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
              </svg>
              <div class="absolute -bottom-6 left-0 w-full flex justify-between text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                <span v-for="data in logTrendData" :key="data.day">{{ data.day }}</span>
              </div>
            </div>
          </router-link>

          <!-- Feature Requests Status -->
          <router-link to="/features" class="bg-white dark:bg-[#141414] p-6 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm hover:border-amber-500/50 transition-all group">
            <div class="flex items-center justify-between mb-6">
              <h3 class="font-bold text-slate-800 dark:text-white flex items-center gap-2">
                <span class="material-symbols-outlined text-amber-500">rocket_launch</span>
                Feature Requests Summary
              </h3>
              <span class="text-[10px] font-black bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full uppercase tracking-tighter">{{ stats.featureReview }} DITINJAU</span>
            </div>
            <div class="space-y-4">
              <div class="flex items-center gap-4">
                <div class="flex-1 bg-slate-100 dark:bg-gray-800 h-2 rounded-full overflow-hidden flex">
                  <div class="bg-emerald-500 h-full" :style="{ width: (stats.featureDev / (stats.featureReview + stats.featureDev || 1) * 100) + '%' }"></div>
                  <div class="bg-amber-500 h-full" :style="{ width: (stats.featureReview / (stats.featureReview + stats.featureDev || 1) * 100) + '%' }"></div>
                </div>
              </div>
              <div class="grid grid-cols-2 gap-4">
                <div class="flex flex-col">
                  <span class="text-[10px] font-bold text-slate-400 uppercase">Dikembangkan</span>
                  <span class="text-lg font-black text-emerald-600">{{ stats.featureDev }}</span>
                </div>
                <div class="flex flex-col">
                  <span class="text-[10px] font-bold text-slate-400 uppercase">Ditinjau</span>
                  <span class="text-lg font-black text-amber-600">{{ stats.featureReview }}</span>
                </div>
              </div>
            </div>
          </router-link>
        </div>

        <!-- Distribution & Severity Charts -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Severity Total (Pie Chart Style) -->
          <router-link to="/logs" class="bg-white dark:bg-[#141414] p-6 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm flex flex-col hover:border-rose-500/30 transition-all">
            <h3 class="font-bold text-slate-800 dark:text-white flex items-center gap-2 mb-6">
              <span class="material-symbols-outlined text-rose-500">pie_chart</span>
              Severitas Total (Log, Bug, Feature)
            </h3>
            <div class="flex-1 flex items-center gap-10">
              <div class="relative size-32 flex-shrink-0">
                <svg class="size-full -rotate-90" viewBox="0 0 36 36">
                  <circle cx="18" cy="18" r="16" fill="none" stroke="currentColor" stroke-width="4" class="text-slate-100 dark:text-gray-800" />
                  <circle cx="18" cy="18" r="16" fill="none" stroke="#f43f5e" stroke-width="4" :stroke-dasharray="`${(severityStats.critical / (severityStats.total || 1)) * 100}, 100`" stroke-dashoffset="0" />
                  <circle cx="18" cy="18" r="16" fill="none" stroke="#fb923c" stroke-width="4" :stroke-dasharray="`${(severityStats.high / (severityStats.total || 1)) * 100}, 100`" :stroke-dashoffset="`-${(severityStats.critical / (severityStats.total || 1)) * 100}`" />
                </svg>
                <div class="absolute inset-0 flex items-center justify-center flex-col">
                  <span class="text-lg font-black text-slate-800 dark:text-white">{{ severityStats.total }}</span>
                  <span class="text-[8px] font-bold text-slate-400 uppercase">Items</span>
                </div>
              </div>
              <div class="flex flex-col gap-3 justify-center flex-1">
                <div v-for="item in [
                  { label: 'Critical', color: 'bg-rose-500', count: severityStats.critical },
                  { label: 'High', color: 'bg-orange-400', count: severityStats.high },
                  { label: 'Medium', color: 'bg-amber-400', count: severityStats.medium },
                  { label: 'Low', color: 'bg-emerald-500', count: severityStats.low }
                ]" :key="item.label" class="flex items-center justify-between text-xs font-bold">
                  <div class="flex items-center gap-3">
                    <span :class="item.color" class="size-2.5 rounded-full"></span>
                    <span class="text-slate-500 uppercase tracking-tighter">{{ item.label }}</span>
                  </div>
                  <span class="text-slate-700 dark:text-slate-300 font-black">{{ item.count }}</span>
                </div>
              </div>
            </div>
          </router-link>

          <!-- Access Control Summary -->
          <div class="bg-white dark:bg-[#141414] p-6 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm flex flex-col">
            <div class="flex items-center justify-between mb-6">
              <h3 class="font-bold text-slate-800 dark:text-white flex items-center gap-2">
                <span class="material-symbols-outlined text-blue-500">security</span>
                Team Access Control Summary
              </h3>
              <router-link to="/access-control" class="text-[10px] font-black bg-blue-100 text-blue-700 px-3 py-1 rounded-lg hover:bg-blue-200 transition-colors">ADD NEW ROLE</router-link>
            </div>
            <div class="space-y-4">
              <div v-for="role in rolesSummary" :key="role.name">
                <div class="flex items-center justify-between text-[10px] font-bold mb-1">
                  <span class="text-slate-500 uppercase">{{ role.name }}</span>
                  <span class="text-slate-700 dark:text-slate-300"></span>
                </div>
                <!-- Removed percentage bar as requested -->
                <div class="w-full bg-slate-100 dark:bg-gray-800 h-1.5 rounded-full overflow-hidden opacity-30">
                  <div :class="`bg-${role.color}-500`" class="h-full rounded-full transition-all" style="width: 100%"></div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- My Logs Table (Reported by Current User) -->
        <div class="bg-white dark:bg-[#141414] rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm overflow-hidden">
          <div class="px-6 py-4 border-b border-slate-100 dark:border-gray-800 flex items-center justify-between">
            <h3 class="font-bold text-slate-800 dark:text-white flex items-center gap-2">
              <span class="material-symbols-outlined text-emerald-600">person_search</span>
              Daftar Log Saya (Terbaru)
            </h3>
            <router-link to="/logs" class="text-xs font-bold text-emerald-600 hover:text-emerald-700 hover:underline">Lihat Semua</router-link>
          </div>
          <div class="overflow-x-auto">
            <table class="w-full text-left text-sm">
              <thead class="bg-slate-50 dark:bg-[#1a1a1a]/50 text-slate-500 dark:text-slate-400 text-xs uppercase font-bold">
                <tr>
                  <th class="px-6 py-3">Issue / Log</th>
                  <th class="px-6 py-3">Tanggal</th>
                  <th class="px-6 py-3">Modul</th>
                  <th class="px-6 py-3">Status</th>
                  <th class="px-6 py-3 text-right">Severity</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100 dark:divide-gray-800">
                <tr v-for="log in myRecentLogs" :key="log.id" class="hover:bg-slate-50 dark:hover:bg-[#1a1a1a]/50 transition-colors cursor-pointer" @click="$router.push('/logs')">
                  <td class="px-6 py-4">
                    <div class="flex flex-col">
                      <span class="font-bold text-slate-800 dark:text-white line-clamp-1">#LOG-{{ log.no_lap || log.id }}</span>
                      <span class="text-[10px] text-slate-400 line-clamp-1">{{ log.actual_behavior || 'No description' }}</span>
                    </div>
                  </td>
                  <td class="px-6 py-4 text-xs font-medium text-slate-500">{{ new Date(log.created_at).toLocaleDateString('id-ID') }}</td>
                  <td class="px-6 py-4">
                    <span class="px-2 py-1 bg-slate-100 dark:bg-gray-800 text-[10px] font-bold rounded uppercase">{{ log.module || 'General' }}</span>
                  </td>
                  <td class="px-6 py-4">
                    <span :class="getStatusClass(log.status)" class="px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-tighter">
                      {{ log.status }}
                    </span>
                  </td>
                  <td class="px-6 py-4 text-right">
                    <span :class="getSeverityClass(log.priority)" class="text-xs font-black uppercase italic">{{ log.priority }}</span>
                  </td>
                </tr>
                <tr v-if="myRecentLogs.length === 0">
                  <td colspan="5" class="px-6 py-10 text-center text-slate-400 font-bold italic">Belum ada log yang Anda laporkan</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Right Column (Activity & News) -->
      <div class="w-full lg:w-[380px] flex flex-col gap-6">
        <!-- Recent Activities (Discussions) -->
        <div class="bg-white dark:bg-[#141414] p-6 rounded-xl border border-slate-200 dark:border-gray-800 shadow-sm flex-1">
          <h3 class="font-bold text-slate-800 dark:text-white flex items-center gap-2 mb-6">
            <span class="material-symbols-outlined text-blue-500">forum</span>
            Aktivitas Diskusi Terkini
          </h3>
          <div class="space-y-6">
            <div v-for="(activity, i) in recentActivities" :key="i" class="flex gap-4 group cursor-pointer" @click="handleActivityClick(activity)">
              <div class="relative">
                <img :src="activity.avatar" class="size-10 rounded-full border-2 border-white dark:border-gray-800 shadow-sm" />
                <div v-if="activity.icon" class="absolute -bottom-1 -right-1 size-5 bg-rose-500 text-white rounded-full flex items-center justify-center border-2 border-white dark:border-[#141414]">
                  <span class="material-symbols-outlined text-[10px]">{{ activity.icon }}</span>
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between mb-0.5">
                  <p class="text-xs font-black text-slate-800 dark:text-white truncate">{{ activity.user }}</p>
                  <span class="text-[9px] font-bold text-slate-400 whitespace-nowrap uppercase tracking-tighter">{{ activity.time }}</span>
                </div>
                <p class="text-[11px] text-slate-500 dark:text-slate-400 mb-1 leading-tight">{{ activity.action }}</p>
                <div class="p-2 bg-slate-50 dark:bg-gray-800/50 rounded-lg border border-slate-100 dark:border-gray-800 group-hover:border-blue-500/30 transition-all">
                  <p class="text-[10px] text-slate-600 dark:text-slate-300 italic line-clamp-2">"{{ activity.preview }}"</p>
                </div>
              </div>
            </div>
            <div v-if="recentActivities.length === 0" class="text-center py-10 text-slate-400 font-bold italic text-sm">Belum ada aktivitas diskusi</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>