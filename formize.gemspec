# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{formize}
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Brice Texier}]
  s.date = %q{2011-08-24}
  s.description = %q{Like simple_form or formtastic, it aims to handle easily forms but taking in account AJAX and HTML5 on depending fields mainly.}
  s.email = %q{brice.texier@ekylibre.org}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".travis.yml",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "assets/javascripts/formize.js",
    "formize.gemspec",
    "lib/formize.rb",
    "lib/formize/action_pack.rb",
    "lib/formize/definition.rb",
    "lib/formize/definition/element.rb",
    "lib/formize/definition/field.rb",
    "lib/formize/definition/field_set.rb",
    "lib/formize/definition/form.rb",
    "lib/formize/definition/form_element.rb",
    "lib/formize/form_helper.rb",
    "lib/formize/generator.rb",
    "test/helper.rb",
    "test/test_formize.rb"
  ]
  s.homepage = %q{http://github.com/burisu/formize}
  s.licenses = [%q{MIT}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.7}
  s.summary = %q{Simple form DSL with dynamic interactions for Rails}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<actionpack>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 2.4.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<actionpack>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 2.4.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<actionpack>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 2.4.2"])
  end
end

