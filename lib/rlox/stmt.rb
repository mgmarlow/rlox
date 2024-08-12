# frozen_string_literal: true

module Rlox
  module Stmt
    STATEMENTS = [
      ["Expression", [:expression]],
      ["Print", [:expression]]
    ]

    STATEMENTS.each do |stmt|
      classname, names = stmt

      klass = Rlox::Stmt.const_set(classname, Class.new)
      klass.class_eval do
        attr_accessor(*names)

        define_method(:initialize) do |*values|
          names.each_with_index do |name, i|
            instance_variable_set(:"@#{name}", values[i])
          end
        end

        define_method(:accept) do |visitor|
          visitor.public_send(:"visit_#{classname.downcase}_stmt", self)
        end
      end
    end
  end
end
