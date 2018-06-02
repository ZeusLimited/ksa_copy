module BusinessTime
  module TimeExtensions
    module ClassMethods
      def workday?(day)
        Date.new(2014, 12, 27) == day.to_date ||
          (Time.weekday?(day) && !BusinessTime::Config.holidays.include?(day.to_date))
      end
    end
  end
end
