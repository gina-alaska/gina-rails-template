# GINA Rails Template

This is the start of a basic rails template.

There are 3 main actions that it will perform

* basic gem and git configuration for a new application
  * Adds haml and bower-tools gems
  * Installs bootstrap and font-awesome js libs and adds them to the application.{js|css} manifest files
* add authentication (optional)
  * Creates a couple of controllers, models and some views that can be used to help 
* create cookbook (optional)

##How to use

You will need to checkout the template repo to somewhere local

    git clone https://github.com/gina-alaska/gina-rails-template.git
    
For a new rails application use
    
    rails new <ApplicationName> -m <path/to/gina-rails-template/gina-template.rb>
    
This can be [applied to an already existing application](http://edgeguides.rubyonrails.org/rails_application_templates.html) but use with care as several files are created that might conflict with existing code.  Where possible this has been handled using concerns so it should be possible to just add them to already existing controllers/models

##Authentication Configuration

This template will ask if you wish to add authentication support, this will add necessary omniauth gems to you Gemfile and create several controllers and models.

The following providers are supported

* GINA::ID (OpenID) - http://id.gina.alaska.edu
* Google (OAuth2) - disabled by default since it requires ENV variables to properly work
* Github (OAuth2/Github) - disabled by default since it requires additional ENV variables to properly work

To use Github authentication register your application at: https://github.com/settings/applications/new

To use Google authentication register your application at: https://cloud.google.com/console    

After registering your application you can edit the <code>config/initializers/omniauth.rb</code> file and uncomment the approriate lines, create the following environment variables to be loaded by the rack server of choice.

    export GOOGLE_KEY=
    export GOOGLE_SECRET=
    export GITHUB_KEY=
    export GITHUB_SECRET=

### Routes

The following routes are added:

* get '/auth/:provider/disable', to: 'users#disable_provider'
* post '/auth/:provider/callback', to: 'sessions#create'
* get '/auth/:provider/callback', to: 'sessions#create'
* get '/auth/failure', to: 'sessions#failure'
* get '/login', to: 'sessions#new'
* get '/logout', to: 'sessions#destroy'
* resources :users
* resources :sessions
* resources :memberships

### Included Helpers/Filters

Take a look at <code>app/controllers/concerns/app_helpers.rb</code> for a full list and implementation of available helper methods

* current_user - returns current user if they are signed in.
* signed_in? - returns boolean if a user is signed in
* login_required! - used with before\_filter to check that a user is signed in to access to current controller
* membership_require! - used with before\_filter to make sure a signed in user is has been added as a member
* redirect\_back\_or\_default

### Testing

If everything has been configured correctly you should be able to point your browser at <code>http://localhost:<port>/auth/gina</code> and attempt to login using the GINA::ID provider.

### Additional things to do

* Add the necessary views and controller methods to manage user memberships
* Setup an endpoint to handle user preferences/settings (resource :preferences, controller: 'users')
* Add some views to handle authentication failures (Sessions#failure)
* Provide a method for users to choose their desired login method (GINA, Google, Github, etc...)
* Permission handling, this is usually best handled by adding to the membership model

### Pow configuration info

If you are using pow create a .powenv file in the rails root directory and then <code>touch tmp/restart.txt</code>.  Be sure to add the .powenv to your .gitignore to prevent your key/secret information from being exposed to other users.

## Cookbook Instructions

You will need to have <code>test-kitchen, berkshelf and vagrant</code> installed and running in order to use the automatic cookbook creation template.  The default recipes will create a system with nginx, ruby, bundler and unicorn to host an application.

It will create a new folder called &lt;APP_NAME&gt;-cookbook in the current directory with all of the receipes and template files for starting a vm

### Starting the VM

Just run the following command to start the vm

    cd <APP_NAME>-cookbook
    kitchen converge centos

Once that has completed successfully you can login using

    kitchen login centos

After confirming the VM starts and is configured correctly upload to chef using

    berks upload