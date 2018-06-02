require 'spec_helper'

describe User do
  let(:role) { create(:role) }
  let(:department) { create(:department) }
  let(:user1) { create(:user_user) }
  let(:user2) { create(:user_contractor_boss, assignments: [build(:assignment, department_id: department.id, role_id: role.id)]) }

  describe 'validate' do
    before { user.valid? }
    describe 'email' do
      subject { user.errors.messages[:email] }
      let(:user) { build(:user) }

      it { is_expected.to be_blank }

      context 'blank' do
        let(:user) { build(:user, email: nil) }

        it { is_expected.to include SpecError.message(:blank) }
      end

      context 'too long' do
        let(:user) { build(:user, email: Faker::Lorem.characters(256)) }

        it { is_expected.to include SpecError.message(:too_long, count: 255) }
      end

      context 'invalid' do
        let(:user) { build(:user, email: 'Borisova-TaA@yakutskenergo.ru>') }

        it { is_expected.to include SpecError.message(:invalid) }
      end
    end
  end

  describe "get current_users nil departments" do
    it "user call method with empty department in his role" do
      expect(user1.dept_root).to eq []
    end
    it "user call method without empty department in his role" do
      expect(user2.dept_root).to eq [department.id]
    end
  end

  describe "restrict admin role for non admins" do
    context "current_user is admin" do
      let(:user) { create(:user_admin) }
      it do
        expect(user.valid?).to eq(true)
        expect(user.errors.messages[:base]).to be_empty
      end
    end

    context "current_user is not admin" do
      let(:user) { create(:user_moderator) }
      it "don't allow to choose admin role" do
        user.assignments[0].role_id = Constants::Roles::ADMIN
        expect(user.valid?).to eq(false)
        expect(user.errors.messages[:base]).to include('Выбор роли администратора запрещен')
      end

      it 'can change anything else' do
        user.assignments[0].role_id = Constants::Roles::USER_BOSS
        expect(user.valid?).to eq(true)
        expect(user.errors.messages[:base]).to be_empty
      end
    end
  end

  describe "get emails contractor boss" do
    it "call method with empty department in his role" do
      expect(user1.contractor_boss_email).to eq []
    end
    it "user call method without empty department in his role" do
      expect(user2.contractor_boss_email).to eq []
    end
    it "2 users in one department and first user called method" do
      role_contractor_boss = create(:role, :contractor_boss)
      user3 = create(:user, assignments:
        [build(:assignment, department_id: department.id, role_id: role.id)])
      user4 = create(:user, assignments:
        [build(:assignment, department_id: department.id, role_id: role_contractor_boss.id)])
      expect(user3.contractor_boss_email).to eq [user4.email]
    end
  end
end
