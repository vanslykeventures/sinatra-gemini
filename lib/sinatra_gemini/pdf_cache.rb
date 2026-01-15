# frozen_string_literal: true

module SinatraGeminiPdfCache
  private

  def redis_client
    Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
  end

  def fetch_pdf_text(file, redis)
    cache_key = pdf_cache_key(file)
    cached = redis.get(cache_key)
    return cached if cached

    text = +""
    PDF::Reader.open(file) do |reader|
      reader.pages.each { |page| text << page.text }
    end

    redis.set(cache_key, text)
    text
  end

  def warm_pdf_cache(redis)
    Dir.glob("files/**/*.pdf").each do |file|
      fetch_pdf_text(file, redis)
    end
  end

  def clear_pdf_cache(redis)
    cursor = "0"
    loop do
      cursor, keys = redis.scan(cursor, match: "sinatra_gemini:pdf:*", count: 500)
      redis.del(*keys) unless keys.empty?
      break if cursor == "0"
    end
  end

  def pdf_cache_key(file)
    mtime = File.mtime(file).to_i
    "sinatra_gemini:pdf:#{file}:#{mtime}"
  end
end
