# encoding: UTF-8
# frozen_string_literal: true

describe Member do
  let(:member) { build(:member, :level_3) }
  subject { member }

  describe '.from_payload' do
    let(:payload) { { email: 'race@example.com', uid: 'ID0123456789', role: 'member', state: 'active', level: 2 } }

    it 'creates a new member' do
      expect { Member.from_payload(payload) }.to change(Member, :count).by(1)
    end

    context 'when a parallel first request created the member in between' do
      let!(:existing) { create(:member, email: payload[:email], uid: payload[:uid], level: 1) }

      it 'uses the existing member when the loser got an unsaved record' do
        Member.stubs(:find_or_create_by).returns(Member.new(payload))
        member = Member.from_payload(payload)
        expect(member.id).to eq existing.id
        expect(member.reload.level).to eq 2
      end

      it 'uses the existing member when the unique index raised' do
        Member.stubs(:find_or_create_by).raises(ActiveRecord::RecordNotUnique)
        expect(Member.from_payload(payload).id).to eq existing.id
      end
    end

    it 'still rejects an email taken by another uid' do
      create(:member, email: payload[:email])
      expect { Member.from_payload(payload) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'uid' do
    subject(:member) { create(:member, :level_3) }
    it do
      expect(member.uid).to_not be_nil
      expect(member.uid).to_not be_empty
      expect(member.uid).to match(/\AID[A-Z0-9]{10}$/)
    end
  end

  describe 'username' do
    subject(:member) { create(:member, username: 'foobar') }
    it do
      expect(member.username).to_not be_nil
      expect(member.username).to_not be_empty
      expect(member.username).to eq 'foobar'
    end
  end

  describe 'before_create' do
    it 'should unify email' do
      create(:member, email: 'foo@example.com')
      expect(build(:member, email: 'Foo@example.com')).to_not be_valid
    end

    it 'doesnt creates accounts for the member' do
      expect do
        member.save!
      end.not_to change(member.accounts, :count)
    end
  end

  describe '#trades' do
    subject { create(:member, :level_3) }

    it 'should find all trades belong to user' do
      ask = create(:order_ask, :btcusd, member: member)
      bid = create(:order_bid, :btcusd, member: member)
      t1 = create(:trade, :btcusd, maker_order: ask)
      t2 = create(:trade, :btcusd, taker_order: bid)
      expect(member.trades.order('id')).to eq [t1, t2]
    end
  end

end
