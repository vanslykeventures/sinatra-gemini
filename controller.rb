require 'sinatra'
require "dotenv/load"
require_relative 'sinatra_gemini'

get '/' do
  erb :index
end

post '/submit' do
  response = SinatraGemini.new.run(payload)

  return "#{response}"
end

private 

def payload
  {
    task: params[:message],
    season: params[:season],
    sport: params[:sport],
    age: true_age
  }
end

def true_age
  params[:season] == 'spring' ? params[:spring_age] : params[:fall_age]
end

# TODO: #
# show result on main page
# cleanup formatting
# add rule pdfs/txt
# parse and cleanup the response
# cleanup the prompt so that it doesn't mention all of the irrelevant data