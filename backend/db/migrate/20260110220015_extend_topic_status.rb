class ExtendTopicStatus < ActiveRecord::Migration[8.0]
  def up
    # 既存のvotingとrevealedをcurrent_votingとcurrent_revealedに移行
    execute <<-SQL
      UPDATE topics SET status = 'current_voting' WHERE status = 'voting';
      UPDATE topics SET status = 'current_revealed' WHERE status = 'revealed';
    SQL
    
    # デフォルト値を変更
    change_column_default :topics, :status, 'draft'
  end

  def down
    # 戻す場合はcurrent_votingとcurrent_revealedをvotingとrevealedに戻す
    execute <<-SQL
      UPDATE topics SET status = 'voting' WHERE status IN ('current_voting', 'draft', 'organizing');
      UPDATE topics SET status = 'revealed' WHERE status IN ('current_revealed', 'desired_voting', 'desired_revealed', 'completed');
    SQL
    
    change_column_default :topics, :status, 'voting'
  end
end
