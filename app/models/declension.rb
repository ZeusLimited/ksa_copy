# frozen_string_literal: true

class Declension < ApplicationRecord
  has_paper_trail

  belongs_to :content, polymorphic: true
end
