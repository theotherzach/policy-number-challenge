# frozen_string_literal: true

require_relative '../lib/policy_ocr'

describe PolicyOcr do
  it 'loads' do
    expect(PolicyOcr).to be_a Module
  end

  it 'loads the sample.txt' do
    expect(fixture('sample').lines.count).to eq(44)
  end
end
