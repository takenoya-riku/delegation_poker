import { nextTick } from 'vue'
import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import RoomsPage from '~/pages/rooms.vue'

describe('保存したルーム一覧ページ', () => {
  it('保存済みがない場合は空状態を表示する', async () => {
    localStorage.clear()

    const wrapper = mount(RoomsPage, {
      global: {
        stubs: {
          NuxtLink: {
            props: ['to'],
            template: '<a :href="to"><slot /></a>',
          },
        },
      },
    })

    await nextTick()

    expect(wrapper.text()).toContain('まだ保存されたルームがありません')
  })

  it('保存済みがある場合は一覧を表示する', async () => {
    localStorage.setItem(
      'saved_rooms',
      JSON.stringify([
        { code: 'AB12CD', name: 'サンプルルーム', updatedAt: new Date().toISOString() },
      ])
    )

    const wrapper = mount(RoomsPage, {
      global: {
        stubs: {
          NuxtLink: {
            props: ['to'],
            template: '<a :href="to"><slot /></a>',
          },
        },
      },
    })

    await nextTick()

    expect(wrapper.text()).toContain('サンプルルーム')
    expect(wrapper.text()).toContain('AB12CD')
    expect(wrapper.find('a[href="/room/AB12CD"]').exists()).toBe(true)
  })
})
