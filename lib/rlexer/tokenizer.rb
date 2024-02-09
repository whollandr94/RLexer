require_relative "token"

module RLexer
  class Tokenizer
    attr_accessor :tokens
    
    def initialize
      @tokens = []
      @cursor = 0
    end
    
    def reset
      @tokens = []
      @cursor = 0
    end
    
    def tokenize(html_string)
      @state = :data_state
      return_state = nil
    
      until end_of_input?(html_string)
        char = html_string[@cursor]
        consume
    
        case @state
        when :data_state
          pp :data_state
          if char == "<"
            @state = :tag_open_state
            next
          end
        when :tag_open_state
          pp :tag_open_state
          if char == "!"
            @state = :markup_declaration_open_state
            next
          end
        when :markup_declaration_open_state
          pp :markup_declaration_open_state
          if peek?(html_string, "--")
            consume_multiple(1)
            @token = Token.new("Comment")
            @state = :comment_start_state
            next
          end
        when :comment_start_state
          pp :comment_start_state
          if char == "-"
            @state = :comment_start_dash_state
            next
          end
          if char == ">"
            #TODO: Implement parse errors (abrupt-closing-of-empty-comment)
            @state = :data_state
            @tokens << @token
            @token = nil
            next
          end
          @state = :comment_state
          reconsume
          next
        when :comment_state
          pp :comment_state
          #TODO: Fully implement :comment_state
          if char == "-"
            @state = :comment_end_dash_state
            next
          end
          append_current_input_character(char)
        when :comment_start_dash_state
          pp :comment_start_dash_state
          if char == "-"
            @state = :comment_end_state
            next
          end
          if char == ">"
            #TODO: Implement parse errors (abrupt-closing-of-empty-comment)
            @state = :data_state
            @tokens << @token
            @token = nil
            next
          end
          if eof?
            #TODO: Implement parse errors (eof-in-comment)
            @tokens << @token
            @token = nil
            next
            #TODO: Implement end-of-file token
          end
          append_current_input_character(char)
          @state = :comment_state
          reconsume
          next
        when :comment_end_dash_state
          pp :comment_end_dash_state
          #TODO: Fully implement :comment_end_dash_state
          if char == "-"
            @state = :comment_end_state
            next
          end
        when :comment_end_state
          pp :comment_end_state
          if char == ">"
            @state = :data_state
            @tokens << @token
            @token = nil
            next
          end
        end
      end
    end
    
    def eof?
      false
    end
    
    def consume
      @cursor += 1
    end
    
    def consume_multiple(amount)
      @cursor += amount
    end
    
    def reconsume
      @cursor -= 1
    end
    
    def append_current_input_character(char)
      @token.data ||= ""
      @token.data += char
    end
    
    def end_of_input?(html_string)
      @cursor >= html_string.length
    end
    
    def peek?(html_string, chars)
      html_string[@cursor - 1, chars.length] == chars
    end
  end
end