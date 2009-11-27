require 'rake'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "structured_warnings"
    gemspec.summary = "Provides structured warnings for Ruby, using an exception-like interface and hierarchy."
    gemspec.description = "This is an implementation of Daniel Berger's proposal of structured warnings for Ruby."
    gemspec.email = "ruby@schmidtwisser.de"
    gemspec.homepage = "http://github.com/schmidt/structured_warnings"
    gemspec.authors = ["Gregor Schmidt"]

    gemspec.add_development_dependency('rake')
    gemspec.add_development_dependency('jeweler', '>= 1.4.0')
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

desc "Run all tests"
task :test do 
  require 'rake/runtest'
  Rake.run_tests 'test/**/*_test.rb'
end

desc 'Generate documentation for the structured_warnings gem.'
Rake::RDocTask.new(:doc) do |doc|
  doc.rdoc_dir = 'doc'
  doc.title = 'structured_warnings'
  doc.options << '--line-numbers' << '--inline-source'
  doc.rdoc_files.include('README.rdoc')
  doc.rdoc_files.include('lib/**/*.rb')
end

task :default => :test
