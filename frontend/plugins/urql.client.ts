import { createClient, provideClient } from '@urql/vue'

export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig()
  
  const client = createClient({
    url: `${config.public.apiBaseUrl}/graphql`,
    requestPolicy: 'cache-and-network',
  })

  nuxtApp.provide('$urql', client)
  provideClient(client)
})
