#!/usr/bin/env rake

require "bundler/gem_tasks"
require "rake/testtask"

desc "Default: run unit tests."
task :default => :test

desc "Test the acts_as_archival plugin."
Rake::TestTask.new(:test) do |t|
  t.libs    << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end
