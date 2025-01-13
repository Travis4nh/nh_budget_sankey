require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'when there are simple linear transfers' do
    let!(:budget) { create(:budget, name: '1996 budget' ) }
    let!(:account1) { create(:account, name: '01 - General Fund', budget:) }
    let!(:account2) { create(:account, name: '02 - Gold Depository', budget:) }
    let!(:transfer12) { create(:transfer, source: account1, dest: account2, budget: ) }

    let!(:account3) { create(:account, name: '03 - Handcart', budget:) }
    let!(:transfer23) { create(:transfer, source: account2, dest: account3, budget: ) }

    let!(:account4) { create(:account, name: '04 - Wheels', budget:) }
    let!(:transfer34) { create(:transfer, source: account3, dest: account4, budget: ) }

    it 'relations work' do
      expect(account1.transfers_in).to eq([])
      expect(account1.transfers_out).to eq([transfer12])

      expect(account2.transfers_in).to eq([transfer12])
      expect(account2.transfers_out).to eq([transfer23])
    end

    it 'indirect relations work' do
      expect(account1.upstream_direct).to eq([])
      expect(account1.downstream_direct).to eq([account2])

      expect(account2.upstream_direct).to eq([account1])
      expect(account2.downstream_direct).to eq([account3])

      expect(account3.upstream_direct).to eq([account2])
      expect(account3.downstream_direct).to eq([account4])

      expect(account4.upstream_direct).to eq([account3])
      expect(account4.downstream_direct).to eq([])
    end

    it 'all_upstream_transfers() work' do
      expect(account1.all_upstream_transfers).to eq([])
      expect(account2.all_upstream_transfers).to eq([transfer12])
      expect(account3.all_upstream_transfers.to_set).to eq([transfer12, transfer23].to_set)
      expect(account4.all_upstream_transfers.to_set).to eq([transfer12, transfer23, transfer34].to_set)
    end

  end

  describe 'when there is one tier of many-to-one transfers' do
    let!(:budget) { create(:budget, name: '1996 budget' ) }
    
    let!(:account_left) { create(:account, name: 'left', budget:) }
    let!(:account_right) { create(:account, name: 'right', budget:) }
    let!(:account_bottom) { create(:account, name: 'bottom', budget:) }

    let!(:transfer_lb) { create(:transfer, source: account_left, dest: account_bottom, budget: ) }
    let!(:transfer_rb) { create(:transfer, source: account_right, dest: account_bottom, budget: ) }

    it 'relations work' do
      expect(account_left.transfers_in).to eq([])
      expect(account_right.transfers_in).to eq([])
      expect(account_bottom.transfers_in.to_set).to eq([transfer_lb, transfer_rb].to_set)
    end
    
    it 'all_upstream_transfers() work' do
      expect(account_left.all_upstream_transfers).to eq([])
      expect(account_right.all_upstream_transfers).to eq([])
      expect(account_bottom.all_upstream_transfers.to_set).to eq([transfer_lb, transfer_rb].to_set)
    end
  end

  describe 'when there are two tiers of many-to-one transfers' do
    let!(:budget) { create(:budget, name: '1996 budget' ) }
    
    let!(:account_left_left) { create(:account, name: 'left left', budget:) }
    let!(:account_left_right) { create(:account, name: 'left right', budget:) }
    let!(:account_left) { create(:account, name: 'left', budget:) }
    let!(:transfer_ll_l) { create(:transfer, source: account_left_left, dest: account_left, budget: ) }
    let!(:transfer_lr_l) { create(:transfer, source: account_left_right, dest: account_left, budget: ) }
    
    let!(:account_right_left) { create(:account, name: 'right left', budget:) }
    let!(:account_right_right) { create(:account, name: 'right right', budget:) }
    let!(:account_right) { create(:account, name: 'right', budget:) }
    let!(:transfer_rl_r) { create(:transfer, source: account_right_left, dest: account_right, budget: ) }
    let!(:transfer_rr_r) { create(:transfer, source: account_right_right, dest: account_right, budget: ) }

    let!(:account_bottom) { create(:account, name: 'bottom', budget:) }
    let!(:transfer_lb) { create(:transfer, source: account_left, dest: account_bottom, budget: ) }
    let!(:transfer_rb) { create(:transfer, source: account_right, dest: account_bottom, budget: ) }

    it 'relations work' do
      expect(account_left.transfers_in).to eq([])
      expect(account_right.transfers_in).to eq([])
      expect(account_bottom.transfers_in.to_set).to eq([transfer_lb, transfer_rb].to_set)
    end
    
    it 'all_upstream_transfers() work' do
      expect(account_left_left.all_upstream_transfers).to eq([])
      expect(account_left_right.all_upstream_transfers).to eq([])
      expect(account_left.all_upstream_transfers.to_set).to eq([transfer_ll_l, transfer_lr_l].to_set)

      expect(account_right_left.all_upstream_transfers).to eq([])
      expect(account_right_right.all_upstream_transfers).to eq([])
      expect(account_right.all_upstream_transfers.to_set).to eq([transfer_rl_r, transfer_rr_r].to_set)

      expect(account_bottom.all_upstream_transfers.to_set).to eq([transfer_ll_l, transfer_lr_l,
                                                                  transfer_rl_r, transfer_rr_r,
                                                                  transfer_lb, transfer_rb
                                                                 ].to_set)
    end
  end

  describe 'when there are two tiers of one-to-many transfers' do
    let!(:budget) { create(:budget, name: '1996 budget' ) }

    let!(:account_top) { create(:account, name: 'top', budget:) }
    let!(:account_left) { create(:account, name: 'left', budget:) }
    let!(:account_right) { create(:account, name: 'right', budget:) }

    let!(:transfer_tl) { create(:transfer, source: account_top, dest: account_left, budget: ) }
    let!(:transfer_tr) { create(:transfer, source: account_top, dest: account_right, budget: ) }

    let!(:account_left_left) { create(:account, name: 'left left', budget:) }
    let!(:account_left_right) { create(:account, name: 'left right', budget:) }
    let!(:transfer_l_ll) { create(:transfer, source: account_left, dest: account_left_left, budget: ) }
    let!(:transfer_l_lr) { create(:transfer, source: account_left, dest: account_left_right, budget: ) }


    let!(:account_right_left) { create(:account, name: 'right left', budget:) }
    let!(:account_right_right) { create(:account, name: 'right right', budget:) }
    let!(:transfer_r_rl) { create(:transfer, source: account_right, dest: account_right_left, budget: ) }
    let!(:transfer_r_rr) { create(:transfer, source: account_right, dest: account_right_right, budget: ) }


    
    it 'relations work' do
      expect(account_left.transfers_in).to eq([account_top])
      expect(account_right.transfers_in).to eq([account_top])
    end
    
    it 'all_downstream_transfers() work' do
      expect(account_left_left.all_downstream_transfers).to eq([])
      expect(account_left_right.all_downstream_transfers).to eq([])
      expect(account_left.all_downstream_transfers.to_set).to eq([transfer_l_ll, transfer_l_lr].to_set)

      expect(account_right_left.all_downstream_transfers).to eq([])
      expect(account_right_right.all_downstream_transfers).to eq([])
      expect(account_right.all_downstream_transfers.to_set).to eq([transfer_r_rl, transfer_r_rr].to_set)

      expect(account_top.all_downstream_transfers.to_set).to eq([transfer_l_ll, transfer_l_lr,
                                                                  transfer_r_rl, transfer_r_rr,
                                                                  transfer_tl, transfer_tr
                                                                 ].to_set)
    end
  end
  
  
end
