module EtpAddressesConcern
  extend ActiveSupport::Concern
  include Constants

  def etp?
    EtpAddress::ETP.include?(etp_address_id)
  end

  def etp_b2b?
    etp_address_id == EtpAddress::B2B_ENERGO
  end
end
