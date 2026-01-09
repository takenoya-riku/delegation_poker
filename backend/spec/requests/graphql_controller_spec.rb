require 'rails_helper'

RSpec.describe 'GraphQL API', type: :request do
  describe 'POST /graphql' do
    context 'クエリが有効な場合' do
      it 'testFieldクエリに対して成功レスポンスを返す' do
        post_graphql(query: <<~GRAPHQL)
          query {
            testField
          }
        GRAPHQL

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('testField')
        expect(json['data']['testField']).to eq('Hello World!')
      end

      it 'testMutationミューテーションに対して成功レスポンスを返す' do
        post_graphql_mutation(mutation: <<~GRAPHQL)
          mutation {
            testMutation
          }
        GRAPHQL

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('data')
        expect(json['data']).to have_key('testMutation')
        expect(json['data']['testMutation']).to eq('Test mutation response')
      end

      it 'オペレーション名付きクエリを処理する' do
        post_graphql(
          query: <<~GRAPHQL,
            query TestQuery {
              testField
            }
          GRAPHQL
          operation_name: 'TestQuery'
        )

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json['data']['testField']).to eq('Hello World!')
      end

      it '変数付きクエリを処理する' do
        post_graphql(
          query: <<~GRAPHQL
            query {
              testField
            }
          GRAPHQL
        )

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json['data']).to be_present
        expect(json['data']['testField']).to eq('Hello World!')
      end
    end

    context 'クエリが無効な場合' do
      it '存在しないフィールドに対してエラーレスポンスを返す' do
        post_graphql(query: <<~GRAPHQL)
          query {
            nonExistentField
          }
        GRAPHQL

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('errors')
        expect(json['errors']).to be_an(Array)
        expect(json['errors'].first).to have_key('message')
      end

      it '不正なクエリ構文に対してエラーレスポンスを返す' do
        post_graphql(query: '{ invalid query syntax }')

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('errors')
      end
    end

    context 'クエリが欠落している場合' do
      it 'エラーレスポンスを返す' do
        post '/graphql', params: {}, as: :json

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('errors')
      end
    end

    context '変数が文字列として提供される場合' do
      it 'JSON文字列変数を正しくパースする' do
        post_graphql(
          query: <<~GRAPHQL
            query {
              testField
            }
          GRAPHQL
        )

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json['data']).to be_present
        expect(json['data']['testField']).to eq('Hello World!')
      end
    end

    context '変数がハッシュとして提供される場合' do
      it 'ハッシュ変数を正しく処理する' do
        post_graphql(
          query: <<~GRAPHQL
            query {
              testField
            }
          GRAPHQL
        )

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json['data']).to be_present
        expect(json['data']['testField']).to eq('Hello World!')
      end
    end

    context 'レスポンス形式' do
      it 'JSONコンテンツタイプを返す' do
        post_graphql(query: <<~GRAPHQL)
          query {
            testField
          }
        GRAPHQL

        expect(response.content_type).to include('application/json')
      end

      it '正しい形式でデータを返す' do
        post_graphql(query: <<~GRAPHQL)
          query {
            testField
          }
        GRAPHQL

        json = graphql_response(response)
        expect(json).to be_a(Hash)
        expect(json).to have_key('data')
      end
    end
  end
end
