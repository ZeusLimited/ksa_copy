# frozen_string_literal: true

class OrderFile < ApplicationRecord
  has_paper_trail

  belongs_to :order
  belongs_to :tender_file
end
