<template>
  <button @click="handleLogin" class="btn btn-primary" :disabled="loading">
    <span v-if="loading" class="loading loading-spinner loading-sm"></span>
    <span v-else>Googleでログイン</span>
  </button>
</template>

<script setup lang="ts">
const { login } = useAuth()
const loading = ref(false)

const handleLogin = () => {
  loading.value = true
  login()
}
</script>
