class Account < ApplicationRecord
  belongs_to :budget

  has_many :transfers_out, class_name: "Transfer", foreign_key: "source_id"
  has_many :transfers_in, class_name: "Transfer", foreign_key: "dest_id"

  has_many :downstream_direct, class_name: "Account", through: :transfers_out, :source => "dest"

  has_many :upstream_direct, class_name: "Account", through: :transfers_in, :source => "source"

end
