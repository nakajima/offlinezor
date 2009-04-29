require 'rubygems'
require 'rack'
require 'sinatra/base'
require File.dirname(__FILE__) + '/lib/rack-appcache'

class Offlinezor < Sinatra::Default
  set :root, File.dirname(__FILE__)
  set :static, true
  set :public, File.join(root, 'public')

  use Rack::AppCache, :include => public, :manifest => '/manifest'

  get '/' do
    erb :index
  end

  get '/other' do
    erb :other
  end

  get '/purge-manifest' do
    @request.env['app-cache.manifest'] = nil
    redirect '/'
  end
end
