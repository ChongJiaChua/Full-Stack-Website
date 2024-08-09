class Reading < Sequel::Model

  many_to_one :users, class: :User, key: :reader
  many_to_one :story, class: :Story, key: :stories_reading, on_delete: :cascade

  def self.retrieve_stories(user_name)
    return Story.join(:readings, stories_reading: :story_id)
                    .where(reader: user_name)
                    .select_map([:story_id , :title])
  end

  def self.top_readers
    group_and_count(:reader).order(Sequel.desc(:count)).all
  end
end