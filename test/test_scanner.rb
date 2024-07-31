# frozen_string_literal: true

require "test_helper"

class TestScanner < Minitest::Test
  def test_newlines_advance_line_counter
    scanner = Rlox::Scanner.new "42\n\n42\n\n"
    _ = scanner.scan_tokens

    assert_equal 5, scanner.line
  end

  def test_it_handles_1_char_tokens
    tests = [
      ["(", :left_paren],
      [")", :right_paren],
      ["{", :left_brace],
      ["}", :right_brace],
      [",", :comma],
      [".", :dot],
      ["-", :minus],
      ["+", :plus],
      [";", :semicolon],
      ["*", :star],
      ["!", :bang],
      ["=", :equal],
      ["<", :less],
      [">", :greater],
      ["/", :slash]
    ]

    tests.each do |test|
      input, expected = test
      scanner = Rlox::Scanner.new input
      got = scanner.scan_tokens.first
      assert_equal expected, got.type
    end
  end

  def test_it_handles_2_char_tokens
    tests = [
      [">=", :greater_equal],
      ["<=", :less_equal],
      ["==", :equal_equal],
      ["!=", :bang_equal]
    ]

    tests.each do |test|
      input, expected = test
      scanner = Rlox::Scanner.new input
      got = scanner.scan_tokens.first
      assert_equal expected, got.type
    end
  end

  def test_it_handles_comments
    scanner = Rlox::Scanner.new "// I'm a comment"
    got = scanner.scan_tokens.first

    # Comments are ignored!
    assert_equal :eof, got.type
  end

  def test_it_handles_digits
    scanner = Rlox::Scanner.new "42"
    got = scanner.scan_tokens.first

    assert_equal :number, got.type
    assert_equal "42", got.lexeme
  end

  def test_it_handles_strings
    scanner = Rlox::Scanner.new '"a string"'
    got = scanner.scan_tokens.first

    assert_equal :string, got.type
    assert_equal '"a string"', got.lexeme
  end

  def test_it_handles_identifiers
    scanner = Rlox::Scanner.new "foo_bar"
    got = scanner.scan_tokens.first

    assert_equal :identifier, got.type
    assert_equal "foo_bar", got.lexeme
  end

  def test_it_handles_empty_function_definitions
    scanner = Rlox::Scanner.new "fun foo_bar () {}"
    got = scanner.scan_tokens.map(&:type)
    expected = [:fun, :identifier, :left_paren, :right_paren, :left_brace, :right_brace, :eof]

    assert_equal expected, got
  end
end
