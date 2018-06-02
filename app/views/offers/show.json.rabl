object @offer
attributes *Offer.column_names
child(:offer_specifications) do
  attributes *OfferSpecification.column_names
end
