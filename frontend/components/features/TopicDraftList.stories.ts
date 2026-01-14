import type { Meta, StoryObj } from '@storybook/vue3'
import TopicDraftList from './TopicDraftList.vue'

const meta: Meta<typeof TopicDraftList> = {
  title: 'Features/TopicDraftList',
  component: TopicDraftList,
}

export default meta

type Story = StoryObj<typeof TopicDraftList>

export const Empty: Story = {
  args: {
    topics: [],
    participants: [
      { id: 'p1', name: '山田太郎' },
      { id: 'p2', name: '佐藤花子' },
    ],
    roomId: 'room-1',
    isRoomMaster: false,
    currentParticipantId: 'p1',
  },
}

export const WithTopics: Story = {
  args: {
    topics: [
      {
        id: 't1',
        title: '相談したいテーマ',
        description: '進め方を決めたい',
        status: 'DRAFT',
        participantId: 'p1',
      },
      {
        id: 't2',
        title: 'スケジュール調整',
        description: null,
        status: 'DRAFT',
        participantId: 'p2',
      },
    ],
    participants: [
      { id: 'p1', name: '山田太郎' },
      { id: 'p2', name: '佐藤花子' },
    ],
    roomId: 'room-1',
    isRoomMaster: true,
    currentParticipantId: 'p1',
  },
}
