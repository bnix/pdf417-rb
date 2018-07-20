RSpec.describe PDF417::CompactionManager do
  describe '#compact' do
    it 'compacts text' do
      compactor = PDF417::CompactionManager.new('ABCDE')
      expect(compactor.compact).to eq([1, 63, 149])
    end

    context 'picking a compactor' do
      it 'uses the first compactor to return a non-zero length' do
        skipped_compactor   = double(compactable_length: 0)
        used_compactor      = double(compactable_length: 3, compact: [])
        unreached_compactor = double(compactable_length: 3)

        compactors = [skipped_compactor, used_compactor, unreached_compactor]

        PDF417::CompactionManager.new('486', compactors: compactors).compact

        expect(used_compactor).to have_received(:compact)
      end

      it 'raises an error if a compactor was not chosen' do
        compactors = [double(compactable_length: 0)]

        expect {
          PDF417::CompactionManager.new('0', compactors: compactors).compact
        }.to raise_error PDF417::MessageNotCompactable
      end
    end

    context 'changing compaction mode' do
      it 'implicitly uses text compaction' do
        expect(PDF417::CompactionManager.new('A').compact).to eq([29])
      end

      it 'adds codeword 902 to change to number compaction' do
        message = '5'
        number_stub = PDF417::NumberCompactor.new(message)
        manager = PDF417::CompactionManager.new(message, compactors: [number_stub])

        allow(number_stub).to receive(:compactable_length).and_return(1)

        expect(manager.compact).to eq([902, 15])
      end

      it 'adds codeword 900 to change to text compaction' do
        message = '5A'
        text_stub = PDF417::TextCompactor.new(message)
        number_stub = PDF417::NumberCompactor.new(message)
        compactors = [number_stub, text_stub]
        manager = PDF417::CompactionManager.new(message, compactors: compactors)

        allow(number_stub).to receive(:compactable_length).with(0).and_return(1)
        allow(number_stub).to receive(:compactable_length).with(1).and_return(0)
        allow(text_stub).to receive(:compactable_length).with(1).and_return(1)

        expect(manager.compact).to eq([902, 15, 900, 29])
      end
    end
  end
end
