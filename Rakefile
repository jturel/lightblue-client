require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new
  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  # missing rspec or rubocop lib
end
