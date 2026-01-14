import type { Meta, StoryObj } from '@storybook/vue3'
import FormCard from './FormCard.vue'

const meta: Meta<typeof FormCard> = {
  title: 'UI/FormCard',
  component: FormCard,
}

export default meta

type Story = StoryObj<typeof FormCard>

export const Default: Story = {
  args: {
    title: 'フォームカード',
    cardClass: 'border-blue-200',
    iconClass: 'bg-gradient-success',
  },
  render: (args) => ({
    components: { FormCard },
    setup: () => ({ args }),
    template: `
      <FormCard v-bind="args">
        <template #icon>🧩</template>
        <div class="text-gray-600">ここにフォームを配置します。</div>
      </FormCard>
    `,
  }),
}
