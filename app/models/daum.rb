class Daum < ApplicationRecord
    has_many :memberships
    has_many :users, through: :memberships
    has_many :posts
    
    def is_member?(user)
        self.users.include?(user)
    end
    
end
