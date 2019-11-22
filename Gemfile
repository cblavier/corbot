source 'https://rubygems.org' do
  ruby '2.6.3'
  
  gem 'sinatra'

  group :production do
    gem "puma"
  end

  group :development do
    gem 'sinatra-contrib'
  end

  group :test do
    gem 'rack-test'
    gem 'rspec'
    gem 'vcr'
  end
end