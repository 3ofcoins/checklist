require_relative './checklist'

module Checklist
  class << self
    def new(*args, &block)
      Checklist.new(*args, &block)
    end

    def Step(name, &block) # rubocop:disable Style/MethodName
      Step.define_template(name, &block)
    end
  end

  module ObjectExt
    def Checklist(name, *args, &block) # rubocop:disable Style/MethodName
      if block_given?
        unless args.empty?
          raise ArgumentError, 'Checklist definition does not take arguments'
        end
        Checklist.define_template(name, &block)
      else
        Checklist.render_template(name, *args)
      end
    end
  end
end

class Object
  include Checklist::ObjectExt
end
