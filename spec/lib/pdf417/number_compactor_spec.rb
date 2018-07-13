RSpec.describe PDF417::NumberCompactor do
  describe '::compact' do
    subject(:compactor) { described_class }

    it 'prepends 1 to each group of numbers' do
      expect(compactor.compact('90')).to eq([190])
    end

    it 'converts to base 900' do
      expect(compactor.compact('923')).to eq([2, 123])
    end

    it 'enocodes numbers in blocks of 44 decimals' do
      one_number_encoded  = compactor.compact('2' * 44)
      two_numbers_encoded = compactor.compact('2' * 45)

      block1 = two_numbers_encoded[1, two_numbers_encoded.length - 1]
      block2 = two_numbers_encoded.first

      expect(block1).to eq(one_number_encoded)
      expect(block2).to eq(12)
    end
  end
end
