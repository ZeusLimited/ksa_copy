# frozen_string_literal: true

class Contact < ApplicationRecord
  has_paper_trail

  # hex_fields :legal_aoid, :legal_houseid, :postal_aoid, :postal_houseid

  belongs_to :department
  belongs_to :legal_fias, class_name: 'Fias', foreign_key: :legal_fias_id
  belongs_to :postal_fias, class_name: 'Fias', foreign_key: :postal_fias_id
  has_many :tenders

  validates :web, :email, :phone, :fax, presence: true
  validates :legal_fias_name, :postal_fias_name, presence: { message: :not_exist }

  delegate :name, :okato, to: :legal_fias, prefix: true, allow_nil: true
  delegate :name, :okato, to: :postal_fias, prefix: true, allow_nil: true
end
