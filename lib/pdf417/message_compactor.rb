module PDF417
  class MessageCompactor
    # TODO implement binary and numeric compactors
    def self.compact(message)
      TextCompactor.compact(message)
    end
  end
end
