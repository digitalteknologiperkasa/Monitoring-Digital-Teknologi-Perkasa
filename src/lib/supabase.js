import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)

// Create a separate client for administrative tasks (if service role key is available)
// Note: This should ideally only be used in a secure environment
export const supabaseAdmin = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY 
  ? createClient(supabaseUrl, import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })
  : null

