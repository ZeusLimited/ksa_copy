# frozen_string_literal: true

class Task < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :task_status

  scope :worked, -> { where(task_status_id: Constants::TaskStatuses::WORK) }

  validates :task_status_id, :task_status_id, presence: true

  def self.search(params)
    dics = order(:task_status_id, :priority)
    dics = dics.where(task_status_id: params[:status]) if params[:status].present?
    dics
  end
end
