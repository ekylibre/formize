# encoding: utf-8
Gem::Specification.new do |s|
  s.name = "formize"
  File.open("VERSION", "rb") do |f|
    s.version = f.read
  end
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.author = "Brice Texier"
  s.email  = "burisu@oneiros.fr"
  s.summary = "Simple form DSL with dynamic interactions for Rails"
  s.description = "Like simple_form or formtastic, it aims to handle easily forms but taking in account AJAX and HTML5 on depending fields mainly."
  s.extra_rdoc_files = ["LICENSE", "README.rdoc" ]
  s.test_files = `git ls-files test`.split("\n") 
  exclusions = [ "#{s.name}.gemspec", ".travis.yml", ".gitignore", "Gemfile", "Gemfile.lock", "Rakefile", "ci/Gemfile.rails-3.1", "ci/Gemfile.rails-3.2", "ci"]
  s.files = `git ls-files`.split("\n").delete_if{|f| exclusions.include?(f)}
  s.homepage = "http://github.com/burisu/formize"
  s.license = "MIT"
  s.require_path = "lib"

  add_runtime_dependency = (s.respond_to?(:add_runtime_dependency) ? :add_runtime_dependency : :add_dependency)
  s.send(add_runtime_dependency, "rails", [">= 3.1"])
  s.send(add_runtime_dependency, "jquery-rails", [">= 0"])
end

