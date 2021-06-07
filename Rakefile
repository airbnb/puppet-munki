require "puppetlabs_spec_helper/rake_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new
PuppetLint.configuration.send("disable_variable_scope")
task :all do
  Rake::Task["lint"].invoke
  Rake::Task["syntax"].invoke
end

task default: [:all]
