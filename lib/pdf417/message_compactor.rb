module PDF417
  class MessageCompactor
    def initialize(message)
      @message = message
    end

    # TODO implement binary and numeric compactors
    def compact
      TextCompactor.compact(@message)
    end
  end
end
