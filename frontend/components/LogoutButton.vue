<template>
  <button 
    @click="handleLogout" 
    class="px-4 py-2 rounded-lg font-semibold bg-white border-2 border-gray-300 text-gray-700 hover:border-gray-400 hover:bg-gray-50 transition-all duration-300 transform hover:scale-105 shadow-md hover:shadow-lg"
  >
    <span class="flex items-center gap-2">
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
      </svg>
      ログアウト
    </span>
  </button>
</template>

<script setup lang="ts">
const { logout } = useAuth()

const handleLogout = () => {
  logout()
  navigateTo('/')
}
</script>
