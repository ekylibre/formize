source "http://rubygems.org"

gem "rails", "~> 3.0"
gem "jquery-rails"
gem "fastercsv", :platforms=>[:ruby_18, :mri_18, :mingw_18, :mswin]

group :development do
  gem "jeweler", "~> 1.6.4"
  gem "rcov", ">= 0"
  gem "rdoc", ">= 2.4.2"
end
