module PDF417
  class BarcodeConfig
    attr_accessor :columns, :message, :security_level

    def initialize(message:, columns:, security_level:)
      @message = message
      @columns = columns
      @security_level = security_level
    end
  end
end
