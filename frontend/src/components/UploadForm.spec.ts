import { describe, it, expect, vi, beforeEach } from 'vitest';
import { mount } from '@vue/test-utils';
import UploadForm from './UploadForm.vue';
import * as generatedClient from '../generated/client';

// Spy on the module
vi.mock('../generated/client', async () => {
  const actual = await vi.importActual<typeof generatedClient>('../generated/client');
  return {
    ...actual,
    TranscriptionService: {
      postUpload: vi.fn(),
    },
  };
});

describe('UploadForm', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

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
    vi.mocked(generatedClient.TranscriptionService.postUpload).mockResolvedValue(mockResponse as any);

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

  it('emits error message on failed upload', async () => {
    const mockError = new generatedClient.ApiError(
      {},
      {
        body: { error: 'Method not allowed' },
        status: 405,
        statusText: 'Method Not Allowed',
        url: '/upload',
      },
      'Method Not Allowed',
    );

    vi.mocked(generatedClient.TranscriptionService.postUpload).mockRejectedValue(mockError);

    const wrapper = mount(UploadForm);

    // Create a mock file
    const file = new File(['audio content'], 'test.wav', {
      type: 'audio/wav',
    });

    // Set the file input value
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
      'Error: Method not allowed',
    ]);
  });
});
