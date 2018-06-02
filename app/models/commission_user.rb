# frozen_string_literal: true

class CommissionUser < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :assoc_status, class_name: "Dictionary", foreign_key: "status"
  belongs_to :commission

  validates :status, :user_name, presence: true
  scope :clerks, -> { where(status: Constants::Commissioners::CLERK) }
  scope :boss, -> { where(status: Constants::Commissioners::BOSS) }


  def user_name
    user.try(:fio_full)
  end

  def user_name=(name)
    # do nothing
  end

  def status_name
    assoc_status.try(:name)
  end

  def status_name=(name)
    # do nothing
  end
end
