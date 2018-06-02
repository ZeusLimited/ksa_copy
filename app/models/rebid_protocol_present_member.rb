# frozen_string_literal: true

class RebidProtocolPresentMember < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :status, class_name: 'Dictionary', foreign_key: 'status_id'
  belongs_to :rebid_protocol

  delegate :name, to: :status, prefix: true
  delegate :fio_full, to: :user, prefix: true

  attr_accessor :enable, :hide
end
