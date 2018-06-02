class DepartmentDecorator < Draper::Decorator
  delegate_all

  def shortname
    name || fullname
  end
end
