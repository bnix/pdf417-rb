module PDF417
  class LowLevelEncoder
    START_PATTERN = 0x1fea8
    STOP_PATTERN  = 0x3fa29

    attr_reader :barcode_logic, :writer

    def initialize(barcode_logic)
      @barcode_logic = barcode_logic
      @writer = RowBuffer.new
    end

    def encode
      barcode_logic.each_row do |codewords, cluster|
        writer.next_row
        writer << START_PATTERN
        codewords.each do |codeword|
          writer << CodewordCluster.fetch(cluster, codeword)
        end
        writer << STOP_PATTERN
      end

      writer.rows
    end

    class RowBuffer
      attr_reader :rows

      def initialize
        @rows = []
        @cursor = -1
      end

      def next_row
        @cursor += 1
        @rows << []
      end

      def <<(low_encoded_word)
        @rows[@cursor] << low_encoded_word
      end
    end
  end
end
