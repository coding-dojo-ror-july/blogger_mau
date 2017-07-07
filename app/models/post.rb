class Post < ActiveRecord::Base
  belongs_to :blog
  has_many :messages

  # 2. require the presence of title and content for the posts, require the title to be at least 7 characters long.
  validates :content, presence: true
  validates :title, length: { minimum: 7 }
end
