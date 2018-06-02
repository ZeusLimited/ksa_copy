class AddViolationReasonToWinnerProtocol < ActiveRecord::Migration[5.1]
  include MigrationHelper
  def change
    add_column_with_comment :winner_protocols, :violation_reason, :string,
                            comment: 'Причины неисполнения срока подведения итогов'
  end
end
