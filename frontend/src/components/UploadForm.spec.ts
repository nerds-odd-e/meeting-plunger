import { describe, it, expect, vi } from 'vitest';
import { mount } from '@vue/test-utils';
import UploadForm from './UploadForm.vue';

describe('UploadForm', () => {
  it('renders upload form with file input and button', () => {
    const wrapper = mount(UploadForm);

    expect(wrapper.find('h2').text()).toBe('Upload Audio File');
    expect(wrapper.find('input[type="file"]').exists()).toBe(true);
    expect(wrapper.find('button[type="submit"]').text()).toBe('Upload');
  });

  it('shows alert when submitting without file', async () => {
    const wrapper = mount(UploadForm);
    const alertSpy = vi.spyOn(window, 'alert').mockImplementation(() => {});

    await wrapper.find('form').trigger('submit');

    expect(alertSpy).toHaveBeenCalledWith('Please select a file');
    alertSpy.mockRestore();
  });

  it('emits transcript event on successful upload', async () => {
    const mockResponse = { transcript: 'Hello, how are you?' };
    global.fetch = vi.fn().mockResolvedValue({
      json: async () => mockResponse,
    });

    const wrapper = mount(UploadForm);

    // Create a mock file
    const file = new File(['audio content'], 'test.wav', {
      type: 'audio/wav',
    });

    // Set the file input value using Object.defineProperty
    const input = wrapper.find('input[type="file"]')
      .element as HTMLInputElement;
    Object.defineProperty(input, 'files', {
      value: [file],
      writable: false,
    });

    await wrapper.find('form').trigger('submit');

    // Wait for async operations
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(wrapper.emitted('transcript')).toBeTruthy();
    expect(wrapper.emitted('transcript')?.[0]).toEqual([
      mockResponse.transcript,
    ]);
  });
});
