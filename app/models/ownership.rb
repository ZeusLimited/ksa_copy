# frozen_string_literal: true

class Ownership < ApplicationRecord

  has_many :contractors

  validates :shortname, :fullname, presence: true

end
