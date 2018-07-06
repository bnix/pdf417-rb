require 'rexml/document'

module PDF417
  module Canvases
    class SVG
      def initialize
        @doc = REXML::Document.new
        @doc.add(REXML::XMLDecl.new(1.0, 'UTF-8'))
        svg = REXML::Element.new('svg')
        svg.add_attributes('xmlns' => 'http://www.w3.org/2000/svg', 'version' => '1.1')
        @doc.add(svg)
      end

      def rect(x:, y:, width:, height:)
        rect = REXML::Element.new('rect')
        rect.add_attributes(
          'x' => x.to_s,
          'y' => y.to_s,
          'width' => width.to_s,
          'height' => height.to_s
        )
        @doc.root.add(rect)
      end

      def to_s
        String.new.tap { |io| @doc.write(io) }
      end
    end
  end
end
