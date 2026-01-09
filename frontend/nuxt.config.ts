// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: true },
  
  modules: ['@nuxtjs/tailwindcss'],
  
  build: {
    transpile: ['@urql/vue', '@urql/core']
  },
  
  runtimeConfig: {
    public: {
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL || 'http://localhost:3001',
      graphqlEndpoint: process.env.NUXT_PUBLIC_GRAPHQL_ENDPOINT || 'http://localhost:3001/graphql'
    }
  }
})
