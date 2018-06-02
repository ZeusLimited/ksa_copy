# frozen_string_literal: true

class InvestProjectName < ApplicationRecord
  belongs_to :department

  scope :filter, (lambda do |term, dep_id|
    select('id, name, aqua_id')
      .where(department_id: Department.find(dep_id).root_id)
      .where('lower(name) like lower(?)', "%#{term}%")
      .order(updated_at: :desc)
  end)

  def fullname
    "#{name} (#{aqua_id})"
  end
end
