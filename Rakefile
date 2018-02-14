require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = Dir.glob('test/**/*_spec.rb')
end

RuboCop::RakeTask.new(:rubocop) do |t|
    t.patterns = Dir.glob('lib/**/*.rb')
end

task default: :spec
