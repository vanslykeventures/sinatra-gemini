# frozen_string_literal: true

module SinatraGeminiPromptBuilder
  private

  def build_prompt(task, text_brain, pdf_brain)
    <<~PROMPT
      Use the following data only.  Use no external knowledge, even things that may sound common or assumed.

      #{text_brain}
      #{pdf_brain}

      Only respond in regards to the 'task' statement.  No others.
      #{task}
      Organize your response in the format of \"The provided statement is true or false because of 'reason' \.  Always include and attribute to the referenced rule."
    PROMPT
  end
end
