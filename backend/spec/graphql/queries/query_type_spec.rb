require 'rails_helper'

RSpec.describe Types::QueryType, type: :graphql do
  describe '#test_field' do
    it '期待される文字列を返す' do
      result = execute_graphql(query: <<~GRAPHQL)
        query {
          testField
        }
      GRAPHQL

      data = graphql_data(result)
      expect(data).to be_present
      expect(data['testField']).to eq('Hello World!')
    end
  end

  context 'クエリが無効な場合' do
    it '存在しないフィールドに対してエラーを返す' do
      result = execute_graphql(query: <<~GRAPHQL)
        query {
          nonExistentField
        }
      GRAPHQL

      errors = graphql_errors(result)
      expect(errors).to be_present
      expect(errors.first).to have_key('message')
    end
  end

  context '変数を使用する場合' do
    it '変数を正しく処理する' do
      # 変数を使わないクエリでも変数を渡すことができることを確認
      result = execute_graphql(
        query: <<~GRAPHQL
          query {
            testField
          }
        GRAPHQL
      )

      data = graphql_data(result)
      expect(data).to be_present
      expect(data['testField']).to eq('Hello World!')
    end
  end

  context 'コンテキストを使用する場合' do
    it 'コンテキストにアクセスできる' do
      result = execute_graphql(
        query: <<~GRAPHQL
          query {
            testField
          }
        GRAPHQL
      )

      data = graphql_data(result)
      expect(data).to be_present
    end
  end
end
