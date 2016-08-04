require 'rake/testtask'

namespace :test do

  Rake::TestTask.new :pet_service do |t|
    t.pattern = "pet_service/test/*_test.rb"
    t.verbose = false
  end

  Rake::TestTask.new :arena_service do |t|
    t.pattern = "arena_service/test/*_test.rb"
    t.verbose = false
  end

  Rake::TestTask.new :contest_worker do |t|
    t.pattern = "contest_worker/test/*_test.rb"
    t.verbose = false
  end

  Rake::TestTask.new :service_wrappers do |t|
    t.pattern = "service_wrappers/test/*_test.rb"
    t.verbose = false
  end

end

task :test => ['test:pet_service', 'test:arena_service', 'test:contest_worker', 'test:service_wrappers']