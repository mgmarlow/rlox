# frozen_string_literal: true

require "test_helper"

class TestInterpreter < Minitest::Test
  def setup
    @visitor = Rlox::Visitor::Interpreter.new
  end

  def test_it_handles_literal_expr
    got = interpret('"foobar"')
    assert_equal "foobar", got

    got = interpret("2")
    assert_equal 2.0, got

    got = interpret("nil")
    assert_nil got
  end

  def test_it_handles_grouping_expr
    got = interpret('("foobar")')
    assert_equal "foobar", got
  end

  def test_it_handles_unary_expr
    got = interpret("!false")
    assert_equal true, got

    got = interpret("!true")
    assert_equal false, got

    got = interpret("!!true")
    assert_equal true, got

    got = interpret("!!false")
    assert_equal false, got

    got = interpret("-2")
    assert_equal(-2.0, got)
  end

  def test_it_handles_binary_expr
    got = interpret("2 * 2")
    assert_equal 4.0, got

    got = interpret("2 / 2")
    assert_equal 1.0, got

    got = interpret("2 - 2")
    assert_equal 0, got

    got = interpret("2 + 2")
    assert_equal 4.0, got

    got = interpret('"foo" + "bar"')
    assert_equal "foobar", got

    got = interpret("2 > 2")
    assert_equal false, got

    got = interpret("2 >= 2")
    assert_equal true, got

    got = interpret("2 < 2")
    assert_equal false, got

    got = interpret("2 <= 2")
    assert_equal true, got

    got = interpret("2 == 2")
    assert_equal true, got

    got = interpret("2 == nil")
    assert_equal false, got

    got = interpret("nil == nil")
    assert_equal true, got

    got = interpret("2 != 2")
    assert_equal false, got
  end

  def test_runtime_exception
    assert_raises Rlox::RuntimeError do
      interpret('-"foobar"')
    end

    assert_raises Rlox::RuntimeError do
      interpret('"foobar" > 3')
    end

    assert_raises Rlox::RuntimeError do
      interpret('"foobar" >= 3')
    end

    assert_raises Rlox::RuntimeError do
      interpret('"foobar" < 3')
    end

    assert_raises Rlox::RuntimeError do
      interpret('"foobar" <= 3')
    end

    assert_raises Rlox::RuntimeError do
      interpret('"foo" * "bar"')
    end

    assert_raises Rlox::RuntimeError do
      interpret('"foo" / "bar"')
    end

    assert_raises Rlox::RuntimeError do
      interpret('2 - "foobar"')
    end
  end

  def interpret(str)
    scanner = Rlox::Scanner.new(str)
    tokens = scanner.scan_tokens
    parser = Rlox::Parser.new(tokens)
    expr = parser.parse
    # Use private method since public method puts to stdout
    @visitor.send(:evaluate, expr)
  end
end
