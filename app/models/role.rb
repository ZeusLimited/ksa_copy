# frozen_string_literal: true

class Role < ApplicationRecord
  has_paper_trail

  has_many :assignments
  has_many :users, through: :assignments

  scope :without_admin, -> { where.not(id: Constants::Roles::ADMIN) }

  def fullname
    "#{name_ru} (#{name})"
  end
end
