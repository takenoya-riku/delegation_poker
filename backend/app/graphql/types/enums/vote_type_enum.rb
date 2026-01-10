module Types
  module Enums
    class VoteTypeEnum < Types::Base::BaseEnum
      description "投票の種類"

      value "CURRENT_STATE", "現状確認", value: "current_state"
      value "DESIRED_STATE", "ありたい姿", value: "desired_state"
    end
  end
end
