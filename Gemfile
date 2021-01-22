source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2', '>= 6.0.2.2'
# Use postgres as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Stripe and header signature verifier
gem 'stripe'
gem 'sinatra'

# Square
gem 'square.rb'

# Translations
gem 'globalize', '~> 5.3.0'
gem 'globalize-accessors'

gem 'actionmailer'

# rails admin
# gem 'rails_admin', '~> 2.0'

gem 'rubocop'

# Caching
gem 'connection_pool'
gem 'actionpack-action_caching'
gem 'dalli'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

gem 'rest-client'

# faker is a requirement for our db seeds and many parts of our test process
group :development, :test, :staging do
    gem 'faker'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 4.0.0'
  gem 'faker'
  gem 'pry-byebug'
  gem 'dotenv-rails'
end

group :development, :staging do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'factory_bot_rails', '~> 4.0'
  gem 'shoulda-matchers', '~> 4.3'
  gem 'database_cleaner'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "annotate", "~> 3.1"

gem 'safe_attributes'

gem 'ulid'

# pagination gem
gem 'pagy', '~> 3.8'

# GCS gem
gem 'google-cloud-storage'

gem 'workos'
