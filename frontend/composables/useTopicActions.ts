import { useMutation } from '@urql/vue'
import gql from 'graphql-tag'
import {
  AddTopicDocument,
  DeleteTopicDocument,
  OrganizeTopicDocument,
  StartOrganizingDocument,
  UpdateTopicDocument,
} from '~/graphql/generated/types'

export const useTopicActions = () => {
  const addTopicMutation = useMutation(AddTopicDocument)
  const updateTopicMutation = useMutation(UpdateTopicDocument)
  const deleteTopicMutation = useMutation(DeleteTopicDocument)
  const startOrganizingMutation = useMutation(StartOrganizingDocument)
  const organizeTopicMutation = useMutation(OrganizeTopicDocument)
  const revertToDraftMutation = useMutation(gql`
    mutation RevertToDraft($topicId: ID!) {
      revertToDraft(topicId: $topicId) {
        topic {
          id
          status
        }
        errors
      }
    }
  `)

  const addTopic = (variables: { roomId: string; participantId: string; title: string; description?: string | null }) => {
    return addTopicMutation.executeMutation(variables)
  }

  const updateTopic = (variables: { topicId: string; participantId: string; title?: string | null; description?: string | null }) => {
    return updateTopicMutation.executeMutation(variables)
  }

  const deleteTopic = (variables: { topicId: string; participantId: string }) => {
    return deleteTopicMutation.executeMutation(variables)
  }

  const startOrganizing = (variables: { topicId: string }) => {
    return startOrganizingMutation.executeMutation(variables)
  }

  const organizeTopic = (variables: { topicId: string }) => {
    return organizeTopicMutation.executeMutation(variables)
  }

  const revertToDraft = (variables: { topicId: string }) => {
    return revertToDraftMutation.executeMutation(variables)
  }

  return {
    addTopic,
    updateTopic,
    deleteTopic,
    startOrganizing,
    organizeTopic,
    revertToDraft,
  }
}
