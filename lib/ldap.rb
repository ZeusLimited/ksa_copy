class Ldap
  def initialize
    @ldap ||= Net::LDAP.new(config_file)
  end

  def get_attributes(email, attributes)
    result = {}
    @ldap.search(base: config_file[:base], filter: filter(email), attributes: attributes, return_result: true) do |entry|
      entry.each do |attrib, value|
        next if attrib == :dn
        result[attrib] = value.first
      end
    end
    result
  end

  private

  def filter(email)
    Net::LDAP::Filter.eq("mail", email)
  end

  def config_file
    @config_file ||= YAML.load(ERB.new(File.new(File.join(Rails.root, 'config', 'ldap.yml')).read).result)
  end
end
