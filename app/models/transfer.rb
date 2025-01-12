class Transfer < ApplicationRecord
  belongs_to :budget
  belongs_to :source, class_name: "Account"
  belongs_to :dest, class_name: "Account"
end
