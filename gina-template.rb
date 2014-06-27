def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

gem "haml"
gem "bower-tools", github: "gina-alaska/bower-tools"
gem "pg"

if yes?("Add authentication?")
  apply 'authentication.rb'
end

run "bundle install"
generate('bower:tools:install')

run "bower install bootstrap"
run "bower install font-awesome"

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
