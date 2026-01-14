import type { Meta, StoryObj } from '@storybook/vue3'
import RoomJoinForm from './RoomJoinForm.vue'

const meta: Meta<typeof RoomJoinForm> = {
  title: 'Features/RoomJoinForm',
  component: RoomJoinForm,
}

export default meta

type Story = StoryObj<typeof RoomJoinForm>

export const Default: Story = {}
