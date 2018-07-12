RSpec.describe PDF417::BarcodePainter do
  describe '#paint' do
    it 'paints only bars' do
      barcode = [[0x1d5c0], [0x1f560]] # 11101010111000000, 11111010101100000
      canvas = MockCanvas.new
      painter = PDF417::BarcodePainter.new(barcode, canvas)
      painter.paint

      expect(canvas.rectangles.length).to eq(8)
    end

    it 'scales rectangle widths to match contiguous bar modules' do
      barcode = [[0x1a1b8]] # 11010000110111000
      canvas = MockCanvas.new
      painter = PDF417::BarcodePainter.new(barcode, canvas)
      painter.paint

      expect(canvas.rectangles[0]).to include(width: 6)
      expect(canvas.rectangles[1]).to include(width: 3)
      expect(canvas.rectangles[2]).to include(width: 6)
      expect(canvas.rectangles[3]).to include(width: 9)
    end

    it 'paints bars at correct coordinates' do
      barcode = [[0x1a1b8], [0x1be42]] # 11010000110111000, 11011111001000010
      canvas = MockCanvas.new
      painter = PDF417::BarcodePainter.new(barcode, canvas)
      painter.paint

      expect(canvas.rectangles[0]).to include(x: 0, y: 0)
      expect(canvas.rectangles[1]).to include(x: 9, y: 0)
      expect(canvas.rectangles[2]).to include(x: 24, y: 0)
      expect(canvas.rectangles[3]).to include(x: 33, y: 0)

      expect(canvas.rectangles[4]).to include(x: 0, y: 9)
      expect(canvas.rectangles[5]).to include(x: 9, y: 9)
      expect(canvas.rectangles[6]).to include(x: 30, y: 9)
      expect(canvas.rectangles[7]).to include(x: 45, y: 9)
    end
  end

  # Helper for inspecting paint commands
  class MockCanvas
    attr_reader :rectangles

    def initialize
      @rectangles = []
    end

    def rect(x:, y:, width:, height:)
      rectangles << { x: x, y: y, width: width, height: height }
    end
  end
end
