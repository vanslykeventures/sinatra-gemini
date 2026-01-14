# frozen_string_literal: true
require 'sinatra'
require 'gemini-ai'
require 'pdf-reader'
require "dotenv/load"

class SinatraGemini
  def run(task)
    context = extract_context(task)

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
      PDF::Reader.open(file) do |reader|
        reader.pages.each { |page| pdf_brain += page.text }
      end
    end

    prompt = <<~PROMPT
      Use the following data only.  Use no external knowledge, even things that may sound common or assumed. 
      
      #{text_brain}
      #{pdf_brain}
      
      
      Only respond in regards to the 'task' statement.  No others.
      #{task}
      Organize your response in the format of \"The provided statement is true or false because of 'reason' \"
    PROMPT

    response = gemini.generate_content(
      { contents: { role: 'user', parts: { text: prompt } } }
    )

    response.dig("candidates", 0, "content", "parts", 0, "text")
  end

  private

  def extract_context(task)
    {
      season: extract_field(task, 'Season'),
      sport: extract_field(task, 'Sport'),
      age_range: normalize_age_range(extract_field(task, 'Age Range')),
      teeball_level: normalize_teeball_level(extract_field(task, 'Tee Ball Level')),
      question: extract_field(task, 'Question')
    }.merge(raw_task: task)
  end

  def extract_field(task, label)
    match = task.match(/#{Regexp.escape(label)}:\s*([^,]+)/i)
    match ? match[1].strip : nil
  end

  def normalize_age_range(value)
    return nil if value.nil? || value.empty?

    direct = value.match(/u?\d{1,2}/i)
    return nil unless direct

    num = direct[0].gsub(/[^0-9]/, '')
    "U#{num}"
  end

  def normalize_teeball_level(value)
    return nil if value.nil? || value.empty?

    return 'II' if value.match?(/2|ii/i)
    return 'I' if value.match?(/1|i/i)

    nil
  end

  def select_pdf_files(context)
    season = normalize_season(context[:season])
    sport = normalize_sport(context[:sport])
    age_range = context[:age_range]
    teeball_level = context[:teeball_level]
    question = context[:question].to_s

    files = []
    files.concat(Dir.glob('files/*.pdf'))

    if season
      season_scope = "files/#{season}"
      files.concat(Dir.glob("#{season_scope}/*.pdf"))
      if sport
        files.concat(Dir.glob("#{season_scope}/#{sport}/**/*.pdf"))
      else
        files.concat(Dir.glob("#{season_scope}/**/*.pdf"))
      end
    else
      files.concat(Dir.glob('files/*/**/*.pdf'))
    end

    files = files.uniq

    if age_range
      files = files.select do |file|
        file.match?(/#{Regexp.escape(age_range)}/i) || all_league_rules?(file)
      end
    end

    if sport == 'Teeball' && teeball_level
      files = files.select do |file|
        file.match?(/Tee-?Ball-?#{Regexp.escape(teeball_level)}/i) || !file.match?(/Tee-?Ball/i)
      end
    end

    files.concat(always_include_pdfs)
    files.concat(season_all_league_rules(season))
    files.uniq
  end

  def normalize_season(value)
    return nil if value.nil? || value.empty?

    value.to_s.strip.capitalize
  end

  def normalize_sport(value)
    return nil if value.nil? || value.empty?

    normalized = value.to_s.strip.downcase
    return 'Teeball' if normalized.include?('tee')
    return 'Softball' if normalized.include?('soft')
    return 'Baseball' if normalized.include?('base')

    nil
  end

  def always_include_pdfs
    [
      'files/Weather-Policy-rev-Feb-2023.pdf',
      'files/TieBreakerS2013.pdf'
    ]
  end

  def season_all_league_rules(season)
    return [] unless season

    Dir.glob("files/#{season}/*ALL-LEAGUE-RULES*.pdf")
  end

  def all_league_rules?(file)
    file.match?(/ALL-LEAGUE-RULES/i)
  end

end
