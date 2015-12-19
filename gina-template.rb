def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

gem "haml"
gem "stamp"
gem 'puma'
gem 'active_link_to'
gem 'simple_form'
gem 'friendly_id'
gem 'version'
gem 'bundler', '>= 1.8.4'
gem "font-awesome-rails"

add_source "https://rails-assets.org" do
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-jasny-bootstrap'
end

gem_group :production do
  gem 'rails_12factor'
end

gem_group :development, :test do
  gem "pry"
  gem "better_errors", group: :development
  gem "guard"
  gem "guard-minitest"
end


if yes?("Add authentication?")
  apply 'authentication.rb'
end

after_bundle do
  generate("simple_form:install",  "--bootstrap")
  rake "db:migrate"
  run "touch tmp/restart.txt"
end

apply 'git.rb'
