# frozen_string_literal: true
require 'sinatra'
require 'gemini-ai'
require 'pdf-reader'
require 'redis'
require "dotenv/load"
require_relative 'lib/sinatra_gemini/context'
require_relative 'lib/sinatra_gemini/pdf_cache'
require_relative 'lib/sinatra_gemini/pdf_selector'
require_relative 'lib/sinatra_gemini/prompt_builder'

class SinatraGemini
  include SinatraGeminiContext
  include SinatraGeminiPdfCache
  include SinatraGeminiPdfSelector
  include SinatraGeminiPromptBuilder

  def refresh_pdf_cache!
    redis = redis_client
    clear_pdf_cache(redis)
    warm_pdf_cache(redis)
  end

  def run(task)
    context = extract_context(task)
    redis = redis_client

    gemini = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GEMINI_API_KEY'],
        region: 'us-central1'
      },
      options: {
        model: 'gemini-2.5-flash'
      }
    )

    text_files = Dir.glob('files/*.txt')
    text_brain = text_files.map { |file| File.read(file) }

    pdf_files = select_pdf_files(context)
    pdf_brain = ''
    pdf_files.each do |file|
      pdf_brain += fetch_pdf_text(file, redis)
    end

    prompt = build_prompt(task, text_brain, pdf_brain)

    response = gemini.generate_content(
      { contents: { role: 'user', parts: { text: prompt } } }
    )

    response.dig("candidates", 0, "content", "parts", 0, "text")
  end
end
