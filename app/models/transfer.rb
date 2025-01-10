class Transfer < ApplicationRecord
  belongs_to :from, class_name: "Cat"
  belongs_to :to, class_name: "Cat"
end
