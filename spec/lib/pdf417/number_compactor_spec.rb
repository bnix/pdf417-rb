RSpec.describe PDF417::NumberCompactor do
  def compactor(msg)
    described_class.new(msg)
  end

  describe '#compact' do
    it 'prepends 1 to each group of numbers' do
      expect(compactor('90').compact).to eq([190])
    end

    it 'converts to base 900' do
      expect(compactor('923').compact).to eq([2, 123])
    end

    it 'enocodes numbers in blocks of 44 digits' do
      one_number_encoded  = compactor('2' * 44).compact
      two_numbers_encoded = compactor('2' * 45).compact

      block1 = two_numbers_encoded[1, two_numbers_encoded.length - 1]
      block2 = two_numbers_encoded.first

      expect(block1).to eq(one_number_encoded)
      expect(block2).to eq(12)
    end
  end
end
