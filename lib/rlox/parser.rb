# frozen_string_literal: true

module Rlox
  class ParseError < StandardError; end

  class Parser
    def initialize(tokens)
      @current = 0
      @tokens = tokens
    end

    def parse
      statements = []

      until done?
        statements << statement
      end

      statements
    rescue ParseError
      nil
    end

    private

    def statement
      return print_statement if match?(:print)

      expression_statement
    end

    def print_statement
      value = expression
      consume(:semicolon, "expect a ';' after value")
      Stmt::Print.new(value)
    end

    def expression_statement
      value = expression
      consume(:semicolon, "expect a ';' after value")
      Stmt::Expression.new(value)
    end

    def expression
      equality
    end

    def equality
      expr = comparison

      while match?(:bang_equal, :equal_equal)
        op = previous
        right = comparison
        expr = Expr::Binary.new(expr, op, right)
      end

      expr
    end

    def comparison
      expr = term

      while match?(:greater, :greater_equal, :less, :less_equal)
        op = previous
        right = term
        expr = Expr::Binary.new(expr, op, right)
      end

      expr
    end

    def term
      expr = factor

      while match?(:minus, :plus)
        op = previous
        right = factor
        expr = Expr::Binary.new(expr, op, right)
      end

      expr
    end

    def factor
      expr = unary

      while match?(:slash, :star)
        op = previous
        right = unary
        expr = Expr::Binary.new(expr, op, right)
      end

      expr
    end

    def unary
      if match?(:bang, :minus)
        op = previous
        right = unary
        return Expr::Unary.new(op, right)
      end

      primary
    end

    def primary
      return Expr::Literal.new(false) if match?(:false)
      return Expr::Literal.new(true) if match?(:true)
      return Expr::Literal.new(nil) if match?(:nil)

      if match?(:number, :string)
        return Expr::Literal.new(previous.literal)
      end

      if match?(:left_paren)
        expr = expression
        consume(:right_paren, "expect ')' after expression")
        return Expr::Grouping.new(expr)
      end

      raise error(peek, "expect expression")
    end

    def consume(type, message)
      return advance if check?(type)

      raise error(peek, message)
    end

    def error(token, message)
      Lox.token_error(token, message)
      ParseError.new
    end

    def synchronize
      advance

      until done?
        return if previous.type == :semicolon

        case peek.type
        when :class, :fun, :var,
          :for, :if, :while,
          :print, :return
          return
        end

        advance
      end
    end

    def match?(*types)
      found = types.any? { |type| check?(type) }

      if found
        advance
        true
      else
        false
      end
    end

    def check?(type)
      return false if done?

      peek.type == type
    end

    def advance
      @current += 1 unless done?

      previous
    end

    def done?
      peek.type == :eof
    end

    def peek
      @tokens[@current]
    end

    def previous
      @tokens[@current - 1]
    end
  end
end
