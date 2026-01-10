class AddVoteTypeToVotes < ActiveRecord::Migration[8.0]
  def change
    add_column :votes, :vote_type, :string, null: false, default: 'current_state'
    add_index :votes, [:topic_id, :participant_id, :vote_type], unique: true, name: 'index_votes_on_topic_participant_vote_type'
    
    # 既存のユニーク制約を削除（新しい複合ユニーク制約に置き換えるため）
    remove_index :votes, name: 'index_votes_on_topic_id_and_participant_id'
  end
end
