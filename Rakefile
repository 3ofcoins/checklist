require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'

desc 'Run Minitest specs'
Rake::TestTask.new :spec do |task|
  task.libs << 'spec'
  task.test_files = FileList['spec/**/*_spec.rb']
end

task :rubocop do
  sh 'rubocop'
end

def make_selftest_checklist
  require 'checklist'

  Checklist.checklist 'Self Test' do
    step 'rake', :rubocop
    step 'rake', :spec
  end
end

def selftest_checklist
  @selftest_checklist ||= make_selftest_checklist
end

desc 'Run self test'
task :selftest do
  selftest_checklist.run!
end

desc 'Show self test checklist'
task 'selftest:show' do
  selftest_checklist.report
end

task default: :selftest
