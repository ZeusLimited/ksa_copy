# frozen_string_literal: true

class TenderRequest < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :contractor
  belongs_to :tender

  delegate :name_inn, to: :contractor, prefix: true, allow_nil: true

  validates :inbox_num, :outbox_num, length: { maximum: 30 }
  validates :request, presence: true
  validates :register_date, :inbox_num, :inbox_date, :contractor_text, :tender_id, presence: true

  set_date_columns :register_date, :inbox_date, :outbox_date if oracle_adapter?

  def user_name
    user_id ? user.fio_full : nil
  end

  def user_name=(val)
    # do nothing
  end

  def outbox
    res = []
    res << "№#{outbox_num}" if outbox_num
    res << "от #{outbox_date.strftime('%d.%m.%Y')}" if outbox_date
    res.join ' '
  end

  def inbox
    res = []
    res << "№#{inbox_num}" if inbox_num
    res << "от #{inbox_date.strftime('%d.%m.%Y')}" if inbox_date
    res.join ' '
  end
end
