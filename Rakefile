# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'rake'
require 'rake/testtask'
require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task :default => [:test]
task :test do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.warning = false
    t.test_files = FileList['test/lib/*_test.rb']
    t.verbose = true
  end
end
