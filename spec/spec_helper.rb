# -*- mode: ruby; coding: utf-8 -*-

require 'English'
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
end

require 'checklist'
