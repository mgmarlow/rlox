# frozen_string_literal: true

module Rlox
  module Visitor
    class Interpreter
      class Unreachable < StandardError; end

      def interpret(statements)
        statements.each { |stmt| execute(stmt) }
      rescue RuntimeError => e
        Lox.runtime_error(e)
      end

      def visit_expression_stmt(stmt)
        evaluate(stmt.expression)
        nil
      end

      def visit_print_stmt(stmt)
        value = evaluate(stmt.expression)
        puts stringify(value)
        nil
      end

      def visit_literal_expr(expr)
        expr.value
      end

      def visit_grouping_expr(expr)
        evaluate(expr.expression)
      end

      def visit_unary_expr(expr)
        right = evaluate(expr.right)

        case expr.operator.type
        when :bang
          !is_truthy(right)
        when :minus
          check_number_op(expr.operator, right)
          -1 * right
        else
          raise Unreachable.new
        end
      end

      def visit_binary_expr(expr)
        left = evaluate(expr.left)
        right = evaluate(expr.right)

        case expr.operator.type
        when :minus
          check_number_op(expr.operator, left, right)
          left - right
        when :slash
          check_number_op(expr.operator, left, right)
          left / right
        when :star
          check_number_op(expr.operator, left, right)
          left * right
        when :plus
          left + right
        when :greater
          check_number_op(expr.operator, left, right)
          left > right
        when :greater_equal
          check_number_op(expr.operator, left, right)
          left >= right
        when :less
          check_number_op(expr.operator, left, right)
          left < right
        when :less_equal
          check_number_op(expr.operator, left, right)
          left <= right
        when :bang_equal
          !is_equal(left, right)
        when :equal_equal
          is_equal(left, right)
        else
          raise Unreachable.new
        end
      end

      private

      def evaluate(expr)
        expr.accept(self)
      end

      def execute(stmt)
        stmt.accept(self)
      end

      def is_truthy(val)
        return false if val.nil?
        return val if val.is_a?(TrueClass) || val.is_a?(FalseClass)

        true
      end

      def is_equal(a, b)
        a == b
      end

      def check_number_op(op, *operands)
        return if operands.all? { |operand| operand.is_a?(Numeric) }

        raise Rlox::RuntimeError.new(op, "operands must be Numeric")
      end

      def check_plus_op(op, *operands)
        return if operands.all? { |operand| operand.is_a?(Numeric) } || operands.all? { |operand| operand.is_a?(String) }

        raise Rlox::RuntimeError.new(op, "operands must both be either Numeric or String")
      end

      def stringify(obj)
        return "nil" if obj.nil?

        case obj
        when Numeric
          text = obj.to_s
          if text.end_with?(".0")
            text.sub!(".0", "")
          end
          text
        else
          obj.to_s
        end
      end
    end
  end
end
