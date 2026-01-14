import { flushPromises, mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import RoomJoinForm from '~/components/features/RoomJoinForm.vue'

const joinRoomMock = vi.fn()

vi.mock('~/composables/useRoomActions', () => ({
  useRoomActions: () => ({
    joinRoom: joinRoomMock,
  }),
}))

describe('RoomJoinForm', () => {
  beforeEach(() => {
    joinRoomMock.mockReset()
    vi.stubGlobal('navigateTo', vi.fn())
    localStorage.clear()
    sessionStorage.clear()
  })

  it('参加成功時に保存と画面遷移を行う', async () => {
    joinRoomMock.mockResolvedValue({
      data: {
        joinRoom: {
          participant: { id: 'participant-1' },
          room: { code: 'ab12cd' },
          errors: [],
        },
      },
    })

    const wrapper = mount(RoomJoinForm)
    await wrapper.find('input[placeholder="6桁のコード"]').setValue(' ab12cd ')
    await wrapper.find('input[placeholder="例: 山田太郎"]').setValue(' 山田太郎 ')
    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(joinRoomMock).toHaveBeenCalledWith({
      code: 'AB12CD',
      name: '山田太郎',
    })
    expect(localStorage.getItem('participant_AB12CD')).toBe('participant-1')
    expect(sessionStorage.getItem('participant_session_AB12CD')).toBe('participant-1')
    expect(navigateTo).toHaveBeenCalledWith('/room/ab12cd')
  })

  it('参加失敗時にエラーメッセージを表示する', async () => {
    joinRoomMock.mockResolvedValue({
      data: {
        joinRoom: {
          participant: null,
          room: { code: 'ab12cd' },
          errors: ['参加できませんでした'],
        },
      },
    })

    const wrapper = mount(RoomJoinForm)
    await wrapper.find('input[placeholder="6桁のコード"]').setValue('ab12cd')
    await wrapper.find('input[placeholder="例: 山田太郎"]').setValue('山田太郎')
    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(wrapper.text()).toContain('参加できませんでした')
    expect(navigateTo).not.toHaveBeenCalled()
  })
})
