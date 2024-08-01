# frozen_string_literal: true

require_relative "rlox/version"
require_relative "rlox/scanner"
require_relative "rlox/expression_builder"

Rlox.build_expression_classes

module Rlox
  class Error < StandardError; end

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
      nil if had_error?
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
        nil
      elsif ARGV.length == 1
        Lox.new.run_file(ARGV[0])
      else
        Lox.new.run_prompt
      end
    end
  end
end
