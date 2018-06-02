@selectFiasAddress = (suggestions) ->
  $('#contractor_oktmo').val(suggestions.data.oktmo)
  $(this).val(fiasFullname(suggestions.data))
  setFiasId($(this).closest('fieldset.fias'), fiasParams(suggestions.data))

setFiasId = (fieldset, params) ->
  $.post '/fias', params, (data) ->
    fieldset.find("input:hidden[name$='fias_id]']").val(data.id)
    fieldset.find("input:hidden.address-id").val(data.aoid_hex)

fiasParams = (fias_dadata) ->
  fias:
    aoid_hex: fiasId(fias_dadata)
    houseid_hex: fias_dadata.house_fias_id
    name: fiasFullname(fias_dadata)
    postalcode: fias_dadata.postal_code
    regioncode: fias_dadata.region_kladr_id.substr(0, 2)
    okato: fias_dadata.okato
    oktmo: fias_dadata.oktmo

fiasId = (fias_dadata) ->
  fias_dadata.street_fias_id ||
    fias_dadata.settlement_fias_id ||
    fias_dadata.city_fias_id ||
    fias_dadata.area_fias_id ||
    fias_dadata.region_fias_id

fiasFullname = (fias_dadata) ->
  $.unique([fias_dadata.postal_code,
   fias_dadata.region_with_type,
   fias_dadata.area_with_type,
   fias_dadata.city_with_type,
   fias_dadata.settlement_with_type,
   fias_dadata.street_with_type,
   fias_dadata.house && (fias_dadata.house_type + " " + fias_dadata.house),
   fias_dadata.block && (fias_dadata.block_type + " " + fias_dadata.block),
   fias_dadata.flat && (fias_dadata.flat_type + " " + fias_dadata.flat)
  ].filter((val) -> val != null)).join(', ')
