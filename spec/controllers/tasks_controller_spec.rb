require 'spec_helper'

describe TasksController do
  before(:each) do
    @user = FactoryGirl.create(:user_admin)
    @task_status = FactoryGirl.create(:task_status)
    sign_in @user
  end

  let(:valid_attributes) do
    {
      description: "MyText",
      task_status_id: @task_status.id,
      user_id: @user.id
    }
  end

  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all tasks as @tasks" do
      task = Task.create! valid_attributes
      get :index
      expect(assigns(:tasks)).to eq([task])
    end
  end

  describe "GET show" do
    it "assigns the requested task as @task" do
      task = Task.create! valid_attributes
      get :show, params: { id: task.to_param }
      expect(assigns(:task)).to eq(task)
    end
  end

  describe "GET new" do
    it "assigns a new task as @task" do
      get :new
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe "GET edit" do
    it "assigns the requested task as @task" do
      task = Task.create! valid_attributes
      get :edit, params: { id: task.to_param }
      expect(assigns(:task)).to eq(task)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Task" do
        expect do
          post :create, params: { task: valid_attributes }
        end.to change(Task, :count).by(1)
      end

      it "assigns a newly created task as @task" do
        post :create, params: { task: valid_attributes }
        expect(assigns(:task)).to be_a(Task)
        expect(assigns(:task)).to be_persisted
      end

      it "redirects to the created task" do
        post :create, params: { task: valid_attributes }
        expect(response).to redirect_to(Task.last)
      end
    end

    describe "with invalid params" do
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "assigns the requested task as @task" do
        task = Task.create! valid_attributes
        put :update, params: { id: task.to_param, task: valid_attributes }
        expect(assigns(:task)).to eq(task)
      end

      it "redirects to the task" do
        task = Task.create! valid_attributes
        put :update, params: { id: task.to_param, task: valid_attributes }
        expect(response).to redirect_to(task)
      end
    end

    describe "with invalid params" do
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested task" do
      task = Task.create! valid_attributes
      expect do
        delete :destroy, params: { id: task.to_param }
      end.to change(Task, :count).by(-1)
    end

    it "redirects to the tasks list" do
      task = Task.create! valid_attributes
      delete :destroy, params: { id: task.to_param }
      expect(response).to redirect_to(tasks_url)
    end
  end
end
