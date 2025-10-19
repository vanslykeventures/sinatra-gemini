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
    age: age_code
  }
end

def age_code
  if params[:season] == 'spring'
    if params[:sport] == 'baseball'
      params[:spring_age_bb]
    elsif params[:sport] == 'softball'
      params[:spring_age_sb]
    else
      params[:spring_tb]
    end
  else
    if params[:sport] == 'baseball'
      params[:fall_age_bb]
    elsif params[:sport] == 'softball'
      params[:fall_age_sb]
    else
      params[:fall_tb]
    end
  end
end
