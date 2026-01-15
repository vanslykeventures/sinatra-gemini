# frozen_string_literal: true

require_relative "sinatra_gemini"

desc "Clear cached PDF text in Redis and warm cache from disk"
task :refresh_pdf_cache do
  SinatraGemini.new.refresh_pdf_cache!
  puts "PDF cache refreshed."
end
