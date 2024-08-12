# frozen_string_literal: true

require "test_helper"

class TestInterpreter < Minitest::Test
  def setup
    @visitor = Rlox::Visitor::Interpreter.new
  end

  def test_it_handles_expression_stmt
    # todo
  end

  def test_it_handles_literal_expr
    got = evaluate('"foobar"')
    assert_equal "foobar", got

    got = evaluate("2")
    assert_equal 2.0, got

    got = evaluate("nil")
    assert_nil got
  end

  def test_it_handles_grouping_expr
    got = evaluate('("foobar")')
    assert_equal "foobar", got
  end

  def test_it_handles_unary_expr
    got = evaluate("!false")
    assert_equal true, got

    got = evaluate("!true")
    assert_equal false, got

    got = evaluate("!!true")
    assert_equal true, got

    got = evaluate("!!false")
    assert_equal false, got

    got = evaluate("-2")
    assert_equal(-2.0, got)
  end

  def test_it_handles_binary_expr
    got = evaluate("2 * 2")
    assert_equal 4.0, got

    got = evaluate("2 / 2")
    assert_equal 1.0, got

    got = evaluate("2 - 2")
    assert_equal 0, got

    got = evaluate("2 + 2")
    assert_equal 4.0, got

    got = evaluate('"foo" + "bar"')
    assert_equal "foobar", got

    got = evaluate("2 > 2")
    assert_equal false, got

    got = evaluate("2 >= 2")
    assert_equal true, got

    got = evaluate("2 < 2")
    assert_equal false, got

    got = evaluate("2 <= 2")
    assert_equal true, got

    got = evaluate("2 == 2")
    assert_equal true, got

    got = evaluate("2 == nil")
    assert_equal false, got

    got = evaluate("nil == nil")
    assert_equal true, got

    got = evaluate("2 != 2")
    assert_equal false, got
  end

  def test_runtime_exception
    assert_raises Rlox::RuntimeError do
      evaluate('-"foobar"')
    end

    assert_raises Rlox::RuntimeError do
      evaluate('"foobar" > 3')
    end

    assert_raises Rlox::RuntimeError do
      evaluate('"foobar" >= 3')
    end

    assert_raises Rlox::RuntimeError do
      evaluate('"foobar" < 3')
    end

    assert_raises Rlox::RuntimeError do
      evaluate('"foobar" <= 3')
    end

    assert_raises Rlox::RuntimeError do
      evaluate('"foo" * "bar"')
    end

    assert_raises Rlox::RuntimeError do
      evaluate('"foo" / "bar"')
    end

    assert_raises Rlox::RuntimeError do
      evaluate('2 - "foobar"')
    end
  end

  def evaluate(str)
    scanner = Rlox::Scanner.new(str)
    tokens = scanner.scan_tokens
    parser = Rlox::Parser.new(tokens)
    # I'm being lazy here by forming expressions via strings since
    # it's convenient. It's a little bad for test hygiene though.
    expr = parser.send(:expression)
    # Use private method since public method puts to stdout
    @visitor.send(:evaluate, expr)
  end
end
