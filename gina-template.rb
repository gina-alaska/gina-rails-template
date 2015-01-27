def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

gem "haml"
gem "bower-rails"
gem "stamp"
gem "pry"
gem "better_errors", group: :development
gem "guard"
gem "guard-minitest"

if yes?("Add authentication?")
  apply 'authentication.rb'
end

run "bundle install"

generate('bower_rails:initialize')

inject_into_file("Bowerfile", after: "# asset 'bootstrap'") do
  '
  asset "bootstrap"
  asset "font-awesome"
  '
end

rake "bower:install"

inject_into_file("app/assets/javascripts/application.js", after: "//= require jquery_ujs\n") do
  "//= require bootstrap/dist/js/bootstrap\n"
end
inject_into_file("app/assets/stylesheets/application.css", before: " *= require_self\n") do
  " *= require bootstrap/dist/css/bootstrap
 *= require font-awesome/css/font-awesome\n"
end

rake "db:migrate"
run "touch tmp/restart.txt"  

if yes?("Create cookbook?")
  apply 'cookbook.rb'
end

apply 'git.rb'
