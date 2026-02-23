import axios from 'axios'
import { supabase } from './supabase'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

const axiosInstance = axios.create({
  baseURL: `${supabaseUrl}/rest/v1`,
  timeout: 10000, // 10 seconds timeout
  headers: {
    'apikey': supabaseAnonKey,
    'Authorization': `Bearer ${supabaseAnonKey}`,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
  }
})

// Interceptor untuk menangani token user jika ada session
axiosInstance.interceptors.request.use(async (config) => {
  try {
    // Gunakan session dari store jika sudah ada (lebih cepat/non-blocking)
    let session = null
    
    try {
      const { useAuthStore } = await import('../stores/auth')
      const authStore = useAuthStore()
      session = authStore.session
    } catch (e) {
      console.warn('Axios Interceptor: Could not access authStore directly')
    }

    // Jika di store tidak ada, coba ambil dari SDK dengan timeout ketat
    if (!session) {
      console.log('Axios Interceptor: Fetching session from SDK...')
      const sessionPromise = supabase.auth.getSession()
      const timeoutPromise = new Promise((resolve) => setTimeout(() => resolve({ data: { session: null }, error: 'timeout' }), 2000))
      const { data: { session: sdkSession } } = await Promise.race([sessionPromise, timeoutPromise])
      session = sdkSession
    }
    
    if (session?.access_token) {
      config.headers['Authorization'] = `Bearer ${session.access_token}`
    } else {
      // Fallback ke anon key (PENTING untuk RLS Read pada tabel public)
      config.headers['Authorization'] = `Bearer ${supabaseAnonKey}`
    }
  } catch (e) {
    console.error('Error getting session for axios:', e)
    config.headers['Authorization'] = `Bearer ${supabaseAnonKey}`
  }
  return config
})

export default axiosInstance
