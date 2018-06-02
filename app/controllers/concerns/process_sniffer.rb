module ProcessSniffer
  extend ActiveSupport::Concern
  def sniff
    logger.info "----------------------------"
    logger.info "TimeZone = " + Rails.configuration.time_zone.to_s
    logger.info "BidDate = #{@tender.bid_date}"
    logger.info "PID = #{Process.pid}"
    logger.info "----------------------------"
  end
end
