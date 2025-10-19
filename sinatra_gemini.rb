# frozen_string_literal: true
require 'sinatra'
require 'gemini-ai'
require 'pdf-reader'
require "dotenv/load"

class SinatraGemini
  def run(payload)
    task = payload[:task]
    prompt = <<~PROMPT
      Use the following data only.  Use no external knowledge, even things that may sound common or assumed. 
      
      #{pdf_brain(payload)}
      
      Only respond in regards to the 'task' statement.  No others.
      #{task}
      Organize your response in the format of \"The provided statement is true or false because of 'reason' \".  Cite which rule is the reason whenever possible.
    PROMPT

    response = gemini.generate_content(
      { contents: { role: 'user', parts: { text: prompt } } }
    )

    response_text = response.dig("candidates", 0, "content", "parts", 0, "text")
    {
      question: task,
      response_text:
    }
  end

  private

  def gemini
    Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GEMINI_API_KEY'],
        region: 'us-central1'
      },
      options: {
        model: 'gemini-2.5-flash'
      }
    )
  end

  def pdf_brain(payload)
    season = payload[:season]
    sport = payload[:sport]
    age = payload[:age]

    season_all_files = Dir.glob("files/#{season}/all/*.pdf")
    season_sport_files = Dir.glob("files/#{season}/#{sport}/*.pdf").select {|filename| filename.include?(age) }

    pdf_files = both_seasons_brain + season_all_files + season_sport_files
    pdf_brain = ''

    pdf_files.each do |file|
      PDF::Reader.open(file) do |reader|
        reader.pages.each { |page| pdf_brain += page.text }
      end
    end

    pdf_brain
  end

  def both_seasons_brain
    Dir.glob('files/both/*.pdf')
  end
end