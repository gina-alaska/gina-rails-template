# used for template files
def secret_key
  SecureRandom.hex(64)
end

def application_name
  ARGV[0]
end

run "berks cookbook #{application_name}-cookbook --chef-minitest"
directory "cookbook", "#{application_name}-cookbook"

append_to_file "#{application_name}-cookbook/recipes/default.rb" do
<<-RECIPE
app_name = '#{application_name}'
account = node[app_name]['account']

include_recipe 'user'
include_recipe 'user::data_bag'
include_recipe '#{application_name}-cookbook::ruby'
include_recipe '#{application_name}-cookbook::nginx'

# user_account account do
# end

node[app_name]['package_deps'].each do |pkg|
  package pkg do
    action :install
  end
end

%w{ application_path shared_path config_path initializers_path }.each do |dir|
  directory node[app_name][dir] do
    owner account
    group account
    mode 00755
    action :create
    recursive true
  end
end

%w{ log tmp system tmp/pids tmp/sockets vendor vendor/assets }.each do |dir|
  directory "\#{node[app_name]['shared_path']}/\#{dir}" do
    owner account
    group account
    mode 0755
  end
end

link "/home/webdev/\#{app_name}" do
  to node[app_name]['deploy_path']
  owner account
  group account
end

template "\#{node[app_name]['shared_path']}/config/database.yml" do
  owner account
  group account
  mode 00644
    
  variables(node[app_name]["database"])
end

template "\#{node[app_name]['shared_path']}/config/initializers/secret_token.rb" do
  owner account
  group account
  mode 00644  
  variables(node[app_name]["rails"])
end

#######
# create nginx site config
#######

template "/etc/nginx/sites-available/\#{app_name}_site" do
  source 'nginx_site.erb'
  variables({
    install_path: node[app_name]['deploy_path'],
    name: app_name,
    user: node[app_name]['account']
  })
end

nginx_site "\#{app_name}_site"

########
# create bundle configs
########

directory "/home/\#{account}/.bundle" do
  owner account
  group account
  mode 00755
  action :create
end

template "/home/\#{account}/.bundle/config" do
  source "bundle/config.erb"
  owner account
  group account
  mode 00644
end

########
# create unicorn configs
########

unicorn_config "\#{node['unicorn_config_path']}/\#{app_name}.rb" do
  preload_app true
  listen("\#{node[app_name]['shared_path']}/tmp/sockets/unicorn.socket" => {backlog: 1024})
  pid("\#{node[app_name]['shared_path']}/tmp/pids/unicorn.pid")
  stderr_path("\#{node[app_name]['shared_path']}/log/unicorn.stderr.log")
  stdout_path("\#{node[app_name]['shared_path']}/log/unicorn.stdout.log")
  worker_timeout 60
  worker_processes [node['cpu']['total'].to_i * 4, 8].min
  working_directory "\#{node[app_name]['deploy_path']}"
  before_fork node[app_name]['before_fork']
  after_fork node[app_name]['after_fork']
end

template "/etc/init.d/unicorn_\#{app_name.gsub('-', '_').downcase}" do
  source "unicorn_init.erb"
  action :create
  mode 00755
  variables({
    install_path: node[app_name]['deploy_path'],
    unicorn_config_file: "\#{node['unicorn_config_path']}/#{app_name}.rb"
  })
end

service "unicorn_\#{app_name.gsub('-', '_').downcase}" do 
  action :enable
end

RECIPE
end

insert_into_file "#{application_name}-cookbook/Berksfile", :before => "metadata\n" do
  <<-EOF

cookbook "nginx"
cookbook "npm"
cookbook "application_ruby"
cookbook "yum", '~> 2.4.4'
cookbook "gina", '= 0.4.6', chef_api: :config
cookbook "gina-postgresql", chef_api: :config

cookbook "chruby"
cookbook "user", git: 'http://github.com/fnichol/chef-user'
  
  EOF
end

append_to_file "#{application_name}-cookbook/metadata.rb" do
  <<-EOF
supports "centos", ">= 6.0"

depends "chruby"
depends "npm"
depends "user"
depends "yum", '~> 2.4.4'
depends "application_ruby"
depends "gina", '~> 0.4.6'
depends "gina-postgresql"
depends "nginx"  
  EOF
end

remove_file "#{application_name}-cookbook/Vagrantfile"

inside("#{application_name}-cookbook") do
  run "kitchen init"
end

run "mv #{application_name}-cookbook .."