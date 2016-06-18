# -*- mode: ruby; coding: utf-8 -*-

require 'English'
require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/' unless ENV['SPEC_COVERAGE']
    add_filter '/.bundle/'
    # not covered by tests
    add_filter '/lib/checklist/ui.rb'
    add_filter '/lib/checklist/step_library.rb'
  end
  SimpleCov.command_name 'spec'
end

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride' if $stdout.tty?

begin
  # silence warnings
  orig_verbose = $VERBOSE
  $VERBOSE = nil
  require 'wrong'
ensure
  $VERBOSE = orig_verbose
end

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

  let(:ui_output) { StringIO.new }
  let(:ui) { Checklist::UI.new(out: ui_output) }

  before do
    @step_template_cache =
      Checklist::Step.instance_variable_get(:@template_cache).dup
  end

  after do
    Checklist::Step.instance_variable_set :@template_cache,
                                          @step_template_cache
    if Checklist::Checklist.instance_variable_defined?(:@template_cache)
      Checklist::Checklist.remove_instance_variable :@template_cache
    end
  end
end

require 'checklist'

Rainbow.enabled = false
