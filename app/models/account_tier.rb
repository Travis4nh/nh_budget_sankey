class AccountTier < ApplicationRecord
  belongs_to :budget
  has_many :accounts
end
