module RLexer
  class Token
    attr_accessor :type, :data

    def initialize(type, data = nil)
      @type = type
    end
  end
end