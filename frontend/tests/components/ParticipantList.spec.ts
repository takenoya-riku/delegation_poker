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
      },
    })

    expect(wrapper.text()).toContain('2人')
    expect(wrapper.text()).toContain('山田太郎')
    expect(wrapper.text()).toContain('佐藤花子')
    expect(wrapper.text()).toContain('あなた')
  })
})
