<template>
  <div class="form-control">
    <label class="label">
      <span class="label-text font-semibold text-gray-700">{{ label }}</span>
    </label>
    <input
      :value="modelValue"
      :type="type"
      :required="required"
      :class="['input input-bordered w-full px-[5px]', inputClass]"
      v-bind="$attrs"
      @input="handleInput"
    >
  </div>
</template>

<script setup lang="ts">
defineOptions({ inheritAttrs: false })

withDefaults(defineProps<{
  label: string
  modelValue: string
  type?: string
  inputClass?: string
  required?: boolean
}>(), {
  type: 'text',
  inputClass: '',
  required: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const handleInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  emit('update:modelValue', target.value)
}
</script>
