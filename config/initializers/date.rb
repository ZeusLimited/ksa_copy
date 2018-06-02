class Date
  def workday?
    Date.new(2014, 12, 27) == self || (weekday? && !BusinessTime::Config.holidays.include?(self))
  end
end
