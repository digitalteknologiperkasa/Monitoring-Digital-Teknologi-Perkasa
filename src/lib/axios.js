import axios from 'axios'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

const axiosInstance = axios.create({
  baseURL: `${supabaseUrl}/rest/v1`,
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
    const { supabase } = await import('./supabase')
    const { data: { session } } = await supabase.auth.getSession()
    
    if (session?.access_token) {
      config.headers['Authorization'] = `Bearer ${session.access_token}`
    }
  } catch (e) {
    console.error('Error getting session for axios:', e)
  }
  return config
})

export default axiosInstance
