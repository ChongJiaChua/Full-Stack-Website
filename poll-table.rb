class Poll < Sequel::Model
    
    def loadQA()
        @data = self.qa
        return @data
    end
end