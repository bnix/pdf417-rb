module PDF417
  class TextCompactor
    PAD_CODEPOINT = 29
    SUBMODE_UPPER = 'UPP'
    SUBMODE_LOWER = 'LOW'
    SUBMODE_MIXED = 'MIX'
    SUBMODE_PUNCT = 'PUN'

    # Generate mappings of PDF417 submode codepoints to ASCII characters
    CODEPOINTS = {
      SUBMODE_UPPER => "ABCDEFGHIJKLMNOPQRSTUVWXYZ\s",
      SUBMODE_LOWER => "abcdefghijklmnopqrstuvwxyz\s",
      SUBMODE_MIXED => "0123456789&\r\t,:#-.$/+%*=^",
      SUBMODE_PUNCT => ";<>@[\\]_`~!\r\t,:\n-.$/\"|*()?{}'"
    }.transform_values! do |submode_chars|
      submode_chars.chars.each_with_object({}).with_index do |(char, acc), i|
        acc[char] = i
        acc
      end
    end

    CODEPOINT_SUPERSET = CODEPOINTS.values.reduce(Set.new) do |set, codepoints|
      set.merge(codepoints.keys)
    end

    # Codepoint sequences for changing submode
    JUMP_COMMANDS = {
      SUBMODE_UPPER => {
        SUBMODE_LOWER => [27],
        SUBMODE_MIXED => [28],
        SUBMODE_PUNCT => [28, 25]
      },
      SUBMODE_LOWER => {
        SUBMODE_UPPER => [28, 28],
        SUBMODE_MIXED => [28],
        SUBMODE_PUNCT => [28, 25]
      },
      SUBMODE_MIXED => {
        SUBMODE_LOWER => [27],
        SUBMODE_UPPER => [28],
        SUBMODE_PUNCT => [25]
      },
      SUBMODE_PUNCT => {
        SUBMODE_LOWER => [29, 27],
        SUBMODE_UPPER => [29],
        SUBMODE_MIXED => [29, 28]
      }
    }

    attr_reader :message

    def initialize(message)
      @message = message
    end

    def compact(start, length)
      compact_text(start, length).each_slice(2).map do |left, right|
        (left * 30) + (right || PAD_CODEPOINT)
      end
    end

    # Encode each char as a submode codepoint, changing submode only
    # when current char cannot be mapped to a codepoint in current submode.
    def compact_text(start = 0, length = @message.length)
      codepoints = []
      current_submode = SUBMODE_UPPER

      message[start, length].each_char do |char|
        submode = next_submode(char, current_submode)

        if current_submode != submode
          codepoints.concat(jump_submode(current_submode, submode))
          current_submode = submode
        end

        codepoints << codepoint(char, current_submode)
      end

      codepoints
    end

    def compactable_length(start)
      pos = start
      consecutive_text_count = 0
      consecutive_number_count = 0

      while pos < message.length
        char = message[pos]
        if char >= '0' && char <= '9'
          consecutive_number_count += 1
          consecutive_text_count += 1

          if consecutive_number_count == 13
            consecutive_text_count -= consecutive_number_count
            break
          end
        elsif CODEPOINT_SUPERSET.include?(char)
          consecutive_number_count = 0
          consecutive_text_count += 1
        else
          break
        end

        pos += 1
      end

      # TODO byte compaction would be used for < 5 characters
      # consecutive_text_count >= 5 ? consecutive_text_count : 0
      consecutive_text_count
    end

    def next_submode(char, preferred_submode)
      submode_options = CODEPOINTS.reduce([]) do |acc, (submode, codepoints)|
        acc << submode if codepoints.key?(char)
        acc
      end

      if submode_options.include?(preferred_submode)
        preferred_submode
      else
        submode_options.first
      end
    end

    def codepoint(char, submode)
      CODEPOINTS[submode][char]
    end

    def jump_submode(from_submode, to_submode)
      JUMP_COMMANDS[from_submode][to_submode]
    end
  end
end
