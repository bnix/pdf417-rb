RSpec.describe PDF417::TextCompactor do
  def compactor(msg)
    described_class.new(msg)
  end

  describe '#compact' do
    it 'turns codepoints into codwords' do
      expect(compactor('AB').compact(0,2)).to eq([1])
    end

    it 'pads incomplete codewords' do
      expect(compactor('ABC').compact(0,3)).to eq([1, 89])
    end
  end

  describe '#compact_text' do
    it 'uses uppercase as the implicit submode' do
      expect(compactor('J').compact_text).to eq([9])
    end

    context 'changing submode' do
      it 'uses jump commands to change submode' do
        expect(compactor('@Tq5').compact_text).to eq([28, 25, 3, 29, 19, 27, 16, 28, 5])
      end

      context 'from uppercase' do
        it 'jumps to lower' do
          expect(compactor('Zy').compact_text).to eq([25, 27, 24])
        end

        it 'jumps to mixed' do
          expect(compactor('G&').compact_text).to eq([6, 28, 10])
        end

        it 'jumps to punctuation' do
          expect(compactor('N?').compact_text).to eq([13, 28, 25, 25])
        end

        it 'does not code a jump command when the submode is the same' do
          expect(compactor('XYZ').compact_text).to eq([23, 24, 25])
        end
      end

      context 'from lowercase' do
        it 'jumps to uppercases' do
          expect(compactor('yZ').compact_text).to eq([27, 24, 28, 28, 25])
        end

        it 'jumps to mixed' do
          expect(compactor('f0').compact_text).to eq([27, 5, 28, 0])
        end

        it 'jumps to punctuation' do
          expect(compactor('m{').compact_text).to eq([27, 12, 28, 25, 26])
        end

        it 'does not code a jump command when the submode is the same' do
          expect(compactor('ijk').compact_text).to eq([27, 8, 9, 10])
        end
      end

      context 'from mixed' do
        it 'jumps to uppercases' do
          expect(compactor('5A').compact_text).to eq([28, 5, 28, 0])
        end

        it 'jumps to lowercase' do
          expect(compactor('=u').compact_text).to eq([28, 23, 27, 20])
        end

        it 'jumps to punctuation' do
          expect(compactor('#>').compact_text).to eq([28, 15, 25, 2])
        end

        it 'does not code a jump command when the submode is the same' do
          expect(compactor('987').compact_text).to eq([28, 9, 8, 7])
        end
      end
    end

    context 'when multiple submodes can code a character' do
      context 'and the current submode contains the character' do
        it 'does not change submodes' do
          expect(compactor("a\s").compact_text).to eq([27, 0, 26])
        end
      end

      context 'and the current submode does not contain the character' do
        it 'changes to the first matching submode' do
          mixed = PDF417::TextCompactor::SUBMODE_MIXED
          punct = PDF417::TextCompactor::SUBMODE_PUNCT
          search_order = PDF417::TextCompactor::CODEPOINTS.keys
          expect(compactor('$').compact_text).to eq([28, 18])
          expect(search_order.index(mixed)).to be < search_order.index(punct)
        end
      end
    end
  end

  describe 'submode character maps' do
    context 'uppercase submode' do
      it 'maps all uppercase characters' do
        submode_char_values = {
          'A' => 0,  'B' => 1,  'C' => 2,  'D' => 3,  'E' => 4,  'F' => 5,
          'G' => 6,  'H' => 7,  'I' => 8,  'J' => 9,  'K' => 10, 'L' => 11,
          'M' => 12, 'N' => 13, 'O' => 14, 'P' => 15, 'Q' => 16, 'R' => 17,
          'S' => 18, 'T' => 19, 'U' => 20, 'V' => 21, 'W' => 22, 'X' => 23,
          'Y' => 24, 'Z' => 25, ' ' => 26
        }
        upp_submode = PDF417::TextCompactor::SUBMODE_UPPER
        submode_table = PDF417::TextCompactor::CODEPOINTS[upp_submode]
        expect(submode_table).to eq(submode_char_values)
      end
    end

    context 'lowercase submode' do
      it 'maps all lowercase characters' do
        submode_char_values = {
          'a' => 0,  'b' => 1,  'c' => 2,  'd' => 3,  'e' => 4,  'f' => 5,
          'g' => 6,  'h' => 7,  'i' => 8,  'j' => 9,  'k' => 10, 'l' => 11,
          'm' => 12, 'n' => 13, 'o' => 14, 'p' => 15, 'q' => 16, 'r' => 17,
          's' => 18, 't' => 19, 'u' => 20, 'v' => 21, 'w' => 22, 'x' => 23,
          'y' => 24, 'z' => 25, ' ' => 26
        }
        low_submode = PDF417::TextCompactor::SUBMODE_LOWER
        submode_table = PDF417::TextCompactor::CODEPOINTS[low_submode]
        expect(submode_table).to eq(submode_char_values)
      end
    end

    context 'mixed submode' do
      it 'maps all mixed characters' do
        submode_char_values = {
          '0'  => 0,  '1' => 1,  '2' => 2,  '3' => 3,  '4' => 4, '5'   => 5,
          '6'  => 6,  '7' => 7,  '8' => 8,  '9' => 9,  '&' => 10, "\r" => 11,
          "\t" => 12, ',' => 13, ':' => 14, '#' => 15, '-' => 16, '.'  => 17,
          '$'  => 18, '/' => 19, '+' => 20, '%' => 21, '*' => 22, '='  => 23,
          '^'  => 24
        }
        mix_submode = PDF417::TextCompactor::SUBMODE_MIXED
        submode_table = PDF417::TextCompactor::CODEPOINTS[mix_submode]
        expect(submode_table).to eq(submode_char_values)
      end
    end

    context 'punctuation submode' do
      it 'maps all punctuation characters' do
        ";<>@[\\]_`~!\r\t,:\n-.$/\"|*()?{}'"
        submode_char_values = {
          ';'  => 0,  '<' => 1,  '>' => 2,  '@'  => 3,  '[' => 4, "\\"  => 5,
          ']'  => 6,  '_' => 7,  '`' => 8,  '~'  => 9,  '!' => 10, "\r" => 11,
          "\t" => 12, ',' => 13, ':' => 14, "\n" => 15, '-' => 16, '.'  => 17,
          '$'  => 18, '/' => 19, '"' => 20, '|'  => 21, '*' => 22, '('  => 23,
          ')'  => 24, '?' => 25, '{' =>26,  '}'  => 27, "'" => 28
        }
        punct_submode = PDF417::TextCompactor::SUBMODE_PUNCT
        submode_table = PDF417::TextCompactor::CODEPOINTS[punct_submode]
        expect(submode_table).to eq(submode_char_values)
      end
    end
  end
end
