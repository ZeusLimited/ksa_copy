module GuidGenerate
  def guid_new
    ActiveRecord::Base.connection_config[:adapter] == 'oracle_enhanced' ? SecureRandom.random_bytes(16) : SecureRandom.uuid
  end
end
