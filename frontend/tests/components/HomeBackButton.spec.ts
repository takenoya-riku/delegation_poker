import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import HomeBackButton from '~/components/ui/HomeBackButton.vue'

describe('HomeBackButton', () => {
  it('デフォルトの表示を行う', () => {
    const wrapper = mount(HomeBackButton, {
      global: {
        stubs: {
          NuxtLink: {
            props: ['to'],
            template: '<a :href="to"><slot /></a>',
          },
        },
      },
    })

    expect(wrapper.text()).toContain('ホームへ戻る')
    expect(wrapper.find('a[href="/"]').exists()).toBe(true)
  })

  it('グラデーションボタンを表示する', () => {
    const wrapper = mount(HomeBackButton, {
      props: { variant: 'gradient' },
      global: {
        stubs: {
          NuxtLink: {
            props: ['to'],
            template: '<a :href="to"><slot /></a>',
          },
        },
      },
    })

    expect(wrapper.text()).toContain('ホームへ戻る')
  })
})
