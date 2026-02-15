<script setup>
import { ref } from 'vue'

const timeRange = ref('Last 6 Months')

const moduleDistribution = ref([
  { name: 'Akademik', percentage: 65, color: 'bg-emerald-900' },
  { name: 'Keuangan', percentage: 45, color: 'bg-emerald-500' },
  { name: 'Asrama', percentage: 80, color: 'bg-teal-400' },
  { name: 'Mobile', percentage: 30, color: 'bg-emerald-700' }
])

const rolesDistribution = ref([
  { name: 'Admin', percentage: 15, color: 'bg-emerald-900' },
  { name: 'Guru', percentage: 35, color: 'bg-emerald-500' },
  { name: 'Santri', percentage: 50, color: 'bg-teal-300' }
])

const monthlyComparison = ref([
  { month: 'Jan', bugs: 65, versions: 30 },
  { month: 'Feb', bugs: 45, versions: 25 },
  { month: 'Mar', bugs: 80, versions: 40 },
  { month: 'Apr', bugs: 55, versions: 35 },
  { month: 'Mei', bugs: 90, versions: 50 },
  { month: 'Jun', bugs: 70, versions: 45 }
])
</script>

<template>
    <!-- Coming Soon Banner -->
    <div class="relative overflow-hidden bg-gradient-to-r from-emerald-600 to-teal-600 rounded-2xl p-8 shadow-lg shadow-emerald-500/20">
      <div class="relative z-10 flex flex-col md:flex-row items-center justify-between gap-6 text-white">
        <div class="space-y-2 text-center md:text-left">
          <h2 class="text-2xl md:text-3xl font-black tracking-tight">Analisis & Laporan Sistem</h2>
          <p class="text-emerald-50/80 font-medium">Data performa dan aktivitas sistem secara real-time.</p>
        </div>
        <div class="flex-shrink-0 bg-white/20 backdrop-blur-md rounded-xl p-4 border border-white/30">
          <span class="material-symbols-outlined text-4xl">analytics</span>
        </div>
      </div>
      <!-- Decorative background elements -->
      <div class="absolute -right-10 -top-10 size-40 bg-white/10 rounded-full blur-3xl"></div>
      <div class="absolute -left-10 -bottom-10 size-40 bg-black/10 rounded-full blur-3xl"></div>
    </div>

    <!-- Content Section (Coming Soon) -->
    <div class="relative group mt-6">
      <!-- Coming Soon Overlay -->
      <div class="absolute inset-0 z-20 flex flex-col items-center justify-center bg-white/10 dark:bg-black/10 backdrop-blur-[12px] rounded-2xl border border-white/20 transition-all duration-500 group-hover:backdrop-blur-[8px]">
        <div class="bg-white/90 dark:bg-[#1a1a1a]/90 p-8 rounded-3xl shadow-2xl border border-slate-200 dark:border-gray-800 flex flex-col items-center text-center max-w-md mx-4 transform transition-transform group-hover:scale-105">
          <div class="size-20 bg-emerald-100 dark:bg-emerald-900/30 rounded-full flex items-center justify-center mb-6 animate-bounce">
            <span class="material-symbols-outlined text-4xl text-emerald-600">construction</span>
          </div>
          <h3 class="text-2xl font-black text-slate-800 dark:text-white mb-3">Segera Hadir!</h3>
          <p class="text-slate-500 dark:text-slate-400 font-medium mb-6">
            Fitur Analisis & Laporan mendalam sedang dalam tahap pengembangan untuk memberikan wawasan yang lebih baik bagi sistem Anda.
          </p>
          <div class="flex gap-3">
            <div class="px-4 py-2 rounded-full bg-slate-100 dark:bg-gray-800 text-[10px] font-bold text-slate-500 uppercase tracking-widest">
              Q3 2024
            </div>
            <div class="px-4 py-2 rounded-full bg-emerald-500 text-[10px] font-bold text-white uppercase tracking-widest animate-pulse">
              In Progress
            </div>
          </div>
        </div>
      </div>

      <!-- Blurred Content -->
      <div class="filter blur-sm pointer-events-none select-none">
        <!-- Top Row: Summary Charts -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Monthly Bug Trend -->
        <div class="bg-white dark:bg-slate-800 p-6 rounded-xl border border-slate-200 dark:border-slate-700 shadow-sm flex flex-col">
          <div class="flex justify-between items-start mb-4">
            <div>
              <h3 class="text-slate-500 dark:text-slate-400 text-sm font-bold uppercase tracking-wider">Tren Bug Bulanan</h3>
              <div class="flex items-baseline gap-2 mt-1">
                <span class="text-3xl font-black text-slate-800 dark:text-white">124</span>
                <span class="text-xs font-bold text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20 px-1.5 py-0.5 rounded flex items-center">
                  <span class="material-symbols-outlined text-[14px] mr-0.5">trending_down</span>
                  -5%
                </span>
              </div>
              <span class="text-[10px] text-slate-400 dark:text-slate-500 mt-1 block">vs bulan lalu</span>
            </div>
            <div class="w-10 h-10 rounded-lg bg-emerald-50 dark:bg-emerald-900/20 flex items-center justify-center text-emerald-600">
              <span class="material-symbols-outlined">bug_report</span>
            </div>
          </div>
          <div class="mt-auto h-[120px] w-full relative">
            <svg class="w-full h-full overflow-visible" preserveAspectRatio="none" viewBox="0 0 300 100">
              <defs>
                <linearGradient id="gradientLine" x1="0" x2="0" y1="0" y2="1">
                  <stop offset="0%" stop-color="#10b981" stop-opacity="0.2"></stop>
                  <stop offset="100%" stop-color="#10b981" stop-opacity="0"></stop>
                </linearGradient>
              </defs>
              <path d="M0,80 C50,80 50,40 100,40 C150,40 150,60 200,60 C250,60 250,20 300,30" fill="none" stroke="#e5e7eb" stroke-dasharray="4 4" stroke-width="2" class="dark:stroke-slate-700"></path>
              <path d="M0,70 C40,70 60,30 100,35 C140,40 160,80 200,60 C240,40 260,20 300,45" fill="url(#gradientLine)" stroke="#10b981" stroke-linecap="round" stroke-width="3"></path>
              <circle cx="300" cy="45" fill="#10b981" r="4" stroke="white" stroke-width="2" class="dark:stroke-slate-800"></circle>
            </svg>
          </div>
        </div>
        
        <!-- Version Distribution -->
        <div class="bg-white dark:bg-slate-800 p-6 rounded-xl border border-slate-200 dark:border-slate-700 shadow-sm flex flex-col">
          <div class="flex justify-between items-start mb-4">
            <div>
              <h3 class="text-slate-500 dark:text-slate-400 text-sm font-bold uppercase tracking-wider">Distribusi Rilis Versi</h3>
              <div class="flex items-baseline gap-2 mt-1">
                <span class="text-3xl font-black text-slate-800 dark:text-white">12</span>
                <span class="text-xs font-bold text-blue-600 bg-blue-50 dark:bg-blue-900/20 px-1.5 py-0.5 rounded flex items-center">
                  <span class="material-symbols-outlined text-[14px] mr-0.5">arrow_upward</span>
                  +2
                </span>
              </div>
              <span class="text-[10px] text-slate-400 dark:text-slate-500 mt-1 block">Modul aktif diperbarui</span>
            </div>
            <div class="w-10 h-10 rounded-lg bg-blue-50 dark:bg-blue-900/20 flex items-center justify-center text-blue-600">
              <span class="material-symbols-outlined">layers</span>
            </div>
          </div>
          <div class="flex items-end justify-around h-[120px] gap-2">
            <div v-for="mod in moduleDistribution" :key="mod.name" class="flex flex-col items-center gap-2 group w-1/4">
              <div class="w-full bg-slate-100 dark:bg-slate-900/50 rounded-t-md relative h-full flex items-end overflow-hidden">
                <div :class="mod.color" class="w-full rounded-t-md transition-all group-hover:opacity-80" :style="{ height: mod.percentage + '%' }"></div>
              </div>
              <span class="text-[9px] font-bold text-slate-500 uppercase truncate w-full text-center">{{ mod.name }}</span>
            </div>
          </div>
        </div>

        <!-- Role Access Donut -->
        <div class="bg-white dark:bg-slate-800 p-6 rounded-xl border border-slate-200 dark:border-slate-700 shadow-sm flex flex-col">
          <div class="flex justify-between items-start mb-2">
            <div>
              <h3 class="text-slate-500 dark:text-slate-400 text-sm font-bold uppercase tracking-wider">Status Akses Role</h3>
              <div class="flex items-baseline gap-2 mt-1">
                <span class="text-3xl font-black text-slate-800 dark:text-white">450</span>
                <span class="text-xs text-slate-500 dark:text-slate-400 ml-1 font-medium">Total Users</span>
              </div>
            </div>
            <div class="w-10 h-10 rounded-lg bg-purple-50 dark:bg-purple-900/20 flex items-center justify-center text-purple-600">
              <span class="material-symbols-outlined">group</span>
            </div>
          </div>
          <div class="flex items-center gap-6 mt-auto">
            <div class="relative w-28 h-28 flex-shrink-0">
              <svg class="w-full h-full -rotate-90" viewBox="0 0 36 36">
                <path class="text-slate-100 dark:text-slate-700" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="currentColor" stroke-width="4.5"></path>
                <path class="text-emerald-900 dark:text-emerald-500" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="currentColor" stroke-dasharray="15, 100" stroke-width="4.5"></path>
                <path class="text-emerald-500 dark:text-emerald-400" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="currentColor" stroke-dasharray="35, 100" stroke-dashoffset="-15" stroke-width="4.5"></path>
                <path class="text-teal-300 dark:text-teal-200" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" fill="none" stroke="currentColor" stroke-dasharray="50, 100" stroke-dashoffset="-50" stroke-width="4.5"></path>
              </svg>
              <div class="absolute inset-0 flex items-center justify-center">
                <span class="material-symbols-outlined text-slate-400 text-xl">pie_chart</span>
              </div>
            </div>
            <div class="flex flex-col gap-2 justify-center flex-1">
              <div v-for="role in rolesDistribution" :key="role.name" class="flex items-center justify-between text-[10px] font-bold">
                <div class="flex items-center gap-2">
                  <span :class="role.color" class="w-2 h-2 rounded-full"></span>
                  <span class="text-slate-600 dark:text-slate-400 uppercase tracking-wide">{{ role.name }}</span>
                </div>
                <span class="text-slate-800 dark:text-white">{{ role.percentage }}%</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Middle Row: Comparison Chart -->
      <div class="bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 shadow-sm p-6">
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
          <div>
            <h3 class="text-lg font-black text-slate-800 dark:text-white">Perbandingan Bug Selesai vs Rilis</h3>
            <p class="text-xs text-slate-500 dark:text-slate-400 font-medium">Analisis produktivitas tim dalam 6 bulan terakhir</p>
          </div>
          <div class="flex flex-wrap items-center gap-6">
            <div class="flex items-center gap-4">
              <div class="flex items-center gap-2">
                <span class="w-3 h-3 rounded-full bg-emerald-900 dark:bg-emerald-500"></span>
                <span class="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Bug Resolved</span>
              </div>
              <div class="flex items-center gap-2">
                <span class="w-3 h-3 rounded-full bg-emerald-100 dark:bg-emerald-900/50"></span>
                <span class="text-[10px] font-bold text-slate-500 uppercase tracking-wider">Versions Released</span>
              </div>
            </div>
            <select v-model="timeRange" class="bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 text-xs font-bold text-slate-600 dark:text-slate-300 py-1.5 px-3 rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none transition-all">
              <option>Last 6 Months</option>
              <option>Last Year</option>
            </select>
          </div>
        </div>

        <div class="relative h-64 w-full mt-4">
          <!-- Grid Lines -->
          <div class="absolute inset-0 flex flex-col justify-between text-[10px] font-bold text-slate-400 dark:text-slate-600 pointer-events-none pb-8">
            <div class="border-b border-slate-100 dark:border-slate-800 w-full flex items-center relative h-0">
              <span class="absolute -left-8">100</span>
            </div>
            <div class="border-b border-slate-100 dark:border-slate-800 w-full flex items-center relative h-0">
              <span class="absolute -left-8">75</span>
            </div>
            <div class="border-b border-slate-100 dark:border-slate-800 w-full flex items-center relative h-0">
              <span class="absolute -left-8">50</span>
            </div>
            <div class="border-b border-slate-100 dark:border-slate-800 w-full flex items-center relative h-0">
              <span class="absolute -left-8">25</span>
            </div>
            <div class="border-b border-slate-100 dark:border-slate-800 w-full flex items-center relative h-0">
              <span class="absolute -left-8">0</span>
            </div>
          </div>
          <!-- Bars -->
          <div class="absolute inset-0 flex items-end justify-between px-4 sm:px-12 pb-8 pt-4">
            <div v-for="item in monthlyComparison" :key="item.month" class="flex flex-col items-center gap-3 h-full justify-end group cursor-pointer w-1/6">
              <div class="flex items-end gap-1.5 h-full w-full justify-center">
                <div class="w-3 sm:w-6 bg-emerald-900 dark:bg-emerald-500 rounded-t-sm hover:opacity-80 transition-all relative" :style="{ height: item.bugs + '%' }">
                  <div class="opacity-0 group-hover:opacity-100 absolute -top-8 left-1/2 -translate-x-1/2 bg-slate-800 text-white text-[10px] font-bold px-2 py-1 rounded whitespace-nowrap z-10">
                    {{ item.bugs }} Bugs
                  </div>
                </div>
                <div class="w-3 sm:w-6 bg-emerald-100 dark:bg-emerald-900/50 rounded-t-sm hover:bg-emerald-200 dark:hover:bg-emerald-900/80 transition-all relative" :style="{ height: item.versions + '%' }">
                  <div class="opacity-0 group-hover:opacity-100 absolute -top-8 left-1/2 -translate-x-1/2 bg-slate-800 text-white text-[10px] font-bold px-2 py-1 rounded whitespace-nowrap z-10">
                    {{ item.versions }} Vers
                  </div>
                </div>
              </div>
              <span class="text-[10px] font-bold text-slate-500 dark:text-slate-400 uppercase tracking-widest">{{ item.month }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}
</style>
