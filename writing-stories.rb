class Story < Sequel::Model

    def self.paywall(text, length)
        words = text.split
        truncated_text = words.take(length).join(' ')
        truncated_text += '...' if words.length > length
        truncated_text
      end
end

