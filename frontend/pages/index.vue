<template>
  <div class="min-h-screen relative overflow-hidden">
    <!-- グラデーション背景 -->
    <div class="absolute inset-0 bg-gradient-to-br from-purple-400 via-pink-400 to-blue-400 opacity-20"></div>
    <div class="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPjxnIGZpbGw9IiNmZmYiIGZpbGwtb3BhY2l0eT0iMC4wNSI+PGNpcmNsZSBjeD0iMzAiIGN5PSIzMCIgcj0iMiIvPjwvZz48L2c+PC9zdmc+')] opacity-30"></div>
    
    <div class="container mx-auto px-4 py-8 relative z-10">
      <!-- ヘッダー -->
      <div class="flex justify-between items-center mb-12 animate-fade-in">
        <h1 class="text-5xl font-bold text-gradient">Delegation Poker</h1>
        <div v-if="isAuthenticated" class="animate-slide-in">
          <LogoutButton />
        </div>
        <div v-else class="animate-slide-in">
          <LoginButton />
        </div>
      </div>

      <!-- ヒーローセクション -->
      <div class="text-center mb-12 animate-fade-in">
        <h2 class="text-3xl font-bold text-gray-800 mb-4">
          チームの意思決定を可視化しよう
        </h2>
        <p class="text-lg text-gray-600 max-w-2xl mx-auto">
          権限委譲レベルを投票で共有し、現状とありたい姿を比較して、より良い意思決定を実現します
        </p>
      </div>

      <!-- メインコンテンツ -->
      <div class="max-w-2xl mx-auto space-y-8">
        <div class="animate-fade-in" style="animation-delay: 0.1s">
          <RoomCreateForm />
        </div>
        
        <div class="divider-modern animate-fade-in" style="animation-delay: 0.2s">
          <span class="bg-white px-4 text-gray-500 font-medium">または</span>
        </div>
        
        <div class="animate-fade-in" style="animation-delay: 0.3s">
          <RoomJoinForm />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { isAuthenticated } = useAuth()

useHead({
  title: 'Delegation Poker'
})
</script>

<style scoped>
.divider-modern {
  text-align: center;
  margin: 2rem 0;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.divider-modern::before,
.divider-modern::after {
  content: '';
  position: absolute;
  top: 50%;
  width: 45%;
  height: 2px;
  background: linear-gradient(to right, transparent, rgba(102, 126, 234, 0.3), transparent);
}

.divider-modern::before {
  left: 0;
}

.divider-modern::after {
  right: 0;
}
</style>

