# frozen_string_literal: true

RSpec.describe 'features' do
  context 'empty file' do
    let(:filename) { 'spec/fixtures/empty.txt' }
    it 'has empty output' do
      expect { system %(./po.rb #{filename}) }
        .to output('')
        .to_stdout_from_any_process
    end

    it 'has a 0 exit code' do
      expect(system %(./po.rb #{filename})).to be true
    end
  end
end
