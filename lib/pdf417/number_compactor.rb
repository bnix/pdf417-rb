module PDF417
  class NumberCompactor
    BASE = 900
    MAX_ENCODABLE_LENGTH = 44

    attr_reader :message

    def initialize(message)
      @message = message
    end

    def compact(start = 0, length = @message.length)
      codewords = []
      encoding_group_count = (length / MAX_ENCODABLE_LENGTH.to_f).ceil

      encoding_group_count.times do |group_index|
        group_offset = (group_index * MAX_ENCODABLE_LENGTH) + start
        number = message[group_offset, MAX_ENCODABLE_LENGTH].prepend('1').to_i

        until number.zero? do
          codewords.unshift(number % BASE)
          number /= BASE
        end
      end

      codewords
    end

    def compactable_length(start)
      pos = start
      consecutive_count = 0
      while pos < message.length
        char = message[pos]
        if char >= '0' && char <= '9'
          consecutive_count += 1
        else
          break
        end
        pos += 1
      end

      consecutive_count >= 13 ? consecutive_count : 0
    end
  end
end
