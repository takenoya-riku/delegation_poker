import type { Meta, StoryObj } from '@storybook/vue3'
import VotingBoard from './VotingBoard.vue'

const meta: Meta<typeof VotingBoard> = {
  title: 'Features/VotingBoard',
  component: VotingBoard,
}

export default meta

type Story = StoryObj<typeof VotingBoard>

export const Default: Story = {
  args: {
    topics: [
      {
        id: 't1',
        title: '意思決定の範囲',
        description: '現状と理想の差を確認する',
        status: 'current_voting',
        participantId: 'p1',
        votes: [
          {
            id: 'v1',
            level: 3,
            voteType: 'current_state',
            participant: { id: 'p1', name: '山田太郎' },
          },
        ],
      },
      {
        id: 't2',
        title: 'レビューの頻度',
        description: null,
        status: 'current_revealed',
        participantId: 'p2',
        votes: [
          {
            id: 'v2',
            level: 4,
            voteType: 'current_state',
            participant: { id: 'p2', name: '佐藤花子' },
          },
          {
            id: 'v3',
            level: 5,
            voteType: 'current_state',
            participant: { id: 'p1', name: '山田太郎' },
          },
        ],
      },
    ],
    participants: [
      { id: 'p1', name: '山田太郎' },
      { id: 'p2', name: '佐藤花子' },
    ],
    participantId: 'p1',
    totalParticipants: 2,
    isRoomMaster: true,
  },
}
