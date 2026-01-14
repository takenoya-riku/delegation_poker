import { flushPromises, mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import RoomCreateForm from '~/components/features/RoomCreateForm.vue'

const createRoomMock = vi.fn()
const joinRoomMock = vi.fn()

vi.mock('~/composables/useRoomActions', () => ({
  useRoomActions: () => ({
    createRoom: createRoomMock,
    joinRoom: joinRoomMock,
  }),
}))

describe('RoomCreateForm', () => {
  beforeEach(() => {
    createRoomMock.mockReset()
    joinRoomMock.mockReset()
    vi.stubGlobal('navigateTo', vi.fn())
    localStorage.clear()
    sessionStorage.clear()
  })

  it('作成と参加が成功した場合は参加者情報を保存して遷移する', async () => {
    createRoomMock.mockResolvedValue({
      data: {
        createRoom: {
          room: { code: 'ab12cd' },
          errors: [],
        },
      },
    })
    joinRoomMock.mockResolvedValue({
      data: {
        joinRoom: {
          participant: { id: 'participant-1' },
          errors: [],
        },
      },
    })

    const wrapper = mount(RoomCreateForm)
    await wrapper.find('input[placeholder="例: プロジェクトAの意思決定"]').setValue(' テストルーム ')
    await wrapper.find('input[placeholder="例: 山田太郎"]').setValue(' 山田太郎 ')
    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(createRoomMock).toHaveBeenCalledWith({ name: 'テストルーム' })
    expect(joinRoomMock).toHaveBeenCalledWith({ code: 'ab12cd', name: '山田太郎' })
    expect(localStorage.getItem('participant_AB12CD')).toBe('participant-1')
    expect(sessionStorage.getItem('participant_session_AB12CD')).toBe('participant-1')
    expect(localStorage.getItem('room_master_AB12CD')).toBe('participant-1')
    expect(navigateTo).toHaveBeenCalledWith('/room/ab12cd')
  })

  it('参加に失敗した場合はエラーメッセージを表示する', async () => {
    createRoomMock.mockResolvedValue({
      data: {
        createRoom: {
          room: { code: 'ab12cd' },
          errors: [],
        },
      },
    })
    joinRoomMock.mockResolvedValue({
      data: {
        joinRoom: {
          participant: null,
          errors: ['参加に失敗しました'],
        },
      },
    })

    const wrapper = mount(RoomCreateForm)
    await wrapper.find('input[placeholder="例: プロジェクトAの意思決定"]').setValue('テストルーム')
    await wrapper.find('input[placeholder="例: 山田太郎"]').setValue('山田太郎')
    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(wrapper.text()).toContain('参加に失敗しました')
    expect(navigateTo).not.toHaveBeenCalled()
  })
})
