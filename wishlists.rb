class Wishlist < Sequel::Model

  many_to_one :users, class: :User, key: :reader
  many_to_one :story, class: :Story, key: :stories_wishlist, on_delete: :cascade

  def self.retrieve_story(user_name) 
    return Story.join(:wishlists, stories_wishlist: :story_id)
            .where(reader: user_name)
            .select_map([:story_id , :title])
  end
end