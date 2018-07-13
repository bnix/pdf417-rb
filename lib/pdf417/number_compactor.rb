module PDF417
  class NumberCompactor
    BASE = 900
    MAX_ENCODABLE_LENGTH = 44

    def self.compact(message)
      codewords = []
      encoding_group_count = (message.length / MAX_ENCODABLE_LENGTH.to_f).ceil

      encoding_group_count.times do |group_index|
        group_offset = group_index * MAX_ENCODABLE_LENGTH
        number = message[group_offset, MAX_ENCODABLE_LENGTH].prepend('1').to_i

        until number.zero? do
          codewords.unshift(number % BASE)
          number /= BASE
        end
      end

      codewords
    end
  end
end
