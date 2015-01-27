def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

gem "haml"
gem "stamp"

gem_group :development, :test do
  gem "pry"
  gem "better_errors", group: :development
  gem "guard"
  gem "guard-minitest"
end

if yes?("Add authentication?")
  apply 'authentication.rb'
end

# run "bundle install"

# if yes?("Create cookbook?")
#   apply 'cookbook.rb'
# end

apply 'bower.rb'

after_bundle do
  rake "db:migrate"
  run "touch tmp/restart.txt"
end

apply 'git.rb'
