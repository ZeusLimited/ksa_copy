require 'csv'

class SimpleCompany
  include ActiveModel::Validations
  attr_accessor :inn
  validates :inn, inn_format: true
end

namespace :contractors do
  desc "validate csv contractors"
  task validate: :environment do
    file_in  = 'tmp/korr.csv'
    file_out = 'tmp/korr_valid.csv'

    CSV.open(file_out, 'wb', col_sep: ';') do |csv|
      csv << %w(inn valid)

      CSV.foreach(file_in) do |row|
        simple = SimpleCompany.new
        simple.inn = row[0]

        csv << [simple.inn, simple.valid?]
      end
    end
  end
end
