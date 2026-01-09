module Types
  module Enums
    class DelegationLevelEnum < Types::Base::BaseEnum
      description "権限委譲レベル（1-7）"

      value "LEVEL_1", "レベル1: Tell（指示）", value: 1
      value "LEVEL_2", "レベル2: Sell（説得）", value: 2
      value "LEVEL_3", "レベル3: Consult（相談）", value: 3
      value "LEVEL_4", "レベル4: Agree（合意）", value: 4
      value "LEVEL_5", "レベル5: Advise（助言）", value: 5
      value "LEVEL_6", "レベル6: Inquire（確認）", value: 6
      value "LEVEL_7", "レベル7: Delegate（委譲）", value: 7
    end
  end
end
