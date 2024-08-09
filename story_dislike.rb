class StoryDislike < Sequel::Model
    many_to_one :story_likes, class: :User,key: :disliker_name
    many_to_one :story, class: :Story,key: :disliked_story_id
  
  end