<template>
  <div :class="['card-modern card-gradient border-2 transition-all duration-300', cardClass]">
    <div class="card-body p-8">
      <div class="flex items-center gap-3 mb-6">
        <div :class="['w-12 h-12 rounded-full flex items-center justify-center text-white text-xl font-bold shadow-lg', iconClass]">
          <slot name="icon" />
        </div>
        <h2 class="card-title text-2xl text-gray-800">
          {{ title }}
        </h2>
      </div>
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  title: string
  cardClass?: string
  iconClass?: string
}>(), {
  cardClass: '',
  iconClass: '',
})
</script>
