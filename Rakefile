require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'
require './lib/lightblue'
import './lib/tasks/lightblue.rake'

RuboCop::RakeTask.new

task default: :test

Rake::TestTask.new do |t|
  t.verbose = true
  t.libs    = ['lib']
  t.libs.push 'test'
  t.test_files = FileList['test/**/*_test.rb']
end
