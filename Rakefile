require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: :test

Rake::TestTask.new do |t|
  t.verbose = true
  t.libs    = ['lib']
  t.libs.push 'spec'
  t.test_files = FileList['spec/**/*_spec.rb']
end
