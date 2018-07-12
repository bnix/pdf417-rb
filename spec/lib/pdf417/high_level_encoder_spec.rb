RSpec.describe PDF417::HighLevelEncoder do
  describe '#encode' do
    context 'length descriptor' do
      it 'equals the number of message and padding codewords plus itself' do
        config = PDF417::BarcodeConfig.new(message: 'AB', columns: 6, security_level: 0)
        barcode = PDF417::HighLevelEncoder.new(config).encode
        expect(barcode.codewords.first).to eq(4)
      end
    end

    context 'padding' do
      it 'adds pad codewords to fill empty columns' do
        config = PDF417::BarcodeConfig.new(message: 'NN' * 8, columns: 8, security_level: 0)
        barcode = PDF417::HighLevelEncoder.new(config).encode
        expect(barcode.codewords[9, 5]).to match_array([900] * 5)
      end
    end
  end
end
