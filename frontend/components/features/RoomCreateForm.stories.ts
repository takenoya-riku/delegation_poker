import type { Meta, StoryObj } from '@storybook/vue3'
import RoomCreateForm from './RoomCreateForm.vue'

const meta: Meta<typeof RoomCreateForm> = {
  title: 'Features/RoomCreateForm',
  component: RoomCreateForm,
}

export default meta

type Story = StoryObj<typeof RoomCreateForm>

export const Default: Story = {}
