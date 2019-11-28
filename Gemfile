source 'https://rubygems.org' do
  ruby '2.6.3'
  
  gem 'puma'
  gem 'sinatra'
  gem 'sinatra-contrib'
  gem 'sinatra-activerecord'
  gem 'activerecord'
  gem 'pg'
  gem 'jbuilder'
  gem 'rake'

  group :development do
    gem 'rubocop', require: false
  end

  group :test do
    gem 'rack-test'
    gem 'rspec'
    gem 'vcr'
    gem 'webmock'
    gem 'database_cleaner'
    gem 'simplecov', require: false
    gem 'simplecov-console', require: false
  end
end