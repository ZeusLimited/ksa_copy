# frozen_string_literal: true

class ContractDecorator < Draper::Decorator
  delegate_all

  def show_template
    :show #TODO Выпилить
  end

  def edit_template
    :edit #TODO Выпилить
  end
end
