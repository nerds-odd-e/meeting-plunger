import { describe, it, expect } from 'vitest';
import { mount } from '@vue/test-utils';
import TranscriptResult from './TranscriptResult.vue';

describe('TranscriptResult', () => {
  it('renders the transcript text', () => {
    const transcript = 'Hello, how are you?';
    const wrapper = mount(TranscriptResult, {
      props: {
        transcript,
      },
    });

    expect(wrapper.text()).toBe(transcript);
    expect(wrapper.find('#result').exists()).toBe(true);
  });

  it('updates when transcript prop changes', async () => {
    const wrapper = mount(TranscriptResult, {
      props: {
        transcript: 'Initial text',
      },
    });

    expect(wrapper.text()).toBe('Initial text');

    await wrapper.setProps({ transcript: 'Updated text' });

    expect(wrapper.text()).toBe('Updated text');
  });
});
