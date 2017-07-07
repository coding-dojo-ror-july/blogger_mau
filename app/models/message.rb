class Message < ActiveRecord::Base
  belongs_to :post
  
  # 3. require author and message for the messages. Require the message to be at least 15 characters long.
  validates :author, :message, presence: true
end
