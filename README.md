# GINA Rails Template

This is the start of a basic rails template.

By default it will add the following gems, along with authentication stuff described later on

* haml          - simple view syntax
* bower-tools   - some default configs to let bower work with rails easier.

##Authentication Configuration

This template will ask if you wish to add authentication support, this will add necessary omniauth gems to you Gemfile and create several controllers and models.

The following providers are supported

* http://id.gina.alaska.edu (openid)
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

The following routes are create:

* /auth/:provider     # examples: /auth/gina, auth/google or auth/github
* /auth/failure => sessions#failure
* resources :users
* resources :authorizations
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

