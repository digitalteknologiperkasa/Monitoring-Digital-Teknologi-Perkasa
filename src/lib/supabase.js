import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// Main Supabase client for regular users
export const supabase = createClient(supabaseUrl, supabaseKey)

// Separate client for admin tasks mapping to service_role (BE CAREFUL)
export const supabaseAdmin = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY 
  ? createClient(supabaseUrl, import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false // Prevent warning
      }
    })
  : null

console.log('Supabase clients initialized. Admin available:', !!supabaseAdmin)

