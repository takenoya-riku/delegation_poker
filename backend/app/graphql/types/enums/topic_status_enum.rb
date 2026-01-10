module Types
  module Enums
    class TopicStatusEnum < Types::Base::BaseEnum
      description "トピックのステータス"

      value "DRAFT", "対象出しフェーズ", value: "draft"
      value "ORGANIZING", "整理フェーズ", value: "organizing"
      value "CURRENT_VOTING", "現状確認投票中", value: "current_voting"
      value "CURRENT_REVEALED", "現状確認結果公開済み", value: "current_revealed"
      value "DESIRED_VOTING", "ありたい姿投票中", value: "desired_voting"
      value "DESIRED_REVEALED", "ありたい姿結果公開済み", value: "desired_revealed"
      value "COMPLETED", "完了", value: "completed"
    end
  end
end
