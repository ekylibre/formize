namespace :formize do
  desc "Generate formize.js"
  task :generate do
    File.open("lib/assets/javascripts/formize.js", "wb") do |js|
      for file in Dir.glob("lib/assets/javascripts/locales/jquery.ui.datepicker*.js").sort
        File.open(file, "rb") do |f|
          js.write f.read
          js.write "\n"
        end
      end
      File.open("lib/assets/javascripts/jquery.ui.timepicker.js", "rb") do |f|
        js.write f.read
        js.write "\n"
      end
      for file in Dir.glob("lib/assets/javascripts/locales/jquery.ui.timepicker*.js").sort
        File.open(file, "rb") do |f|
          js.write f.read
          js.write "\n"
        end
      end
      File.open("lib/assets/javascripts/jquery.ui.formize.js", "rb") do |f|
        js.write f.read
        js.write "\n"
      end
    end
  end
end
