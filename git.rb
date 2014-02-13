git :init

run "rm README.rdoc"
run "touch README.md .gitignore"
run "echo 'TODO add readme content' > README.md"
run "cp config/database.yml config/database.yml.example"

append_to_file ".gitignore" do
  <<-END
/config/database.yml
END
end

git :add => ".", :commit => "-m 'initial commit'"