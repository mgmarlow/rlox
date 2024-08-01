# frozen_string_literal: true

require "test_helper"

class TestAstPrinter < Minitest::Test
  def setup
    @visitor = Rlox::Visitor::AstPrinter.new
  end

  def test_nil_expr
    expr = Rlox::Expr::Literal.new(nil)
    assert_equal "nil", @visitor.print(expr)
  end

  def test_literal_expr
    expr = Rlox::Expr::Literal.new(2)
    assert_equal "2", @visitor.print(expr)
  end

  def test_grouping_expr
    expr = Rlox::Expr::Grouping.new(Rlox::Expr::Literal.new(2))
    assert_equal "(group 2)", @visitor.print(expr)
  end

  def test_unary_expr
    expr = Rlox::Expr::Unary.new(Rlox::Token.new(:minus, "-", nil, 1), Rlox::Expr::Literal.new(2))
    assert_equal "(- 2)", @visitor.print(expr)
  end

  def test_binary_expr
    expr = Rlox::Expr::Binary.new(
      Rlox::Expr::Literal.new(2),
      Rlox::Token.new(:plus, "+", nil, 1),
      Rlox::Expr::Literal.new(2)
    )

    assert_equal "(+ 2 2)", @visitor.print(expr)
  end

  def test_complex_expression
    expr = Rlox::Expr::Binary.new(
      Rlox::Expr::Unary.new(
        Rlox::Token.new(:minus, "-", nil, 1),
        Rlox::Expr::Literal.new(123)
      ),
      Rlox::Token.new(:star, "*", nil, 1),
      Rlox::Expr::Grouping.new(Rlox::Expr::Literal.new(45.67))
    )

    assert_equal "(* (- 123) (group 45.67))", @visitor.print(expr)
  end
end
