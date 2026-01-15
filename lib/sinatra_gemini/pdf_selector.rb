# frozen_string_literal: true

module SinatraGeminiPdfSelector
  private

  def select_pdf_files(context)
    season = normalize_season(context[:season])
    sport = normalize_sport(context[:sport])
    age_range = context[:age_range]
    teeball_level = context[:teeball_level]

    files = []
    files.concat(Dir.glob("files/*.pdf"))

    if season
      season_scope = "files/#{season}"
      files.concat(Dir.glob("#{season_scope}/*.pdf"))
      if sport
        files.concat(Dir.glob("#{season_scope}/#{sport}/**/*.pdf"))
      else
        files.concat(Dir.glob("#{season_scope}/**/*.pdf"))
      end
    else
      files.concat(Dir.glob("files/*/**/*.pdf"))
    end

    files = files.uniq

    if age_range
      files = files.select do |file|
        file.match?(/#{Regexp.escape(age_range)}/i) || all_league_rules?(file)
      end
    end

    if sport == "Teeball" && teeball_level
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
    return "Teeball" if normalized.include?("tee")
    return "Softball" if normalized.include?("soft")
    return "Baseball" if normalized.include?("base")

    nil
  end

  def always_include_pdfs
    [
      "files/Weather-Policy-rev-Feb-2023.pdf",
      "files/TieBreakerS2013.pdf"
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
