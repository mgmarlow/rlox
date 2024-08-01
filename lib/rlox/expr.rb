# frozen_string_literal: true

module Rlox
  module Expr
    EXPRESSIONS = [
      ["Binary", [:left, :operator, :right]],
      ["Grouping", [:expression]],
      ["Literal", [:value]],
      ["Unary", [:operator, :right]]
    ]

    EXPRESSIONS.each do |expression|
      classname, names = expression

      klass = Rlox::Expr.const_set(classname, Class.new)
      klass.class_eval do
        attr_accessor(*names)

        define_method(:initialize) do |*values|
          names.each_with_index do |name, i|
            instance_variable_set(:"@#{name}", values[i])
          end
        end

        define_method(:accept) do |visitor|
          visitor.public_send(:"visit_#{classname.downcase}_expr", self)
        end
      end
    end
  end
end
