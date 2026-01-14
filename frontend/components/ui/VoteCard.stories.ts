import type { Meta, StoryObj } from '@storybook/vue3'
import VoteCard from './VoteCard.vue'

const meta: Meta<typeof VoteCard> = {
  title: 'UI/VoteCard',
  component: VoteCard,
}

export default meta

type Story = StoryObj<typeof VoteCard>

export const CurrentState: Story = {
  args: {
    topicId: 't1',
    participantId: 'p1',
    voteType: 'current_state',
    votes: [
      {
        id: 'v1',
        level: 3,
        voteType: 'current_state',
        participant: { id: 'p1' },
      },
    ],
  },
}

export const DesiredState: Story = {
  args: {
    topicId: 't1',
    participantId: 'p1',
    voteType: 'desired_state',
    votes: [],
  },
}
