require 'rspec/core/rake_task'

task :default => :spec

desc "Play Chess from menu"
task :play do
  ruby "-w lib/chess.rb"
end

desc "Run tests for chess game"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "-c -w"
  t.verbose = false
end
