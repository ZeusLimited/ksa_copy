# frozen_string_literal: true

class Page < ApplicationRecord
  validates :permalink, presence: true

  has_many :page_files

  def to_param
    permalink
  end
end
