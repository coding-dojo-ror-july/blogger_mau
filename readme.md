rails new blog_project
cd blog_project
touch readme.md

# Assignment: Blogs/Posts/Messages 1 of 2
Start a new project and create the models for the ERD below. 
This is an application that allows people to create blogs, write posts for each blog, and leave messages for a post.

Create the migration files as well as the models for the application above.

Implement the following validations:

require the presence of name and description for the blog.
require the presence of title and content for the posts, require the title to be at least 7 characters long.
require author and message for the messages. Require the message to be at least 15 characters long.
Using the console:

create 5 new blogs.
create several posts for each blog.
create several messages for the first post.
know how to retrieve all posts for the first blog.
know how to retrieve all posts for the last blog (sorted by title in the DESC order).
know how to update the first post's title.
know how to delete the third post (have the model automatically delete all messages associated with the third post when you delete the third post).
know how to retrieve all blogs.
know how to retrieve all blogs whose id is less than 5.

# Initial commands
rails new blogger
rails g model Blog name:string description:text
rails g model Post title:string content:text blog:references
rails g model Message message:text post:references
rake db:migrate

# Implement the following validations:
class Blog < ActiveRecord::Base
  has_many :posts

  # 1. require the presence of name and description for the blog.
  validates :name, :description, presence: true
end

class Post < ActiveRecord::Base
  has_many :messages
  belongs_to :blog

  # 2. require the presence of title and content for the posts, require the title to be at least 7 characters long.
  validates :content, presence: true
  validates :title, length: { minimum: 7 }
end

class Message < ActiveRecord::Base
  belongs_to :post
  
  # 3. require message for the messages. Require the message to be at least 15 characters long.
  validates :message, presence: true
end

# Using the console:

rails c

# 1. create 5 new blogs.
1.upto(5) { |i| Blog.create(name: "Blog #{i}", description: "This is the description for Blog #{i}") }

# 2. create several posts for each blog
Blog.all.each do |blog|
  3.times { blog.posts.create(title: "This is Post #{Post.maximum(:id).to_i + 1}", content: "This post belongs to Blog #{blog.id}") }
end

# 3. create several messages for the first post.
post = Post.first
names = ["John Doe", "Jane Doe", "Jennifer Doe", "Michael Smith", "Michelle Smith", "Mitchell Smite"]
names.each { |elem| post.messages.create(author: elem, message: "This message belongs to the first post") }

# 4. know how to retrieve all posts for the first blog.
Blog.first.posts

# 5. know how to retrieve all posts for the last blog (sorted by title in the DESC order).
Post.where(blog: Blog.last).order(title: :desc)

# 6. know how to update the first post's title.
Post.first.update(title: "Updating the title")

# 7. know how to delete the third post (have the model automatically delete all messages associated with the third post when you delete the third post).
class Post < ActiveRecord::Base
  has_many :messages, dependent: :destroy
  belongs_to :blog

  validates :content, presence: true
  validates :title, length: { minimum: 7 }
end

Post.third.destroy

# 8. know how to retrieve all blogs.
Blog.all

# 9. know how to retrieve all blogs whose id is less than 5.
Blog.where("id < ?", 5)

# Assignment: Blogs/Posts/Messages II
Our blog just got a little bit more complicated. 
We're going to make all of our blogs private and only allow certain users to access different blogs. 
We're also only going to allow the registered users to leave messages. 
Here is the new ERD.

Before doing this, please read: http://guides.rubyonrails.org/associationbasics.html#the-hasmany-through-association

CLARIFICATION: When you do these assignments, 
when we state that we want to get all the blogs by User 1, 
we're referring to all blogs who are owned by User 1 and NOT the blogs where User 1 wrote posts. 
This distinction is important.

Based on the new diagram:
Create appropriate models
Create appropriate validations 
(think about what fields you would need to require, what other validation rules you would need)
Using the console...

Create 5 users
 Create 5 blogs
 Have the first 3 blogs be owned by the first user
 Have the 4th blog you create be owned by the second user
 Have the 5th blog you create be owned by the last user
 Have the third user own all of the blogs that were created.
 Have the first user create 3 posts for the blog with an id of 2. 
 Remember that you shouldn't do Post.create(user: User.first, blog_id: 2) 
 but more like Post.create(user: User.first, blog: Blog.find(2)). 
 Again, you should never reference the foreign key in Rails.
 Have the second user create 5 posts for the last Blog.
 Have the 3rd user create several posts for different blogs.
 Have the 3rd user create 2 messages for the first post created 
 and 3 messages for the second post created
 Have the 4th user create 3 messages for the last post you created.
 Change the owner of the 2nd post to the last user.
 Change the 2nd post's content to be something else.
 Retrieve all blogs owned by the 3rd user (make this work by simply doing: User.find(3).blogs).
 Retrieve all posts that were created by the 3rd user
 Retrieve all messages left by the 3rd user
 Retrieve all posts associated with the blog id 5 as well as who left these posts.
 Retrieve all messages associated with the blog id 5 
 along with all the user information of those who left the messages
 Grab all user information of those that own the first blog 
 (make this work by allowing Blog.first.owners to work).
 Change it so that the first blog is no longer owned by the first user.

 # solution
rake db:drop

# Create appropriate models
rails g model User first_name:string last_name:string email:string
rails g model Blog name:string description:text
rails g model Owner user:references blog:references
rails g model Post title:string content:text user:references blog:references
rails g model Message message:text user:references post:references
rake db:migrate

# Create appropriate validations (think about what fields you would need to require, what other validation rules you would need)
# User Model
class User < ActiveRecord::Base
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
  has_many :owners
  has_many :messages
  has_many :posts
  # all the blogs owned by a specific user
  has_many :blogs, through: :owners

  # all the blogs a user has posted on
  has_many :blog_posts, through: :posts, source: :blog

  validates :email, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEX }
  validates :first_name, :last_name, :email, presence: true
end

# Owner Model
class Owner < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
end

# Blog Model
class Blog < ActiveRecord::Base
  has_many :owners
  has_many :posts

  # all the users that own a specifc blog
  has_many :users, through: :owners

  # all the users that posted on a specific blog
  has_many :user_posts, through: :posts, source: :user

  validates :name, :description, presence: true
end

# Post Model
class Post < ActiveRecord::Base
  has_many :messages
  belongs_to :blog
  belongs_to :user

  validates :content, :title, presence: true
end

# Message Model
class Message < ActiveRecord::Base
  belongs_to :post
  belongs_to :user

  validates :message, presence: true
end

# 1. Create 5 users
User.create(first_name: "John", last_name: "Doe", email: "john@doe.com")
User.create(first_name: "Jane", last_name: "Doe", email: "jane@doe.com")
User.create(first_name: "Jessica", last_name: "Doe", email: "jessica@doe.com")
User.create(first_name: "Michael", last_name: "Smith", email: "michael@smith.com")
User.create(first_name: "Michelle", last_name: "Smith", email: "michelle@smith.com")

# 2. Create 5 blogs
1.upto(5) { |i| Blog.create(name: "Blog #{i}", description: "This is blog ##{i}")}

# 3. Have the first 3 blogs be owned by the first user
Owner.create(user: User.first, blog: Blog.first)
Owner.create(user: User.first, blog: Blog.second)
Owner.create(user: User.first, blog: Blog.third)

# 4. Have the 4th blog you create be owned by the second user
Owner.create(user: User.second, blog: Blog.fourth)

# 5. Have the 5th blog you create be owned by the last user
Owner.create(user: User.last, blog: Blog.fifth)

# 6. Have the third user own all of the blogs that were created.
Blog.all.each { |blog| Owner.create(user: User.third, blog: blog) }

# 7. Have the first user create 3 posts for the blog with an id of 2.
1.upto(3) { |i| Post.create(title: "Post ##{i}", content: "This is the content for post ##{i}", user: User.first, blog: Blog.find(2)) }

# 8. Have the second user create 5 posts for the last Blog.
last_id = Post.maximum(:id) + 1
last_id.upto(last_id + 4) { |i| Post.create(title: "Post ##{i}", content: "This is the content for post ##{i}", user: User.second, blog: Blog.last) }

# 9. Have the 3rd user create several posts for different blogs.
Post.create(title: "Post ##{Post.maximum(:id) + 1}", content: "This is the content for post ##{Post.maximum(:id) + 1}", user: User.third, blog: Blog.third)
Post.create(title: "Post ##{Post.maximum(:id) + 1}", content: "This is the content for post ##{Post.maximum(:id) + 1}", user: User.third, blog: Blog.fourth)
Post.create(title: "Post ##{Post.maximum(:id) + 1}", content: "This is the content for post ##{Post.maximum(:id) + 1}", user: User.third, blog: Blog.fifth)

# 10. Have the 3rd user create 2 messages for the first post created and 3 messages for the second post created
Message.create(user: User.first, message: "My products are the best", post: Post.first)
Message.create(user: User.second, message: "No way!", post: Post.first)
Message.create(user: User.third, message: "Basketball is the best sport", post: Post.second)
Message.create(user: User.fourth, message: "We have the world cup. We are the best", post: Post.second)
Message.create(user: User.fifth, message: "We are the real football", post: Post.second)

# 11. Have the 4th user create 3 messages for the last post you created.
Message.create(user: User.fourth, message: "My book is the best", post: Post.last)
Message.create(user: User.fourth, message: "Your book is really good indeed", post: Post.last)
Message.create(user: User.fourth, message: "Agree!", post: Post.last)

# 12. Change the owner of the 2nd post to the last user.
Post.second.update(user: User.last)

# 13. Change the 2nd post's content to be something else.
Post.second.update(content: "Changing the content to something else")

# 14. Retrieve all blogs owned by the 3rd user (make this work by simply doing: User.find(3).blogs).
User.third.blogs

# 15. Retrieve all posts that were created by the 3rd user
User.third.posts

# 16. Retrieve all messages left by the 3rd user
User.third.messages

# 17. Retrieve all posts associated with the blog id 5 as well as who left these posts.    
Post.joins(:user, :blog).where("blogs.id = ?", 5).select("*")

# 18. Retrieve all messages associated with the blog id 5 along with all the user information of those who left the messages
In this problem, we need to do a subquery
Message.joins(:user).where(post: Blog.find(5).posts).select("*")

# 19. Grab all user information of those that own the first blog (make this work by allowing Blog.first.owners to work).
Blog.first.users

# 20. Change it so that the first blog is no longer owned by the first user.
Owner.where("id = ? AND user_id = ?", 1, 1,).update_all("user_id = 5")
