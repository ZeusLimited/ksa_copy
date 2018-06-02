# frozen_string_literal: true

class BpState < ApplicationRecord

  has_many :plan_specifications

  def fullname
    "#{num} - #{name}"
  end

end
