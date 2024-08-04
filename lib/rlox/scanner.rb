# frozen_string_literal: true

module Rlox
  class Token
    TOKEN_TYPES = [
      # single-character tokens.
      :left_paren, :right_paren, :left_brace, :right_brace,
      :comma, :dot, :minus, :plus, :semicolon, :slash, :star,

      # one or two character tokens.
      :bang, :bang_equal,
      :equal, :equal_equal,
      :greater, :greater_equal,
      :less, :less_equal,

      # literals.
      :identifier, :string, :number,

      # keywords.
      :and, :class, :else, :false, :fun, :for, :if, :nil, :or,
      :print, :return, :super, :this, :true, :var, :while,

      :eof
    ].freeze

    attr_reader :type, :lexeme, :literal, :line

    def initialize(type, lexeme, literal, line)
      raise InvalidTokenType.new type unless TOKEN_TYPES.include? type

      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end

    def to_s
      "#{type} #{lexeme} #{literal}"
    end
  end

  class Scanner
    KEYWORDS = {
      "and" => :and,
      "class" => :class,
      "else" => :else,
      "false" => :false,
      "for" => :for,
      "fun" => :fun,
      "if" => :if,
      "nil" => :nil,
      "or" => :or,
      "print" => :print,
      "return" => :return,
      "super" => :super,
      "this" => :this,
      "true" => :true,
      "var" => :var,
      "while" => :while
    }.freeze

    attr_reader :line, :tokens

    def initialize(source)
      @source = source
      @tokens = []
      @start = 0
      @current = 0
      @line = 1
    end

    def scan_tokens
      until done?
        @start = @current
        scan_token
      end

      @tokens << Token.new(:eof, "", nil, @line)
      @tokens
    end

    def done?
      @current >= @source.length
    end

    private

    def scan_token
      case advance
      when "("
        add_token(:left_paren)
      when ")"
        add_token(:right_paren)
      when "{"
        add_token(:left_brace)
      when "}"
        add_token(:right_brace)
      when ","
        add_token(:comma)
      when "."
        add_token(:dot)
      when "-"
        add_token(:minus)
      when "+"
        add_token(:plus)
      when ";"
        add_token(:semicolon)
      when "*"
        add_token(:star)
      when "!"
        add_token(match?("=") ? :bang_equal : :bang)
      when "="
        add_token(match?("=") ? :equal_equal : :equal)
      when "<"
        add_token(match?("=") ? :less_equal : :less)
      when ">"
        add_token(match?("=") ? :greater_equal : :greater)
      when "/"
        if match?("/")
          # Comments go until end of line; ignored.
          advance while peek != "\n" && !done?
        else
          add_token(:slash)
        end
      when '"'
        string
      when /[[:digit:]]/
        number
      when /[[:alpha:]]/
        identifier
      when " ", "\r", "\t"
        # Ignore whitespace.
      when "\n"
        @line += 1
      else
        Lox.error(@line, "unexpected character")
      end
    end

    def advance
      ch = @source[@current]
      @current += 1
      ch
    end

    def add_token(type, literal = nil)
      text = @source[@start...@current]
      @tokens << Token.new(type, text, literal, @line)
    end

    def match?(ch)
      return false if done?
      return false if @source[@current] != ch

      @current += 1
      true
    end

    def peek
      return "\0" if done?

      @source[@current]
    end

    def peek_next
      return "\0" if @current + 1 >= @source.length

      @source[@current + 1]
    end

    def is_digit?(ch)
      ch.match?(/[[:digit:]]/)
    end

    def is_alpha?(ch)
      ch.match?(/[[:alpha:]_]/)
    end

    def is_alphanumeric?(ch)
      is_digit?(ch) || is_alpha?(ch)
    end

    def string
      until peek == '"' || done?
        @line += 1 if peek == "\n"

        advance
      end

      if done?
        Lox.error(@line, "unterminated string")
      end

      # Closing ".
      advance

      # Trim surrounding quotes.
      value = @source[(@start + 1)...(@current - 1)]
      add_token(:string, value)
    end

    def number
      advance while is_digit?(peek)

      if peek != "." && is_digit?(peek_next)
        advance

        advance while is_digit?(peek)
      end

      add_token(:number, @source[@start...@current].to_f)
    end

    def identifier
      advance while is_alphanumeric?(peek)

      text = @source[@start...@current]
      type = KEYWORDS[text] || :identifier

      add_token(type)
    end
  end
end
