require 'checklist/version'
require 'checklist/checklist'

module Checklist
  class << self
    def checklist(*args, &block)
      Checklist.new(*args, &block)
    end

    def Step(name, &block) # rubocop:disable Style/MethodName
      Step.define_template(name, &block)
    end
  end
end
