# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{formize}
  s.version = "0.0.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Brice Texier}]
  s.date = %q{2011-09-16}
  s.description = %q{Like simple_form or formtastic, it aims to handle easily forms but taking in account AJAX and HTML5 on depending fields mainly.}
  s.email = %q{brice.texier@ekylibre.org}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "MIT-LICENSE",
    "README.rdoc",
    "VERSION",
    "lib/assets/images/ui-bg_flat_0_aaaaaa_40x100.png",
    "lib/assets/images/ui-bg_glass_55_fbf9ee_1x400.png",
    "lib/assets/images/ui-bg_glass_65_ffffff_1x400.png",
    "lib/assets/images/ui-bg_glass_75_dadada_1x400.png",
    "lib/assets/images/ui-bg_glass_75_e6e6e6_1x400.png",
    "lib/assets/images/ui-bg_glass_75_ffffff_1x400.png",
    "lib/assets/images/ui-bg_highlight-soft_75_cccccc_1x100.png",
    "lib/assets/images/ui-bg_inset-soft_95_fef1ec_1x100.png",
    "lib/assets/images/ui-icons_222222_256x240.png",
    "lib/assets/images/ui-icons_2e83ff_256x240.png",
    "lib/assets/images/ui-icons_454545_256x240.png",
    "lib/assets/images/ui-icons_888888_256x240.png",
    "lib/assets/images/ui-icons_cd0a0a_256x240.png",
    "lib/assets/javascripts/formize.js",
    "lib/assets/javascripts/jquery.ui.formize.js",
    "lib/assets/javascripts/jquery.ui.timepicker.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-af.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-ar.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-az.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-bg.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-bs.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-ca.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-cs.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-da.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-de-CH.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-de.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-el.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-en-GB.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-eo.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-es.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-et.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-eu.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-fa.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-fi.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-fo.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-fr-CH.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-fr.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-he.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-hr.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-hu.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-hy.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-id.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-is.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-it.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-ja.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-ko.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-lt.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-lv.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-ms.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-nl-BE.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-nl.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-no.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-pl.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-pt-BR.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-ro.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-ru.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-sk.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-sl.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-sq.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-sr-SR.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-sr.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-sv.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-ta.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-th.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-tr.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-uk.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-vi.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-zh-CN.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-zh-HK.js",
    "lib/assets/javascripts/locales/jquery.ui.datepicker-zh-TW.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-cs.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-de.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-el.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-es.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-et.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-fr.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-hu.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-id.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-it.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-lt.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-nl.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-ru.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-tr.js",
    "lib/assets/javascripts/locales/jquery.ui.timepicker-vi.js",
    "lib/assets/stylesheets/formize.css",
    "lib/assets/stylesheets/jquery-ui.css",
    "lib/formize.rb",
    "lib/formize/action_controller.rb",
    "lib/formize/definition.rb",
    "lib/formize/definition/field.rb",
    "lib/formize/definition/field_set.rb",
    "lib/formize/definition/form.rb",
    "lib/formize/definition/form_element.rb",
    "lib/formize/engine.rb",
    "lib/formize/generator.rb",
    "lib/formize/helpers.rb",
    "lib/formize/helpers/asset_tag_helper.rb",
    "lib/formize/helpers/form_helper.rb",
    "lib/formize/helpers/form_tag_helper.rb",
    "lib/formize/helpers/tag_helper.rb",
    "lib/formize/railtie.rb",
    "lib/generators/formize/install/USAGE",
    "lib/generators/formize/install/install_generator.rb",
    "lib/generators/formize/install/templates/initializer.rb",
    "lib/tasks/formize.rake"
  ]
  s.homepage = %q{http://github.com/burisu/formize}
  s.licenses = [%q{MIT}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.7}
  s.summary = %q{Simple form DSL with dynamic interactions for Rails}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3"])
      s.add_runtime_dependency(%q<jquery-rails>, [">= 0"])
      s.add_runtime_dependency(%q<fastercsv>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 2.4.2"])
    else
      s.add_dependency(%q<rails>, ["~> 3"])
      s.add_dependency(%q<jquery-rails>, [">= 0"])
      s.add_dependency(%q<fastercsv>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 2.4.2"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3"])
    s.add_dependency(%q<jquery-rails>, [">= 0"])
    s.add_dependency(%q<fastercsv>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 2.4.2"])
  end
end

