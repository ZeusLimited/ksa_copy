module UnfairContractorsHelper

  def unfair_contractor_html_attributes(contractor)
    return {} unless contractor.unfair?
    {
      class: 'unfair-color',
      data: { toggle: 'tooltip' },
      title: I18n.t(".unfair_contractors_helper.unfair_contractor")
    }
  end

end
