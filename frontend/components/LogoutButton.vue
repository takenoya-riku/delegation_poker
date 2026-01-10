<template>
  <button @click="handleLogout" class="btn btn-outline">
    ログアウト
  </button>
</template>

<script setup lang="ts">
const { logout } = useAuth()

const handleLogout = () => {
  logout()
  navigateTo('/')
}
</script>
