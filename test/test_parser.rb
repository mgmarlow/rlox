# frozen_string_literal: true

require "test_helper"

class TestParser < Minitest::Test
  def test_it_handles_equality
    got = parse("2 == 3")

    assert_instance_of Rlox::Expr::Binary, got
    assert_equal :equal_equal, got.operator.type
    assert_equal 2.0, got.left.value
    assert_equal 3.0, got.right.value

    got = parse("2 != 3")

    assert_instance_of Rlox::Expr::Binary, got
    assert_equal :bang_equal, got.operator.type
    assert_equal 2.0, got.left.value
    assert_equal 3.0, got.right.value
  end

  def test_it_handles_comparison
    got = parse("2 > 3")

    assert_instance_of Rlox::Expr::Binary, got
    assert_equal :greater, got.operator.type
    assert_equal 2.0, got.left.value
    assert_equal 3.0, got.right.value

    got = parse("2 >= 3")

    assert_instance_of Rlox::Expr::Binary, got
    assert_equal :greater_equal, got.operator.type
    assert_equal 2.0, got.left.value
    assert_equal 3.0, got.right.value

    got = parse("2 < 3")

    assert_instance_of Rlox::Expr::Binary, got
    assert_equal :less, got.operator.type
    assert_equal 2.0, got.left.value
    assert_equal 3.0, got.right.value

    got = parse("2 <= 3")

    assert_instance_of Rlox::Expr::Binary, got
    assert_equal :less_equal, got.operator.type
    assert_equal 2.0, got.left.value
    assert_equal 3.0, got.right.value
  end

  def test_it_handles_term
    got = parse("2 + 3")

    assert_instance_of Rlox::Expr::Binary, got
    assert_equal :plus, got.operator.type
    assert_equal 2.0, got.left.value
    assert_equal 3.0, got.right.value

    got = parse("2 - 3")

    assert_instance_of Rlox::Expr::Binary, got
    assert_equal :minus, got.operator.type
    assert_equal 2.0, got.left.value
    assert_equal 3.0, got.right.value
  end

  def test_it_handles_factor
    got = parse("2 * 3")

    assert_instance_of Rlox::Expr::Binary, got
    assert_equal :star, got.operator.type
    assert_equal 2.0, got.left.value
    assert_equal 3.0, got.right.value

    got = parse("2 / 3")

    assert_instance_of Rlox::Expr::Binary, got
    assert_equal :slash, got.operator.type
    assert_equal 2.0, got.left.value
    assert_equal 3.0, got.right.value
  end

  def test_it_handles_unary
    got = parse("!false")

    assert_instance_of Rlox::Expr::Unary, got
    assert_equal :bang, got.operator.type
    assert_equal false, got.right.value

    got = parse("!!false")

    assert_instance_of Rlox::Expr::Unary, got
    assert_equal :bang, got.operator.type
    assert_instance_of Rlox::Expr::Unary, got.right
    assert_equal :bang, got.right.operator.type
    assert_equal false, got.right.right.value

    got = parse("-2")

    assert_instance_of Rlox::Expr::Unary, got
    assert_equal :minus, got.operator.type
    assert_equal 2.0, got.right.value
  end

  def test_it_handles_primary
    got = parse("false")

    assert_instance_of Rlox::Expr::Literal, got
    assert_equal false, got.value

    got = parse("true")

    assert_instance_of Rlox::Expr::Literal, got
    assert_equal true, got.value

    got = parse("nil")

    assert_instance_of Rlox::Expr::Literal, got
    assert_nil got.value

    got = parse('"foobar"')

    assert_instance_of Rlox::Expr::Literal, got
    assert_equal "foobar", got.value

    got = parse("4")

    assert_instance_of Rlox::Expr::Literal, got
    assert_equal 4.0, got.value
  end

  def test_it_handles_groups
    got = parse("(3 + 2)")

    assert_instance_of Rlox::Expr::Grouping, got
    assert_instance_of Rlox::Expr::Binary, got.expression
  end

  def test_it_handles_unclosed_parens
    assert_raises Rlox::ParseError do
      parse("(3 + 2")
    end
  end

  def parse(str)
    scanner = Rlox::Scanner.new(str)
    tokens = scanner.scan_tokens
    parser = Rlox::Parser.new(tokens)
    # Call private method to bubble up exception that is caught by #parse
    parser.send(:expression)
  end
end
