import type { Meta, StoryObj } from '@storybook/vue3'
import TopicOrganizeView from './TopicOrganizeView.vue'

const meta: Meta<typeof TopicOrganizeView> = {
  title: 'Features/TopicOrganizeView',
  component: TopicOrganizeView,
}

export default meta

type Story = StoryObj<typeof TopicOrganizeView>

export const Empty: Story = {
  args: {
    topics: [],
    participants: [
      { id: 'p1', name: '山田太郎' },
      { id: 'p2', name: '佐藤花子' },
    ],
    isRoomMaster: false,
    currentParticipantId: 'p1',
  },
}

export const WithTopics: Story = {
  args: {
    topics: [
      {
        id: 't1',
        title: '対象A',
        description: '重複を整理したい',
        status: 'ORGANIZING',
        participantId: 'p1',
      },
      {
        id: 't2',
        title: '対象B',
        description: null,
        status: 'organizing',
        participantId: 'p2',
      },
    ],
    participants: [
      { id: 'p1', name: '山田太郎' },
      { id: 'p2', name: '佐藤花子' },
    ],
    isRoomMaster: true,
    currentParticipantId: 'p1',
  },
}
