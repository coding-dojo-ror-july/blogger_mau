class Blog < ActiveRecord::Base
  has_many :posts

  # 1. require the presence of name and description for the blog.
  validates :name, :description, presence: true
end
