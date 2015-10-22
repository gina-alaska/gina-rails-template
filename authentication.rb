def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

gem 'omniauth'
gem 'omniauth-github'
gem "omniauth-google-oauth2"
gem "omniauth-openid"
gem 'google-api-client'
# run "bundle install"

generate(:resource, "user", "name:string", "email:string", "avatar:string")
generate(:model, "authorization", "provider:string", "uid:string", "user_id:integer")
generate(:controller, "sessions")
generate(:resource, "membership", "user_id:integer", "email:string")

directory "controllers/gina_authentication", "app/controllers/concerns/gina_authentication/", recursive: true
directory "models/gina_authentication", "app/models/concerns/gina_authentication/", recursive: true
directory "views/gina_authentication", "app/views/gina_authentication/", recursive: true

inject_into_class "app/controllers/application_controller.rb",'ApplicationController', "  include GinaAuthentication::AppHelpers\n"
inject_into_class "app/controllers/sessions_controller.rb",'SessionsController', <<-CODE
  protect_from_forgery :except => [:create, :failure]
  include GinaAuthentication::Sessions
CODE

inject_into_class "app/controllers/users_controller.rb",'UsersController', "  include GinaAuthentication::Users\n"

inject_into_class "app/models/user.rb",'User', "  include GinaAuthentication::UserModel\n"
inject_into_class "app/models/authorization.rb",'Authorization', "  include GinaAuthentication::AuthorizationModel\n"
inject_into_class "app/models/membership.rb",'Membership', "  include GinaAuthentication::MembershipModel\n"

route "resources :sessions"
route "get '/auth/failure', to: 'sessions#failure'"
route "get '/auth/:provider/callback', to: 'sessions#create'"
route "post '/auth/:provider/callback', to: 'sessions#create'"
route "get '/auth/:provider/disable', to: 'users#disable_provider'"
route "get '/signin', to: 'sessions#new', as: :signin"
route "get '/signout', to: 'sessions#destroy', as: :signout"

after_bundle do
  initializer 'omniauth.rb', <<-CODE
    require 'openid/store/filesystem'

    Rails.application.config.middleware.use OmniAuth::Builder do
      # provider :developer unless Rails.env.production?
      # provider :google_oauth2, ENV["GOOGLE_KEY"], ENV["GOOGLE_SECRET"], {
      #   name: "google",
      #   scope: "userinfo.email, userinfo.profile",
      #   image_aspect_ratio: "square",
      #   image_size: 50# ,
      #   prompt: 'consent'
      # }
      # provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
      provider :openid, :store => OpenID::Store::Filesystem.new("./tmp"), :name => 'gina', :identifier => 'https://id.gina.alaska.edu'
    end
  CODE
end
