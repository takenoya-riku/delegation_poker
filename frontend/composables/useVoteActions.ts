import { useMutation } from '@urql/vue'
import gql from 'graphql-tag'
import {
  RevealCurrentStateDocument,
  RevealDesiredStateDocument,
  StartDesiredStateVotingDocument,
  VoteDocument,
} from '~/graphql/generated/types'

export const useVoteActions = () => {
  const voteMutation = useMutation(VoteDocument)
  const revealCurrentMutation = useMutation(RevealCurrentStateDocument)
  const startDesiredMutation = useMutation(StartDesiredStateVotingDocument)
  const revealDesiredMutation = useMutation(RevealDesiredStateDocument)
  const revertToOrganizingMutation = useMutation(gql`
    mutation RevertToOrganizing($topicId: ID!) {
      revertToOrganizing(topicId: $topicId) {
        topic {
          id
          status
        }
        errors
      }
    }
  `)

  const vote = (variables: { topicId: string; participantId: string; level: number; voteType: string }) => {
    return voteMutation.executeMutation(variables)
  }

  const revealCurrentState = (variables: { topicId: string }) => {
    return revealCurrentMutation.executeMutation(variables)
  }

  const startDesiredStateVoting = (variables: { topicId: string }) => {
    return startDesiredMutation.executeMutation(variables)
  }

  const revealDesiredState = (variables: { topicId: string }) => {
    return revealDesiredMutation.executeMutation(variables)
  }

  const revertToOrganizing = (variables: { topicId: string }) => {
    return revertToOrganizingMutation.executeMutation(variables)
  }

  return {
    vote,
    revealCurrentState,
    startDesiredStateVoting,
    revealDesiredState,
    revertToOrganizing,
  }
}
