module PDF417
  class HighLevelEncoder
    PAD_CODEWORD = 900

    def initialize(barcode_config)
      @config = barcode_config
    end

    def encode
      compact_message(config.message)
      .yield_self(&method(:padding))
      .yield_self(&method(:length_descriptor))
      .yield_self(&method(:error_correction))
      .yield_self { |codewords| BarcodeMatrix.new(codewords, config) }
    end

    private

    attr_reader :config

    def compact_message(message)
      MessageCompactor.new(message).compact
    end

    def padding(codewords)
      correction_codeword_length = 2 ** (config.security_level + 1)
      sum_codewords = 1 + codewords.length + correction_codeword_length
      rows = (sum_codewords / config.columns.to_f).ceil
      pad_count = rows * config.columns - sum_codewords
      codewords.concat(Array.new(pad_count, PAD_CODEWORD))
    end

    def length_descriptor(codewords)
      codewords.unshift(1 + codewords.length)
    end

    def error_correction(codewords)
      codewords.concat(
        ErrorCorrection.correction_codewords(
          codewords, config.security_level
        )
      )
    end
  end
end
