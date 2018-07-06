lib = File.expand_path(__dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pdf417/codeword_cluster'
require 'pdf417/text_compactor'
require 'pdf417/message_compactor'
require 'pdf417/high_level_encoder'
require 'pdf417/low_level_encoder'
require 'pdf417/barcode_painter'
require 'pdf417/canvases/svg'

module PDF417
  def self.generate(message)
    high_encoder = HighLevelEncoder.new(message, 0, 8)
    low_encoder = LowLevelEncoder.new(high_encoder)
    painter = BarcodePainter.new(low_encoder.encode, Canvases::SVG.new)
    painter.paint

    File.open('barcode.svg', 'w') do |f|
      f.write(painter.canvas)
    end
  end
end
