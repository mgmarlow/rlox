# frozen_string_literal: true

module Rlox
  EXPRESSIONS = [
    ["Binary", [:left, :operator, :right]],
    ["Grouping", [:expression]],
    ["Literal", [:value]],
    ["Unary", [:operator, :right]]
  ]

  def self.build_expression_classes
    EXPRESSIONS.each do |expression|
      kind, names = expression

      classname = "#{kind}Expr"
      klass = Rlox.const_set(classname, Class.new)
      klass.class_eval do
        attr_accessor(*names)

        define_method(:initialize) do |*values|
          names.each_with_index do |name, i|
            instance_variable_set(:"@#{name}", values[i])
          end
        end
      end
    end
  end
end
