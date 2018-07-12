RSpec.describe PDF417::ErrorCorrection do
  describe '::correction_codewords' do
    it 'returns expected codewords' do
      data = [5, 453, 178, 121, 239]
      security_level = 1
      codewords = PDF417::ErrorCorrection.correction_codewords(data, security_level)

      expect(codewords).to eq([452, 327, 657, 619])
    end
  end
end
