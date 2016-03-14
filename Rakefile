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

task default: [:rubocop, :spec]

task :selftest do
  require 'checklist'
  cl = Checklist::Checklist.new 'Self Test' do
    step 'Rubocop' do
      converge { Rake::Task[:rubocop].invoke }
    end

    step 'Spec' do
      converge { Rake::Task[:spec].invoke }
    end
  end

  cl.run!
end
