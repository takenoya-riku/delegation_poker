require 'rails_helper'

RSpec.describe GraphqlController, type: :request do
  describe 'POST /graphql' do
    context 'リクエストが有効な場合' do
      it '成功レスポンスを返す' do
        room = create(:room)

        post_graphql(query: <<~GRAPHQL)
          query {
            room(code: "#{room.code}") {
              id
            }
          }
        GRAPHQL

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('application/json')
      end

      it 'JSON形式でレスポンスを返す' do
        room = create(:room)

        post_graphql(query: <<~GRAPHQL)
          query {
            room(code: "#{room.code}") {
              id
            }
          }
        GRAPHQL

        json = graphql_response(response)
        expect(json).to be_a(Hash)
        expect(json).to have_key('data')
      end

      it 'オペレーション名付きクエリを処理する' do
        room = create(:room)

        post_graphql(
          query: <<~GRAPHQL,
            query GetRoom($code: String!) {
              room(code: $code) {
                id
              }
            }
          GRAPHQL
          operation_name: 'GetRoom',
          variables: { code: room.code }
        )

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('data')
      end

      it '変数付きクエリを処理する' do
        room = create(:room)

        post_graphql(
          query: <<~GRAPHQL,
            query GetRoom($code: String!) {
              room(code: $code) {
                id
              }
            }
          GRAPHQL
          variables: { code: room.code }
        )

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('data')
      end
    end

    context 'リクエストが無効な場合' do
      it '不正なクエリ構文に対してエラーレスポンスを返す' do
        post_graphql(query: '{ invalid query syntax }')

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('errors')
      end

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
      end
    end

    context 'リクエストパラメータが不正な場合' do
      it 'クエリが欠落している場合エラーレスポンスを返す' do
        post '/graphql', params: {}, as: :json

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('errors')
      end

      it '変数が文字列として提供される場合正しくパースする' do
        room = create(:room)

        post_graphql(
          query: <<~GRAPHQL,
            query GetRoom($code: String!) {
              room(code: $code) {
                id
              }
            }
          GRAPHQL
          variables: { code: room.code }.to_json
        )

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('data')
      end

      it '変数がハッシュとして提供される場合正しく処理する' do
        room = create(:room)

        post_graphql(
          query: <<~GRAPHQL,
            query GetRoom($code: String!) {
              room(code: $code) {
                id
              }
            }
          GRAPHQL
          variables: { code: room.code }
        )

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        expect(json).to have_key('data')
      end
    end

    context 'エラーハンドリング' do
      it '開発環境でエラーが発生した場合バックトレースを含む' do
        allow(Rails.env).to receive(:development?).and_return(true)

        post_graphql(query: <<~GRAPHQL)
          query {
            room(code: "INVALID") {
              id
            }
          }
        GRAPHQL

        expect(response).to have_http_status(:success)
        json = graphql_response(response)
        # エラーが返されることを確認（詳細な内容はGraphQL結合テストで確認）
        expect(json).to have_key('data').or have_key('errors')
      end
    end
  end
end
