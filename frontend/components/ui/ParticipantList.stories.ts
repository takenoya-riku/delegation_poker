import type { Meta, StoryObj } from '@storybook/vue3'
import ParticipantList from './ParticipantList.vue'

const meta: Meta<typeof ParticipantList> = {
  title: 'UI/ParticipantList',
  component: ParticipantList,
}

export default meta

type Story = StoryObj<typeof ParticipantList>

export const Default: Story = {
  args: {
    participants: [
      { id: 'p1', name: '山田太郎' },
      { id: 'p2', name: '佐藤花子' },
      { id: 'p3', name: '鈴木一郎' },
    ],
    currentParticipantId: 'p2',
    roomMasterId: 'p1',
    isRoomMaster: true,
  },
}
