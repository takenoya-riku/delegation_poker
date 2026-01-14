import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import FormField from '~/components/ui/FormField.vue'

describe('FormField', () => {
  it('入力に応じて値を更新する', async () => {
    const wrapper = mount(FormField, {
      props: {
        label: '入力欄',
        modelValue: '',
      },
    })

    await wrapper.find('input').setValue('テスト入力')

    expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['テスト入力'])
  })
})
