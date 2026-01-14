import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import IndexPage from '~/pages/index.vue'

describe('トップページ', () => {
  it('主要な導線を表示する', () => {
    const wrapper = mount(IndexPage, {
      global: {
        stubs: {
          NuxtLink: {
            props: ['to'],
            template: '<a :href="to"><slot /></a>',
          },
          RoomCreateForm: {
            template: '<div data-test="room-create-form" />',
          },
          RoomJoinForm: {
            template: '<div data-test="room-join-form" />',
          },
        },
      },
    })

    expect(wrapper.text()).toContain('Delegation Poker')
    expect(wrapper.find('a[href="/rooms"]').exists()).toBe(true)
    expect(wrapper.find('[data-test="room-create-form"]').exists()).toBe(true)
    expect(wrapper.find('[data-test="room-join-form"]').exists()).toBe(true)
  })
})
