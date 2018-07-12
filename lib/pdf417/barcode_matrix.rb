module PDF417
  class BarcodeMatrix
    attr_reader :codewords, :config

    def initialize(codewords, barcode_config)
      @codewords = codewords
      @config = barcode_config
    end

    def each_row
      total_rows = codewords.length / config.columns

      codewords.each_slice(config.columns).with_index do |row, row_index|
        cluster = row_index % 3
        left, right = row_indicators(cluster, total_rows)
                      .map! { |x| 30 * (row_index / 3) + x }

        yield row.unshift(left).push(right), cluster
      end
    end

    private

    # To aid the decoding process, particularly when a barcode symbol is
    # scanned obliquely, each row has left and right row indicator codewords to
    # identify the row number.
    def row_indicators(cluster, row_count)
      f1 = (row_count - 1) / 3
      f2 = config.columns - 1
      f3 = config.security_level * 3 + ((row_count - 1) % 3)

      case cluster
      when 0; [f1, f2]
      when 1; [f3, f1]
      when 2; [f2, f3]
      end
    end
  end
end
