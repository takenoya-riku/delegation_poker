import type { Meta, StoryObj } from '@storybook/vue3'
import HomeBackButton from './HomeBackButton.vue'

const meta: Meta<typeof HomeBackButton> = {
  title: 'UI/HomeBackButton',
  component: HomeBackButton,
}

export default meta

type Story = StoryObj<typeof HomeBackButton>

export const Outline: Story = {}

export const Gradient: Story = {
  args: {
    variant: 'gradient',
  },
}
