class Account < ApplicationRecord
  belongs_to :budget

  has_many :transfers_out, class_name: "Transfer", foreign_key: "source_id"
  has_many :transfers_in, class_name: "Transfer", foreign_key: "dest_id"

  has_many :downstream_direct, class_name: "Account", through: :transfers_out, :source => "dest"

  has_many :upstream_direct, class_name: "Account", through: :transfers_in, :source => "source"

  def all_upstream_transfers(known_transfers = [])
    new_transfers = transfers_in.to_a - known_transfers
    new_transfers.map(&:source).each do |source|
      indirect = source.all_upstream_transfers(known_transfers)
      new_transfers += indirect
    end
    new_transfers
  end

  def all_downstream_transfers(known_transfers = [])
    new_transfers = transfers_out.to_a - known_transfers
    new_transfers.map(&:dest).each do |dest|
      indirect = dest.all_downstream_transfers(known_transfers)
      new_transfers += indirect
    end
    new_transfers
  end

  
end
