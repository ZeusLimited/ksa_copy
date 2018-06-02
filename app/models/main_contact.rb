# frozen_string_literal: true

class MainContact < ApplicationRecord

  belongs_to :user

  validates :role, :position, :user_id, presence: true
  validates :position, numericality: { only_integer: true }

  def roles
    [
      [I18n.t('main_contacts.organizer'), 'organizer'],
      [I18n.t('main_contacts.developer'), 'developer']
    ]
  end
end
