import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import FormCard from '~/components/ui/FormCard.vue'

describe('FormCard', () => {
  it('タイトルとスロット内容を表示する', () => {
    const wrapper = mount(FormCard, {
      props: {
        title: 'フォームタイトル',
        cardClass: 'border-blue-200',
        iconClass: 'bg-gradient-success',
      },
      slots: {
        icon: '🧩',
        default: '<div>内容</div>',
      },
    })

    expect(wrapper.text()).toContain('フォームタイトル')
    expect(wrapper.text()).toContain('内容')
  })
})
