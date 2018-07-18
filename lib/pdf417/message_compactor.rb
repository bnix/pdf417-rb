module PDF417
  class MessageCompactor
    # TODO byte compaction

    JUMP_COMMANDS = {
      TextCompactor   => 900,
      NumberCompactor => 902
    }

    attr_reader :message, :compactors

    def initialize(message, compactors: nil)
      @message = message
      @compactors = compactors || default_compactors(message)
    end

    def compact
      pos = 0
      current_compactor = TextCompactor # Default compaction mode
      compacted = []

      while pos < message.length
        # Each compactor decides if a sub-message beginning at pos is
        # suitable for its type of compaction and will refuse compaction
        # should it not be space efficient. For example, numeric compaction is
        # best suited for 13+ consecutive digits.
        length = 0
        compactor = compactors.find do |c|
          (length = c.compactable_length(pos)) > 0
        end

        raise MessageNotCompactable unless length > 0

        if current_compactor != compactor.class
          compacted << JUMP_COMMANDS[compactor.class]
          current_compactor = compactor.class
        end

        compacted.concat(compactor.compact(pos, length))
        pos += length
      end

      compacted
    end

    def default_compactors(message)
      [
        NumberCompactor.new(message),
        TextCompactor.new(message)
      ]
    end
  end
end
