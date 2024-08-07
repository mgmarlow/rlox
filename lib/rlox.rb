# frozen_string_literal: true

require_relative "rlox/version"
require_relative "rlox/scanner"
require_relative "rlox/expr"
require_relative "rlox/visitor"
require_relative "rlox/visitor/ast_printer"
require_relative "rlox/visitor/interpreter"
require_relative "rlox/parser"
require_relative "rlox/runtime_error"

module Rlox
  class Error < StandardError; end

  class Lox
    @@had_error = false
    @@had_runtime_error = false

    class << self
      def error(line, message)
        report(line, "", message)
      end

      def token_error(token, message)
        if token.type == :eof
          report(token.line, " at end", message)
        else
          report(token.line, " at '#{token.lexeme}'", message)
        end
      end

      def runtime_error(error)
        puts "#{error.message}\n[line #{error.token.line}]"
        @@had_runtime_error = true
      end

      def report(line, where, message)
        puts "[line #{line}] Error #{where}: #{message}"
        @@had_error = true
      end

      def had_error?
        @@had_error
      end

      def had_runtime_error?
        @@had_runtime_error
      end
    end

    def initialize
      @interpreter = Visitor::Interpreter.new
    end

    def run_file(file)
      contents = File.read(file)
      run(contents)
      exit(65) if Lox.had_error?
      exit(70) if Lox.had_runtime_error?
    end

    def run_prompt
      print "> "
      while (input = gets.chomp) != ".exit"
        run(input)
        print "> "
        @@had_error = false
      end
    end

    private

    def run(source)
      scanner = Scanner.new(source)
      tokens = scanner.scan_tokens
      parser = Parser.new(tokens)
      expr = parser.parse
      return if Lox.had_error?

      @interpreter.interpret(expr)
    end
  end

  class CLI
    def run
      if ARGV.length > 1
        puts "Usage: rlox [script]"
        nil
      elsif ARGV.length == 1
        Lox.new.run_file(ARGV[0])
      else
        Lox.new.run_prompt
      end
    end
  end
end
