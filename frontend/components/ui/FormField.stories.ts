import { ref } from 'vue'
import type { Meta, StoryObj } from '@storybook/vue3'
import FormField from './FormField.vue'

const meta: Meta<typeof FormField> = {
  title: 'UI/FormField',
  component: FormField,
}

export default meta

type Story = StoryObj<typeof FormField>

export const Default: Story = {
  render: () => ({
    components: { FormField },
    setup: () => {
      const value = ref('')
      return { value }
    },
    template: `
      <FormField
        v-model="value"
        label="入力欄"
        placeholder="入力してください"
        input-class="focus:input-primary focus:ring-2 focus:ring-blue-500 transition-all duration-300"
        required
      />
    `,
  }),
}
