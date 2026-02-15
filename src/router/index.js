import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { supabase } from '../lib/supabase'
import MainLayout from '../layouts/MainLayout.vue'
import Dashboard from '../views/Dashboard.vue'
import Login from '../views/Login.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: Login,
      meta: { guest: true }
    },
    {
      path: '/',
      component: MainLayout,
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'dashboard',
          component: Dashboard,
          meta: { title: 'Dashboard Overview', subtitle: 'Overview sistem dan status pembaruan' }
        },
        {
          path: 'logs',
          name: 'logs',
          component: () => import('../views/Logs.vue'),
          meta: { title: 'Manajemen Semua Log', subtitle: 'Monitoring dan tracking error sistem' }
        },
        {
          path: 'version-control',
          name: 'version-control',
          component: () => import('../views/VersionControl.vue'),
          meta: { title: 'Version Control', subtitle: 'Riwayat pembaruan dan rilis sistem' }
        },
        {
          path: 'access-control',
          name: 'access-control',
          component: () => import('../views/AccessControl.vue'),
          meta: { title: 'Access Control', subtitle: 'Manajemen hak akses dan role pengguna' }
        },
        {
          path: 'reports',
          name: 'reports',
          component: () => import('../views/Reports.vue'),
          meta: { title: 'Laporan & Statistik', subtitle: 'Analisis data dan performa sistem' }
        },
        {
          path: 'features',
          name: 'features',
          component: () => import('../views/FeatureManagement.vue'),
          meta: { title: 'Manajemen Fitur', subtitle: 'Perencanaan dan penambahan fitur baru' }
        },
        {
          path: 'settings',
          name: 'settings',
          component: () => import('../views/Settings.vue'),
          meta: { title: 'Pengaturan', subtitle: 'Konfigurasi sistem dan preferensi' }
        },
        {
          path: 'team',
          name: 'team',
          component: () => import('../views/TeamManagement.vue'),
          meta: { 
            title: 'Manajemen Akses Tim', 
            subtitle: 'Manage roles and permissions for the development team',
            roles: ['Super Admin', 'Editor']
          }
        }
      ]
    }
  ]
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  if (authStore.loading) {
    await authStore.initialize()
  }

  const isAuthenticated = !!authStore.user

  if (to.meta.requiresAuth && !isAuthenticated) {
    return next('/login')
  } 
  
  if (to.meta.guest && isAuthenticated) {
    return next('/')
  }

  // Role based access control
  if (to.meta.roles && isAuthenticated) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', authStore.user.id)
      .single()
    
    const userRole = profile?.role || 'Viewer'
    if (!to.meta.roles.includes(userRole)) {
      return next('/')
    }
  }

  next()
})

export default router
