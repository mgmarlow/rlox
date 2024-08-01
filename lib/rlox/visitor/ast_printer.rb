# frozen_string_literal: true

module Rlox
  module Visitor
    class AstPrinter
      def print(expr)
        expr.accept(self)
      end

      def visit_binary_expr(expr)
        parenthesize(expr.operator.lexeme, expr.left, expr.right)
      end

      def visit_grouping_expr(expr)
        parenthesize("group", expr.expression)
      end

      def visit_literal_expr(expr)
        return "nil" if expr.value.nil?

        expr.value.to_s
      end

      def visit_unary_expr(expr)
        parenthesize(expr.operator.lexeme, expr.right)
      end

      private

      def parenthesize(name, *exprs)
        str = "(#{name}"
        exprs.each do |expr|
          str << " "
          str << expr.accept(self)
        end
        str << ")"
        str
      end
    end
  end
end
