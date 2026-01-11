module Mutations
  class Vote < BaseMutation
    description "投票する"

    argument :topic_id, ID, required: true, description: "トピックID"
    argument :participant_id, ID, required: true, description: "参加者ID"
    argument :level, Integer, required: true, description: "権限レベル（1-7）"
    argument :vote_type, Types::Enums::VoteTypeEnum, required: true, description: "投票の種類（現状確認またはありたい姿）"

    field :vote, Types::Objects::VoteType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:, participant_id:, level:, vote_type:)
      # TODO: 認証認可の実装
      # authorize! :vote, Topic.find_by(id: topic_id)

      result = VoteService.call(
        topic_id: topic_id,
        participant_id: participant_id,
        level: level,
        vote_type: vote_type,
      )

      {
        vote: result[:vote],
        errors: result[:errors],
      }
    end
  end
end
