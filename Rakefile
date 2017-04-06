# require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'
require 'rubocop/rake_task'

task default: :test

desc 'Run all tests and linting'
task :test do
  Rake::Task[:lint].invoke
  Rake::Task[:rubocop].invoke
end

desc 'Run rubocop'
task :rubocop do
  RuboCop::RakeTask.new
end

# task :rspec do
#   RSpec::Core::RakeTask.new(:spec)
# end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
end
