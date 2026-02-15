import { defineStore } from 'pinia'
import { supabase } from '../lib/supabase'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    session: null,
    loading: true,
  }),
  actions: {
    async initialize() {
      this.loading = true
      try {
        const { data: { session } } = await supabase.auth.getSession()
        this.session = session
        
        if (session?.user) {
          // Ambil Profile
          let { data: profile, error: profileError } = await supabase
            .from('profiles')
            .select('role, project_id')
            .eq('id', session.user.id)
            .single()
          
          // Jika profile tidak ada, buatkan (terutama untuk user yang dibuat manual di dashboard)
          if (profileError && profileError.code === 'PGRST116') {
            // Tunggu sebentar untuk memastikan jika ini user baru yang dibuat via TeamManagement
            // maka profile-nya mungkin sedang dalam proses insert/upsert
            await new Promise(resolve => setTimeout(resolve, 1500));
            
            // Cek ulang profile
            let { data: recheckProfile } = await supabase
              .from('profiles')
              .select('role, project_id, description')
              .eq('id', session.user.id)
              .single()
            
            if (recheckProfile) {
              profile = recheckProfile;
            } else {
              console.log('Profile not found after wait, creating default profile for user:', session.user.email);
              const { data: newProfile, error: createError } = await supabase
                .from('profiles')
                .insert([
                  { 
                    id: session.user.id, 
                    full_name: session.user.email.split('@')[0], 
                    email: session.user.email,
                    role: 'Viewer' 
                  }
                ])
                .select()
                .single()
              
              if (createError) {
                console.error('Failed to create default profile:', createError);
              } else {
                profile = newProfile;
                console.log('Default profile created successfully.');
              }
            }
          }
          
          let finalRole = profile?.role || 'Viewer'

          // RESCUE LOGIC: Paksa Admin jika email sesuai
          if (['admin@digitek.com', 'ganjarpranowo@pdi.com'].includes(session.user.email)) {
            finalRole = 'Super Admin'
            // Sync balik ke DB jika ternyata di DB masih Viewer
            if (profile?.role !== 'Super Admin') {
              console.log('Syncing Super Admin role to DB for:', session.user.email);
              const { error: syncError } = await supabase.from('profiles').update({ role: 'Super Admin' }).eq('id', session.user.id)
              if (syncError) {
                console.error('Failed to sync Super Admin role to DB:', syncError);
              } else {
                console.log('Successfully synced Super Admin role to DB.');
              }
            }
          }
          
          this.user = { ...session.user, role: finalRole, project_id: profile?.project_id || 1, description: profile?.description }
        } else {
          this.user = null
        }

        supabase.auth.onAuthStateChange(async (_event, session) => {
          this.session = session
          if (session?.user) {
            const { data: profile } = await supabase
              .from('profiles')
              .select('role, project_id, description')
              .eq('id', session.user.id)
              .single()
            
            let finalRole = profile?.role || 'Viewer'
            if (['admin@digitek.com', 'ganjarpranowo@pdi.com'].includes(session.user.email)) {
              finalRole = 'Super Admin'
            }
            this.user = { ...session.user, role: finalRole, project_id: profile?.project_id || 1, description: profile?.description }
          } else {
            this.user = null
          }
        })
      } catch (error) {
        console.error('Auth initialization error:', error)
      } finally {
        this.loading = false
      }
    },

    async signIn(email, password) {
      console.log('Attempting Supabase sign in for:', email);
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })
      
      if (error) {
        console.error('Supabase sign in error:', error);
        throw error;
      }

      console.log('Supabase sign in successful. Data:', data);

      if (data.user) {
        console.log('Fetching profile for user ID:', data.user.id);
        const { data: profile, error: profileError } = await supabase
          .from('profiles')
          .select('role')
          .eq('id', data.user.id)
          .single()

        if (profileError) {
          console.error('Error fetching profile:', profileError);
        }
        
        console.log('Fetched profile:', profile);

        let finalRole = profile?.role || 'Viewer' // Default ke 'Viewer' jika tidak ada profil
        console.log('Initial role:', finalRole);

        if (['admin@digitek.com', 'ganjarpranowo@pdi.com'].includes(data.user.email)) {
          finalRole = 'Super Admin'
          console.log('User is Super Admin. Role set to:', finalRole);
          // Sync balik ke DB jika perlu
          if (profile?.role !== 'Super Admin') {
            console.log('Syncing Super Admin role to DB...');
            await supabase.from('profiles').update({ role: 'Super Admin' }).eq('id', data.user.id)
          }
        }
        
        this.user = { ...data.user, role: finalRole }
        console.log('Final user object set in store:', this.user);
      }

      return data
    },

    async signUp(email, password, metadata = {}) {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: metadata
        }
      })
      
      if (error) throw error

      if (data.user) {
        // Create Profile Entry if not exists (User might be created without profile if trigger is missing)
        const { error: profileError } = await supabase
          .from('profiles')
          .insert({
            id: data.user.id,
            email: email,
            full_name: metadata.full_name || email.split('@')[0],
            role: 'Viewer'
          })
          .select()
          .single()
          
        if (profileError) {
          console.warn('Profile creation failed (might already exist):', profileError)
        }
      }

      return data
    },

    async signOut() {
      const { error } = await supabase.auth.signOut()
      if (error) throw error
      this.user = null
      this.session = null
    }
  }
})
