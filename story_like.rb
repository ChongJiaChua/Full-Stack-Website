class StoryLike < Sequel::Model
    many_to_one :story_likes, class: :User,key: :liker_name
    many_to_one :story, class: :Story,key: :liked_story_id
      
  end
  