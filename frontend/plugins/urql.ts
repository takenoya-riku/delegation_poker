import { createClient, provideClient } from '@urql/vue'
import { cacheExchange, fetchExchange } from '@urql/core'
import { ref } from 'vue'
import type { Client } from '@urql/vue'

export default defineNuxtPlugin((nuxt) => {
  const { vueApp } = nuxt
  const config = useRuntimeConfig()
  
  const client = createClient({
    url: `${config.public.apiBaseUrl}/graphql`,
    exchanges: [cacheExchange, fetchExchange],
    requestPolicy: 'cache-and-network',
    fetchOptions: {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
      },
    },
  })

  // @urql/vueのuseQuery/useMutation用にprovideClientを呼び出す
  // これにより、useQueryやuseMutationが内部的にinjectでクライアントを取得できる
  provideClient(client)

  // Vueアプリケーションのコンテキストでクライアントを提供（参考コードに合わせる）
  // refでラップして提供する
  vueApp.provide('$urql', ref(client))
  
  // Nuxtのprovideも設定
  nuxt.provide('urql', client)
})

declare module '#app' {
  interface NuxtApp {
    $urql: Client
  }
}
