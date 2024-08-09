class CensoredWords < Sequel::Model

  def self.censor_text(text)
    censored_words = CensoredWords.all.map(&:word)

    censored_words.each do |word|
      text.gsub!(word, "*" * word.length)
    end
  end
  
end