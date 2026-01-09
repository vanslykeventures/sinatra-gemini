require 'sinatra'
require "dotenv/load"
require_relative 'sinatra_gemini'

get '/' do
  File.read(File.join(__dir__, 'views', 'get.html'))
end

post '/submit' do
  season = params[:season]
  sport = params[:sport]
  age_range = params[:age_range]
  teeball_level = params[:teeball_level]
  question = params[:question]
  task = if season && sport && (age_range || teeball_level || question)
           parts = ["Season: #{season}", "Sport: #{sport}"]
           parts << "Age Range: #{age_range}" if age_range && !age_range.empty?
           parts << "Tee Ball Level: #{teeball_level}" if teeball_level && !teeball_level.empty?
           parts << "Question: #{question}" if question && !question.empty?
           parts.join(", ")
         else
           params[:message]
         end
  response = SinatraGemini.new.run(task)

  return "#{response}"
end

# TODO: #
# show result on main page
# cleanup formatting
# add rule pdfs/txt
# parse and cleanup the response
# cleanup the prompt so that it doesn't mention all of the irrelevant data
