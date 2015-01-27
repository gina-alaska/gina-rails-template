gem "bower-rails"

after_bundle do
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
end
