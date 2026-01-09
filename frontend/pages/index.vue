<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-8 text-center">Delegation Poker</h1>

    <div class="max-w-md mx-auto space-y-6">
      <RoomCreateForm />
      <div class="divider">または</div>
      <RoomJoinForm />
    </div>
  </div>
</template>

<script setup lang="ts">
useHead({
  title: 'Delegation Poker'
})
</script>

<style scoped>
.divider {
  text-align: center;
  margin: 2rem 0;
  position: relative;
}

.divider::before,
.divider::after {
  content: '';
  position: absolute;
  top: 50%;
  width: 45%;
  height: 1px;
  background: #e5e7eb;
}

.divider::before {
  left: 0;
}

.divider::after {
  right: 0;
}
</style>
