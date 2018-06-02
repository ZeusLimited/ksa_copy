# frozen_string_literal: true

class PageFile < ApplicationRecord
  belongs_to :page

  mount_uploader :wikifile, WikifileUploader
end
