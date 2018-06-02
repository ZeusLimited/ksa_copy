# frozen_string_literal: true

class ParamReport
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Conversion

  attr_accessor :current_user, :date_begin, :date_end, :date_gkpz_on_state,
                :gkpz_year, :gkpz_type, :customer, :organizer, :address_etp,
                :tender_type, :direction, :subject_type, :status, :show_status,
                :financing, :tender_type_exclude, :winners, :format

  def initialize(attributes = {}, current_user)
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    @current_user = current_user
  end

  def persisted?
    false
  end
end
