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

task :default => [:rubocop, :spec]
