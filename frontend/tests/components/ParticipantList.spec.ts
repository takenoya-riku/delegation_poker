import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import ParticipantList from '~/components/ui/ParticipantList.vue'

describe('ParticipantList', () => {
  it('参加者数と現在参加者を表示する', () => {
    const wrapper = mount(ParticipantList, {
      props: {
        participants: [
          { id: 'p1', name: '山田太郎' },
          { id: 'p2', name: '佐藤花子' },
        ],
        currentParticipantId: 'p1',
        roomMasterId: 'p2',
        isRoomMaster: true,
      },
    })

    expect(wrapper.text()).toContain('2人')
    expect(wrapper.text()).toContain('山田太郎')
    expect(wrapper.text()).toContain('佐藤花子')
    expect(wrapper.text()).toContain('あなた')
    expect(wrapper.text()).toContain('ルームマスター')
  })

  it('ルームマスターは他の参加者を削除できる', async () => {
    const wrapper = mount(ParticipantList, {
      props: {
        participants: [
          { id: 'p1', name: '山田太郎' },
          { id: 'p2', name: '佐藤花子' },
        ],
        currentParticipantId: 'p1',
        roomMasterId: 'p1',
        isRoomMaster: true,
      },
    })

    const removeButton = wrapper.findAll('button').find(button => button.text() === '✕')
    if (!removeButton) throw new Error('削除ボタンが見つかりません')
    await removeButton.trigger('click')

    expect(wrapper.emitted('remove')?.[0]).toEqual(['p2'])
  })
})
