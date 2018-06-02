# frozen_string_literal: true

class CompoundDatetime
  attr_accessor :datetime

  def initialize(datetime)
    @datetime = datetime
  end

  # accepts hash like:
  #
  #     {
  #       'date' => '20.12.2012',
  #       'time' => '20:30'
  #     }
  def assign_attributes(hash)
    if hash[:date].present?
      @datetime = Time.zone.parse([hash[:date].presence, hash[:time].presence || ''].join(' '))
    end
    self
  end

  def date
    @datetime&.strftime('%d.%m.%Y')
  end

  def time
    @datetime&.strftime('%H:%M')
  end

  def persisted?
    false
  end
end
