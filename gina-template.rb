def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

add_source "https://rails-assets.org"

gem "haml"
gem "stamp"
gem 'puma'
gem 'active_link_to'
gem 'simple_form'
gem 'friendly_id'
gem 'version'
gem "font-awesome-rails"
gem 'bundler', '>= 1.8.4'
gem 'rails-assets-bootstrap'
# gem 'rails-assets-font-awesome'
gem 'rails-assets-jasny-bootstrap'

gem_group :development, :production do
  gem 'rails_12factor'
end

gem_group :development, :test do
  gem "pry"
  gem "better_errors", group: :development
  gem "guard"
  gem "guard-minitest"
end

generate("simple_form:install",  "--bootstrap")

if yes?("Add authentication?")
  apply 'authentication.rb'
end

# run "bundle install"

# if yes?("Create cookbook?")
#   apply 'cookbook.rb'
# end

after_bundle do
  rake "db:migrate"
  run "touch tmp/restart.txt"
end

apply 'git.rb'
