module PDF417
  class BarcodePainter
    attr_reader :barcode, :canvas

    def initialize(barcode, canvas)
      @barcode = barcode
      @canvas = canvas
    end

    def paint
      x_scale = 3
      y_scale = x_scale * 3

      barcode.each_with_index do |row, row_index|
        y_offset = row_index * y_scale
        x_offset = 0

        row.each do |low_codeword|
          module_widths = calculate_block_widths(low_codeword)

          module_widths.each_with_index do |width, i|
            scaled_width = width * x_scale
            if i.even?
              canvas.rect(
                x: x_offset, y: y_offset, width: scaled_width, height: y_scale
              )
            end

            x_offset += scaled_width
          end
        end
      end
    end

    private

    # Sum contiguous bar or space modules for more efficient painting.
    # Bar modules are represented by 1, space modules 0.
    # Example: the binary representation of codeword 0x15c70 is
    # 10101110001110000 so the resulting widths would be
    # [1, 1, 1, 1, 3, 3, 3, 4].
    def calculate_block_widths(low_codeword)
      raw_pattern = low_codeword.to_s(2)
      width_index = -1
      last_char = nil
      aggregated_widths = []

      raw_pattern.each_char do |char|
        if char != last_char
          width_index += 1
          aggregated_widths[width_index] = 0
        end

        last_char = char
        aggregated_widths[width_index] += 1
      end

      aggregated_widths
    end
  end
end
