text_record = DNSSD::TextRecord.new
DNSSD.register("On the Spot", "_http._tcp", "local", 3000, text_record.encode) do |reply|
  Rails.logger.info "Announcing On the Spot on Bonjour..."
end