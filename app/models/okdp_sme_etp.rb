# frozen_string_literal: true

class OkdpSmeEtp < ApplicationRecord

  validates :okdp_type, presence: true

  scope :okdp_search, (
    lambda do |term|
      select("id, code")
      .where("code like lower(?)", "%#{term}%")
      .order('okdp_type, code')
    end
  )

  def self.search(term)
    return OkdpSmeEtp.none if term.nil?
    select_fields = "id, code, okdp_type"
    select(select_fields)
      .from('okdp_sme_etps')
      .where("code like '%#{term}%'")
  end

end
