require 'puppetlabs_spec_helper/rake_tasks'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

task :all do
  Rake::Task['rubocop'].invoke
  Rake::Task['lint'].invoke
  Rake::Task['syntax'].invoke
end

task default: [:all]
