# -*- mode: ruby; coding: utf-8 -*-

require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/' unless ENV['SPEC_COVERAGE']
    add_filter('lib/checklist/ui.rb') # not covered by tests
  end
  SimpleCov.command_name 'spec'
end

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride' if $stdout.tty?
require 'wrong'

Wrong.config.alias_assert :expect, override: true

class Minitest::Spec # rubocop:disable Style/ClassAndModuleChildren
  include Wrong::Assert
  include Wrong::Helpers

  def increment_assertion_count
    self.assertions += 1
  end

  def failure_class
    Minitest::Assertion
  end
end

require 'checklist'

module Checklist
  module Spec
    class UI
      attr_reader :record

      def initialize
        @record = []
      end

      def say(msg = '')
        @record << [:say, msg]
      end

      def header(checklist)
        @record << [:header, checklist]
      end

      def start(step)
        @record << [:start, step]
      end

      def finish(step)
        @record << [:finish, step]
      end

      def complete(checklist)
        @record << [:complete, checklist]
      end

      def incomplete(checklist, remaining_steps)
        @record << [:incomplete, checklist, remaining_steps]
      end
    end

    class Body
      attr_reader :steps
      def initialize
        @steps = {}
      end

      def step(key)
        @steps[key] ||= 0
        @steps[key] += 1
      end
    end
  end
end

EXAMPLE_STEPS = [
  ['one',   'one done'],
  ['two',   'check two'],
  ['three', 'three it is'],
  ['four',  'here you are', 'A surprise description']].freeze

def example_checklist
  body = Checklist::Spec::Body.new
  cl = Checklist::Checklist.new('Test', ui: Checklist::Spec::UI.new)

  class << cl
    attr_accessor :body
  end

  cl.body = body

  EXAMPLE_STEPS.each_with_index do |step, ii|
    a_challenge, a_response, a_description = step
    cl.step a_challenge.to_sym do
      challenge a_challenge
      response a_response
      description a_description
      converge do
        body.step(ii)
      end
    end
  end

  cl
end
