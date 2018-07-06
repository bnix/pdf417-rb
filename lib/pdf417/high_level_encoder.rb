module PDF417
  class HighLevelEncoder
    PAD_CODEWORD = 900

    attr_reader :message, :security, :columns

    def initialize(message, security, columns)
      @message = message
      @security = security
      @columns = columns
    end

    def each_row
      codewords = pack_codewords
      total_rows = codewords.length / columns

      codewords.each_slice(columns).with_index do |row, row_index|
        cluster = row_index % 3
        left, right = row_indicators(cluster, total_rows)
                      .map { |x| 30 * (row_index / 3) + x }

        yield row.unshift(left).push(right), cluster
      end
    end

    private

    def pack_codewords
      message_codewords = MessageCompactor.new(message).compact
      padding_codewords = padding(message_codewords.length)
      data_codewords = message_codewords + padding_codewords
      length_descriptor = 1 + data_codewords.length
      data_codewords.unshift(length_descriptor)
      # error correction
      correction_codewords = []

      data_codewords.concat(correction_codewords)
    end

    def padding(message_codewords_count)
      correction_codewords_count =  2 ** (security + 1)
      sum_codewords = 1 + message_codewords_count + correction_codewords_count
      pad_count = sum_codewords % columns
      Array.new(pad_count, PAD_CODEWORD)
    end

    # To aid the decoding process, particularly when a barcode symbol is
    # scanned obliquely, each row has left and right row indicator codewords to
    # identify the row number.
    def row_indicators(cluster, row_count)
      f1 = (row_count - 1) / 3
      f2 = columns - 1
      f3 = security * 3 + ((row_count - 1) % 3)

      case cluster
      when 0; [f1, f2]
      when 1; [f3, f1]
      when 2; [f2, f3]
      end
    end
  end
end
