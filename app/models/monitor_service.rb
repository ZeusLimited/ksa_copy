# frozen_string_literal: true

class MonitorService < ApplicationRecord

  belongs_to :department
  validates :department_id, presence: true

  delegate :fullname, :inn, :kpp, to: :department, prefix: true, allow_nil: true

end
