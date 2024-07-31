# frozen_string_literal: true

require_relative "rlox/version"

module Rlox
  class Error < StandardError; end

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
    ]

    attr_reader :type, :lexeme, :literal, :line

    def initialize(type, lexeme, literal, line)
      raise InvalidTokenType.new type unless TOKEN_TYPES.include? type

      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end

    def to_s
      "#{TOKEN_TYPES.find_index(type)} #{lexeme} #{literal}"
    end
  end

  class Scanner
    def initialize(source)
      @source = source
      @tokens = []
      @start = 0
      @current = 0
      @line = 1
    end

    def scan_tokens
      until over? do
        @start = @current
        scan_token
      end

      @tokens << Token.new(:eof, "", nil, @line)
      @tokens
    end

    def over?
      @current >= @source.length
    end

    private

    def scan_token
      case advance
      when "("
        add_token(:left_paren)
      when ")"
        add_token(:right_paren)
      when '{'
        add_token(:left_brace)
      when '}'
        add_token(:right_brace)
      when ','
        add_token(:comma)
      when '.'
        add_token(:dot)
      when '-'
        add_token(:minus)
      when '+'
        add_token(:plus)
      when ';'
        add_token(:semicolon)
      when '*'
        add_token(:star)
      else
        Lox.error(@line, "unexpected character")
      end
    end

    def advance
      @current = @current + 1
      @source[@current]
    end

    def add_token(type, literal = nil)
      text = @source[@start..@current]
      @tokens << Token.new(type, text, literal, @line)
    end
  end

  class Lox
    @@had_error = false

    class << self
      def error(line, message)
        report(line, "", message)
      end

      def report(line, where, message)
        puts "[line #{line}] Error #{where}: #{message}"
        @@had_error = true
      end
    end

    def run_file(file)
      contents = File.read(file)
      run(contents)
      return if had_error?
    end

    def had_error?
      @@had_error
    end

    def run_prompt
      print "> "
      while (input = gets.chomp) != ".exit"
        print "> "
        run(input)
        @@had_error = false
      end
    end

    private

    def run(source)
      scanner = Scanner.new(source)
      tokens = scanner.scan_tokens
      tokens.each do |token|
        puts token
      end
    end
  end

  class CLI
    def run
      if ARGV.length > 1
        puts "Usage: rlox [script]" 
        return
      elsif ARGV.length == 1
        Lox.new.run_file(ARGV[0])
      else
        Lox.new.run_prompt
      end
    end
  end
end
