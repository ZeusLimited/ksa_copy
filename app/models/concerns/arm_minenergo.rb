module ArmMinenergo
  extend ActiveSupport::Concern
  include Constants

  class_methods do
    def to_arm_thousand(val)
      return 0 if val.nil?
      (val.to_f / 1000.0).round(3)
    end
  end

  private

  def default_value(type)
    [:float, :integer].include?(type) ? 0 : nil
  end

  def reject_special_symbols(element)
    element.to_s.gsub(/[:=()]/, ':' => ' ', '=' => ' ', '(' => '[', ')' => ']')
  end

  def add_line(index, elements)
    "(#{index}):::::::#{elements}:"
  end

  def get_additional_info(par1, par2)
    "#{par1}:#{par2}::::0:0:0:0:::::0::0:::0:0::0::0:0:0:0:0:0:0::0:0:0:0:::0:::::::::"
  end

  def get_user_info(user_id)
    return unless user_id.present?
    u = User.find user_id
    [u.fio_full, u.user_job, reject_special_symbols(u.phone), u.email, nil].join(':')
  end
end
