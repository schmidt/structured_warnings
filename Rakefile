require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc/task'

CLEAN.include('**/*.gem', '**/*.rbx', '**/*.rbc')

namespace :gem do
  desc "Create the structured_warnings gem"
  task :create => [:clean] do
    spec = eval(IO.read('structured_warnings.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc "Install the structured_warnings gem"
  task :install => [:create] do
    file = Dir['*.gem'].first
    sh "gem install #{file}"
  end
end

Rake::TestTask.new do |t|
  t.verbose = true
  t.warning = true
  t.test_files = Dir['test/*.rb']
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
