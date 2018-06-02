class UnfairContractorDecorator < Draper::Decorator
  delegate_all

  SCOPE_LOCAL = [:unfair_contractor_decorator]

  def inn_ogrn
    I18n.t('inn_ogrn', scope: SCOPE_LOCAL, contractor_inn: contractor_inn, contractor_ogrn: contractor_ogrn)
  end

end
