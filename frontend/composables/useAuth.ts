export const useAuth = () => {
  const TOKEN_KEY = 'auth_token'

  const config = useRuntimeConfig()
  const apiBaseUrl = config.public.apiBaseUrl

  const token = useState<string | null>(TOKEN_KEY, () => {
    if (process.client) {
      return localStorage.getItem(TOKEN_KEY)
    }
    return null
  })

  const isAuthenticated = computed(() => !!token.value)

  const login = () => {
    if (process.client) {
      window.location.href = `${apiBaseUrl}/auth/google`
    }
  }

  const logout = () => {
    if (process.client) {
      localStorage.removeItem(TOKEN_KEY)
      token.value = null
    }
  }

  const setToken = (newToken: string) => {
    if (process.client) {
      localStorage.setItem(TOKEN_KEY, newToken)
      token.value = newToken
    }
  }

  const getToken = (): string | null => {
    return token.value
  }

  return {
    token: readonly(token),
    isAuthenticated,
    login,
    logout,
    setToken,
    getToken
  }
}
