require 'checklist/version'
require 'checklist/checklist'

module Checklist
  class << self
    def checklist(*args, &block)
      Checklist.new(*args, &block)
    end

    def self.Step(name, &block)
      Step.define_template(name, &block)
    end
  end
end
