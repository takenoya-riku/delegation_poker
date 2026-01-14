export const useMutation = () => ({
  executeMutation: async () => ({ data: {} }),
})

export const useQuery = () => ({
  data: { value: null },
  fetching: { value: false },
  error: { value: null },
  executeQuery: () => undefined,
})
