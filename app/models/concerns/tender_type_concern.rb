# frozen_string_literal: true

module TenderTypeConcern
  extend ActiveSupport::Concern
  include Constants

  def auction?
    TenderTypes::AUCTIONS.include?(tender_type_id)
  end

  def competitive_talk?
    !TenderTypes::NONCOMPETITIVE.include? tender_type_id
  end

  def frame?
    tender_type_id == TenderTypes::ORK || tender_type_id == TenderTypes::ZRK
  end

  def noncompetitive?
    TenderTypes::NONCOMPETITIVE.include? tender_type_id
  end

  def only_source?
    tender_type_id == TenderTypes::ONLY_SOURCE
  end

  def single_source?
    tender_type_id == TenderTypes::SINGLE_SOURCE
  end

  def ei?
    TenderTypes::EI.include?(tender_type_id)
  end

  def preselection?
    tender_type_id == TenderTypes::PO
  end

  def regulated?
    tender_type_id != TenderTypes::UNREGULATED
  end

  def tender?
    TenderTypes::TENDERS.include?(tender_type_id)
  end

  def unregulated?
    tender_type_id == TenderTypes::UNREGULATED
  end

  def zc?
    TenderTypes::ZC.include?(tender_type_id)
  end

  def zpp?
    tender_type_id == TenderTypes::ZPP
  end

  def zzc?
    tender_type_id == TenderTypes::ZZC
  end

  def simple?
    tender_type_id == TenderTypes::SIMPLE
  end

  def tender_type_etp?
    TenderTypes::ETP.include?(tender_type_id)
  end

  def tender_type_non_etp?
    TenderTypes::NON_ETP.include?(tender_type_id)
  end

  def tender_type_non_sme?
    Constants::TenderTypes::NON_SME.include?(tender_type_id)
  end
end
