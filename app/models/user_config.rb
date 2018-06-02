# frozen_string_literal: true

class UserConfig < ApplicationRecord
  belongs_to :user
  validates :subscribe_send_time, presence: true
end
