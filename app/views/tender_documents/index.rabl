object false
child @tender.link_tender_files.includes(:tender_file, :file_type) => :tender_files do
  extends('tender_documents/file_attributes', locals: { show_type: true })
end

child @tender.plan_lots_files.includes(:tender_file, :file_type) => :plan_lots_files do
  extends('tender_documents/file_attributes', locals: { show_type: true })
end

child @tender.bidders.includes(:contractor, bidder_files: :tender_file) => :bidders do
  attributes :id, :contractor_name_short

  child :bidder_files do
    extends('tender_documents/file_attributes', locals: { show_type: false })
  end
end

child @tender.basic_contracts.includes(contract_files: [:tender_file, :file_type]) => :contracts do
  attributes :id, :num, :confirm_date
  child :contract_files do
    extends('tender_documents/file_attributes', locals: { show_type: true })
  end
end
