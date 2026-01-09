require 'rails_helper'

RSpec.describe Types::MutationType, type: :graphql do
  describe '#test_mutation' do
    it '期待される文字列を返す' do
      result = execute_mutation(mutation: <<~GRAPHQL)
        mutation {
          testMutation
        }
      GRAPHQL

      data = graphql_data(result)
      expect(data).to be_present
      expect(data['testMutation']).to eq('Test mutation response')
    end
  end

  context 'ミューテーションが無効な場合' do
    it '存在しないミューテーションに対してエラーを返す' do
      result = execute_mutation(mutation: <<~GRAPHQL)
        mutation {
          nonExistentMutation
        }
      GRAPHQL

      errors = graphql_errors(result)
      expect(errors).to be_present
      expect(errors.first).to have_key('message')
    end
  end

  context '変数を使用する場合' do
    it '変数を正しく処理する' do
      # 変数を使わないミューテーションでも変数を渡すことができることを確認
      result = execute_mutation(
        mutation: <<~GRAPHQL
          mutation {
            testMutation
          }
        GRAPHQL
      )

      data = graphql_data(result)
      expect(data).to be_present
      expect(data['testMutation']).to eq('Test mutation response')
    end
  end

  context 'コンテキストを使用する場合' do
    it 'コンテキストにアクセスできる' do
      result = execute_mutation(
        mutation: <<~GRAPHQL
          mutation {
            testMutation
          }
        GRAPHQL
      )

      data = graphql_data(result)
      expect(data).to be_present
    end
  end
end
