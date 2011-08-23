# encoding: utf-8
# Used for a bug with ruby 1.9.1 
# http://rubyforge.org/tracker/index.php?func=detail&aid=28920&group_id=1513&atid=5921

require 'rubygems'
unless RUBY_VERSION.to_s.match(/^1.8/)
  require 'psych'
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "formize"
  gem.homepage = "http://github.com/burisu/formize"
  gem.license = "MIT"
  gem.summary = "Simple form DSL with dynamic interactions for Rails"
  gem.description = "Like simple_form or formtastic, it aims to handle easily forms but taking in account AJAX and HTML5 on depending fields mainly."
  gem.email = "brice.texier@ekylibre.org"
  gem.authors = ["Brice Texier"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

# require 'rake/rdoctask'
# Rake::RDocTask.new do |rdoc|
#   version = File.exist?('VERSION') ? File.read('VERSION') : ""
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title = "Formize #{version}"
#   rdoc.rdoc_files.include('README*')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end  

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Formize #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
