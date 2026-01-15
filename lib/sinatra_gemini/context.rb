# frozen_string_literal: true

module SinatraGeminiContext
  private

  def extract_context(task)
    {
      season: extract_field(task, "Season"),
      sport: extract_field(task, "Sport"),
      age_range: normalize_age_range(extract_field(task, "Age Range")),
      teeball_level: normalize_teeball_level(extract_field(task, "Tee Ball Level")),
      question: extract_field(task, "Question")
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

    num = direct[0].gsub(/[^0-9]/, "")
    "U#{num}"
  end

  def normalize_teeball_level(value)
    return nil if value.nil? || value.empty?

    return "II" if value.match?(/2|ii/i)
    return "I" if value.match?(/1|i/i)

    nil
  end
end
