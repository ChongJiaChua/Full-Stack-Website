RSpec.describe CensoredWords do
  describe ".censor_text" do
    it "replace bad words with asterisk" do
      text = "fuck"
      described_class.censor_text(text)
      expect(text).to eq("****")
    end
  end
end