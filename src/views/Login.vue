<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth.js'
import { supabase } from '../lib/supabase.js'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMessage = ref('')
const showPassword = ref(false)
const isDarkMode = ref(document.documentElement.classList.contains('dark'))

const toggleDarkMode = () => {
  isDarkMode.value = !isDarkMode.value
  document.documentElement.classList.toggle('dark')
  localStorage.setItem('darkMode', isDarkMode.value)
}

const togglePasswordVisibility = () => {
  showPassword.value = !showPassword.value
}

const isRegistering = ref(false)
const fullName = ref('')

const toggleAuthMode = () => {
  isRegistering.value = !isRegistering.value
  errorMessage.value = ''
}

const handleLogin = async () => {
  loading.value = true
  errorMessage.value = ''
  
  try {
    const trimmedEmail = email.value.trim()
    const trimmedPassword = password.value.trim()

    if (isRegistering.value) {
      await authStore.signUp(trimmedEmail, trimmedPassword, {
        full_name: fullName.value
      })
      errorMessage.value = 'Registrasi berhasil! Silakan cek email untuk verifikasi (jika perlu) atau login.'
      isRegistering.value = false
    } else {
      console.log('Attempting login for:', trimmedEmail)
      await authStore.signIn(trimmedEmail, trimmedPassword)
      // Redirect based on role or to dashboard
      router.push('/')
    }
  } catch (error) {
    console.error('Login error:', error)
    errorMessage.value = error.message || 'Gagal Login. Silakan coba lagi.'
    
    // Suggestion for invalid credentials
    if (error.message.includes('Invalid login credentials')) {
      errorMessage.value = 'Email atau password salah. Pastikan tidak ada spasi tambahan.'
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="bg-slate-50 dark:bg-[#0a0a0a] font-display text-gray-900 dark:text-white min-h-screen transition-colors duration-300">
    <div class="absolute top-6 right-6 z-50">
      <button @click="toggleDarkMode" class="p-2.5 rounded-full bg-white dark:bg-[#141414] shadow-sm border border-gray-200 dark:border-gray-800 text-gray-600 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-[#1a1a1a] transition-colors">
        <span class="material-symbols-outlined">{{ isDarkMode ? 'light_mode' : 'dark_mode' }}</span>
      </button>
    </div>

    <div class="flex min-h-screen">
      <!-- LEFT SIDE: BRANDING -->
      <div class="hidden lg:flex lg:w-1/2 relative bg-gradient-to-br from-[#003d38] to-[#001D1A] overflow-hidden items-center justify-center">
        <div class="absolute inset-0 overflow-hidden opacity-30 pointer-events-none">
          <div class="absolute -top-[10%] -left-[10%] w-[50%] h-[50%] rounded-full bg-emerald-400 blur-[120px]"></div>
          <div class="absolute -bottom-[10%] -right-[10%] w-[40%] h-[40%] rounded-full bg-emerald-600 blur-[100px]"></div>
        </div>
        <div class="relative z-10 px-12 text-center max-w-lg">
          <div class="mb-10 flex justify-center">
            <div class="bg-center bg-no-repeat aspect-square bg-contain rounded-lg size-24 bg-[#121417] p-4 shadow-2xl border border-white/10" style="background-image: url('https://raw.githubusercontent.com/thealfin/Monitoring-Log-Error-Bug-Digital-Teknologi-Perkasa/main/media/digitek%20putih.webp');"></div>
          </div>
          <h1 class="text-4xl font-extrabold text-white mb-6 leading-tight tracking-tight">Monitoring<br>Log Error & Bug</h1>
          <p class="text-xl text-emerald-50 font-light leading-relaxed">
            By PT. Digital Teknologi Perkasa<br>Manage and Track Your Systems Effectively
          </p>
          <div class="mt-12 flex items-center justify-center gap-4 text-emerald-200/60">
            <span class="material-symbols-outlined">security</span>
            <span class="text-sm font-medium tracking-widest uppercase">High Performance Bug Tracking</span>
          </div>
        </div>
      </div>

      <!-- RIGHT SIDE: LOGIN FORM -->
      <div class="flex-1 flex flex-col justify-center items-center p-6 sm:p-12 md:p-20">
        <div class="w-full max-w-[440px]">
          <div class="lg:hidden flex flex-col items-center mb-8">
            <div class="bg-center bg-no-repeat aspect-square bg-contain rounded-lg size-14 mb-4 bg-[#121417] p-2 border border-gray-100 dark:border-gray-800 shadow-md" style="background-image: url('https://raw.githubusercontent.com/thealfin/Monitoring-Log-Error-Bug-Digital-Teknologi-Perkasa/main/media/digitek%20putih.webp');"></div>
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Digital Teknologi Perkasa</h2>
            <p class="text-emerald-700 dark:text-emerald-400 text-sm font-medium">Log Monitoring</p>
          </div>
          
          <div class="mb-10 text-center lg:text-left">
            <h2 class="text-3xl font-extrabold text-gray-900 dark:text-white mb-2">{{ isRegistering ? 'Create Account' : 'Welcome' }}</h2>
            <p class="text-gray-600 dark:text-gray-400">{{ isRegistering ? 'Sign up to get started.' : 'Please enter your details to sign in.' }}</p>
          </div>

          <div class="bg-white dark:bg-[#141414] p-8 rounded-lg shadow-sm border border-gray-100 dark:border-gray-800">
            <!-- Error Message -->
            <div v-if="errorMessage" class="mb-6 p-4 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-100 dark:border-red-900/30 flex items-start gap-3 animate-shake">
              <span class="material-symbols-outlined text-red-500 text-xl mt-0.5">error</span>
              <p class="text-sm font-medium text-red-600 dark:text-red-400 leading-snug">
                {{ errorMessage }}
              </p>
            </div>

            <form @submit.prevent="handleLogin" class="space-y-6">
              <div v-if="isRegistering">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" for="fullname">Full Name</label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <span class="material-symbols-outlined text-gray-400 dark:text-gray-500 text-lg">person</span>
                  </div>
                  <input v-model="fullName" class="w-full bg-gray-50 dark:bg-[#1a1a1a] border border-gray-200 dark:border-gray-800 rounded-lg px-4 py-3.5 pl-11 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-600 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-600 transition-all" id="fullname" placeholder="John Doe" type="text" required />
                </div>
              </div>
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" for="email">Email Address</label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <span class="material-symbols-outlined text-gray-400 dark:text-gray-500 text-lg">alternate_email</span>
                  </div>
                  <input v-model="email" class="w-full bg-gray-50 dark:bg-[#1a1a1a] border border-gray-200 dark:border-gray-800 rounded-lg px-4 py-3.5 pl-11 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-600 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-600 transition-all" id="email" placeholder="Masukan Email Anda" type="email" required />
                </div>
              </div>
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2" for="password">Password</label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <span class="material-symbols-outlined text-gray-400 dark:text-gray-500 text-lg">lock</span>
                  </div>
                  <input v-model="password" :type="showPassword ? 'text' : 'password'" class="w-full bg-gray-50 dark:bg-[#1a1a1a] border border-gray-200 dark:border-gray-800 rounded-lg px-4 py-3.5 pl-11 pr-11 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-600 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-600 transition-all" id="password" placeholder="••••••••" required />
                  <button type="button" @click="togglePasswordVisibility" class="absolute inset-y-0 right-0 pr-4 flex items-center text-gray-400 hover:text-emerald-500 transition-colors">
                    <span class="material-symbols-outlined text-xl">{{ showPassword ? 'visibility_off' : 'visibility' }}</span>
                  </button>
                </div>
              </div>
              <div class="flex items-center justify-between py-1">
                <div class="flex items-center">
                  <input class="h-4 w-4 rounded border-gray-300 bg-white dark:bg-[#1a1a1a] text-emerald-600 focus:ring-emerald-500/20 focus:ring-offset-0" id="remember-me" name="remember-me" type="checkbox" />
                  <label class="ml-2 block text-sm text-gray-600 dark:text-gray-400" for="remember-me">Remember me</label>
                </div>
                <a class="text-sm font-semibold text-emerald-700 dark:text-emerald-400 hover:text-emerald-600 transition-colors" href="#">Forgot password?</a>
              </div>
              <button 
                :disabled="loading" 
                class="w-full bg-[#032A28] hover:bg-[#021A18] active:bg-[#01100F] dark:bg-emerald-500 dark:hover:bg-emerald-600 dark:active:bg-emerald-700 text-white font-bold py-4 rounded-lg shadow-lg shadow-emerald-900/10 transition-all flex items-center justify-center gap-2 group disabled:opacity-70" 
                type="submit">
                <span v-if="loading">Processing...</span>
                <span v-else>{{ isRegistering ? 'Sign Up' : 'Log In' }}</span>
              </button>
              
              <div class="text-center mt-6">
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  {{ isRegistering ? 'Already have an account?' : "Don't have an account?" }}
                  <button type="button" @click="toggleAuthMode" class="font-medium text-emerald-600 hover:text-emerald-500 transition-colors ml-1">
                    {{ isRegistering ? 'Sign In' : 'Sign Up' }}
                  </button>
                </p>
              </div>
            </form>
          </div>
          <div class="mt-10 text-center">
            <p class="text-sm text-gray-500 dark:text-gray-500">
              © 2026 Digital Teknologi Perkasa. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}
.animate-shake {
  animation: shake 0.2s cubic-bezier(.36,.07,.19,.97) both;
}
</style>
