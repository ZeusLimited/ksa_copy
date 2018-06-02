# frozen_string_literal: true

class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :role
  belongs_to :department

  delegate :position, :name, to: :role, prefix: true
end
