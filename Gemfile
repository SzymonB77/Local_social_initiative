source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.7'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# ActiveModel::Serializers allows to generate JSON in an object-oriented and convention-driven manner.
gem 'active_model_serializers', '~> 0.10'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# Use JWT gem for token-based authentication
gem 'jwt'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Annotates Rails/ActiveRecord Models, routes, fixtures, and others based on the database schema.
gem 'annotate', '~> 3.2'

# Provides a clear syntax for writing and deploying cron jobs in a Rails application
gem 'whenever', '~> 1.0.0', require: false

gem 'faker'

# Great Ruby dubugging companion: pretty print Ruby objects to visualize their structure.
gem 'awesome_print', '~> 1.8'

# help to kill N+1 queries and unused eager loading.
gem 'bullet', '~> 6.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # RuboCop is a Ruby code style checking and code formatting tool.
  gem 'rubocop', '~> 1.18', require: false
  gem 'rubocop-performance', '~> 1.6.1', require: false
  gem 'rubocop-rails', '~> 2.5.2', require: false
  gem 'rubocop-rspec', '~> 2.4.0', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
