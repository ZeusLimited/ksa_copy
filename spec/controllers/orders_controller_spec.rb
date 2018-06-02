require 'spec_helper'

RSpec.describe OrdersController, type: :controller do
  let(:user) { create(:user_user) }

  before(:each) { sign_in(user) }

  let(:valid_attributes) do
    attributes_for(:order).merge(agreed_by_user_id: user.id)
  end

  let(:invalid_attributes) do
    attributes_for(:order).merge(num: nil)
  end

  let(:order_filter_params) do
    {
      year: 2016,
      department: 2
    }
  end

  let(:order) { create(:order) }

  let(:fake_order) { instance_double(Order) }

  describe "GET #index" do
    let(:fake_order_filter) { instance_double(OrderFilter) }
    before(:each) { allow(fake_order_filter).to receive_message_chain(:search, :order).and_return(fake_order) }
    before(:each) { allow(Kaminari).to receive_message_chain(:paginate_array, :page).and_return('fake_kaminary') }

    it 'creates new OrderFilter object' do
      params = { 'year' => '2016', 'department' => '2' }
      expect(OrderFilter).to receive(:new).with(params).and_return fake_order_filter
      get :index, params: { order_filter: params }
    end

    it 'assigns data to @orders' do
      allow(OrderFilter).to receive(:new).and_return(fake_order_filter)
      get :index, params: { order_filter: order_filter_params }
      expect(assigns(:orders)).to eq('fake_kaminary')
    end

    it 'render index template' do
      allow(OrderFilter).to receive(:new).and_return(fake_order_filter)
      get :index
      expect(response).to render_template('index')
    end
  end

  describe "GET #show" do
    it 'render template show' do
      allow(Order).to receive(:find)
      get :show, params: { id: order.id }
      expect(response).to render_template('show')
    end
  end

  describe "GET #new" do
    let(:plan_lot) { build(:plan_lot) }
    before(:each) do
      allow_any_instance_of(ApplicationController).to receive(:check_selected_plan_lots_before_order).and_return true
      allow(fake_order).to receive(:plan_lots=)
    end

    it 'creates new Order object' do
      expect(Order).to receive(:new).and_return order
      expect(order).to receive(:received_from_user_id=).with(user.id)
      expect(order).to receive(:agreed_by_user_id=).with(user.id)
      get :new
    end

    it 'renders template new' do
      allow(Order).to receive(:new).and_return order
      allow(order).to receive(:plan_lots=)
      get :new
      expect(response).to render_template('new')
    end

    it 'assigns current_user.plan_lots to @order.plan_lots' do
      user.plan_lots << plan_lot
      get :new
      expect(assigns(:order).plan_lots.last).to eq(plan_lot)
    end
  end

  describe "GET #edit" do
    it 'render template edit' do
      allow(order).to receive_message_chain(:agreed_by, :nil?).and_return(true)
      allow(order).to receive(:agreed_by_user_id=).with(user.id)
      allow(Order).to receive(:find).and_return(order)
      get :edit, params: { id: order.id }
      expect(response).to render_template('edit')
    end
  end

  describe "POST #create" do
    it 'assign new Order to @order' do
      allow(Order).to receive(:new).and_return fake_order
      allow(fake_order).to receive(:save_with_plan_lots).and_return true
      post :create, params: { order: valid_attributes }
      expect(assigns(:order)).to eq(fake_order)
    end

    context 'with valid attributes' do
      it 'success' do
        ord = build(:order, valid_attributes)
        allow(Order).to receive(:new).and_return(ord)
        allow(ord).to receive(:save_with_plan_lots).and_return true
        post :create, params: { order: valid_attributes }
        expect(flash[:notice]).to eq('Поручение успешно создано.')
      end
    end
    context 'with invalid attributes' do
      it 'render new template' do
        allow_any_instance_of(Order).to receive(:save_with_plan_lots).and_return false
        post :create, params: { order: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe "PATCH #update" do
    it 'assign new Order to @order' do
      allow(Order).to receive(:find).and_return order
      allow(order).to receive(:update).and_return true
      patch :update, params: { id: order.id, order: valid_attributes }
      expect(flash[:notice]).to eq("Поручение успешно обновлёно.")
    end

    context 'with valid attributes' do
      it 'redirect to show' do
        allow(Order).to receive(:find).and_return order
        allow(order).to receive(:update).and_return true
        patch :update, params: { id: order.id, order: valid_attributes }
        expect(response).to redirect_to(action: 'show')
      end
    end
    context 'with invalid attributes' do
      it 'render edit template' do
        allow(Order).to receive(:find).and_return order
        allow(order).to receive(:update).and_return false
        patch :update, params: { id: order.id, order: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe "DELETE #destroy" do
    it 'redirect index' do
      allow_any_instance_of(Order).to receive(:destroy).and_return true
      delete :destroy, params: { id: order.id }
      expect(response).to redirect_to(action: 'index')
    end

    context 'when destroy true' do
      it 'shows success message' do
        allow_any_instance_of(Order).to receive(:destroy).and_return true
        delete :destroy, params: { id: order.id }
        expect(flash[:notice]).to eq("Поручение успешно удалено.")
      end
    end

    context 'when destroy false' do
      it 'shows alert message' do
        allow_any_instance_of(Order).to receive(:destroy).and_return false
        delete :destroy, params: { id: order.id }
        expect(flash[:alert]).to match(/Поручение №.+ не может быть удалено./)
      end
    end
  end
end
