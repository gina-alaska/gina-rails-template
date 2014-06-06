def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

# used for template files
def secret_key
  SecureRandom.hex(64)
end

def application_name
  File.basename(Dir.pwd)
end

run "berks cookbook #{application_name} --chef-minitest"
run "mv #{application_name} cookbook"
directory "cookbook", "cookbook"

append_to_file "cookbook/recipes/default.rb" do
<<-RECIPE
include_recipe "#{application_name}::database"
include_recipe "#{application_name}::application"
include_recipe "#{application_name}::unicorn"
include_recipe "#{application_name}::nginx"
RECIPE
end

insert_into_file "cookbook/Berksfile", :before => "metadata\n" do
  <<-EOF

cookbook 'chruby'
cookbook 'nginx'
cookbook 'postgresql'
cookbook 'database'
cookbook 'unicorn'
cookbook 'runit'
cookbook 'yum-epel'
cookbook 'yum-gina', git: 'git@github.com:gina-alaska/yum-gina-cookbook'

  EOF
end

append_to_file "cookbook/metadata.rb" do
  <<-EOF
supports "centos", ">= 6.0"

depends 'chruby'
depends 'nginx'
depends 'postgresql'
depends 'database'
depends 'unicorn'
depends 'runit'
depends 'yum-epel'
depends 'yum-gina'
  EOF
end

inside("cookbook") do
  run "kitchen init"
end

create_file ".gvm.rb" do
  <<-EOF
app_path "/www/#{application_name}/current"
chruby.environment 1.9
startup ['bundle install', 'service unicorn_#{application_name} start']
EOF
end
