require 'spec_helper'

describe B2bClassifier do

  it 'validate presence of name' do
    record = build(:b2b_classifier)
    record.name = nil
    expect(record.valid?).to be_falsey
    expect(record.errors[:name]).to include("не может быть пустым")
  end

  it 'validate presence of classifier_id' do
    record = build(:b2b_classifier)
    record.classifier_id = nil
    expect(record.valid?).to be_falsey
    expect(record.errors[:classifier_id]).to include("не может быть пустым")
  end

  describe '.by_b2b_classifier_ids' do
    let(:faker_ids) do
      [
        Faker::Number.number(8).to_i,
        Faker::Number.number(8).to_i,
        Faker::Number.number(8).to_i
      ]
    end
    context 'when there are no matches' do
      it 'return empty result' do
        expect(B2bClassifier.by_b2b_classifier_ids(1)).to be_empty
      end
    end
    context 'when there are matches' do
      before(:example) do
        create(:b2b_classifier, classifier_id: faker_ids[0])
        create(:b2b_classifier, classifier_id: faker_ids[1])
        create(:b2b_classifier, classifier_id: faker_ids[2])
      end
      it 'return matches objects' do
        search_objects = [faker_ids[1], faker_ids[2]]
        search_result = B2bClassifier.by_b2b_classifier_ids(search_objects).pluck(:classifier_id)
        expect(search_result).to include(*search_objects)
        expect(search_result).not_to include(faker_ids[0])
      end
    end
  end

  describe '.search_by_name_or_id' do
    let(:faker_names) do
      [
        Faker::Lorem.sentence,
        Faker::Lorem.sentence,
        Faker::Lorem.sentence
      ]
    end
    let(:faker_ids) do
      [
        Faker::Number.number(8).to_i,
        Faker::Number.number(8).to_i,
        Faker::Number.number(8).to_i
      ]
    end

    context 'when there are no matches' do
      it 'return empty result' do
        expect(B2bClassifier.search_by_name_or_id('name')).to be_empty
      end
    end
    context 'when there are matches' do
      before(:example) do
        create(:b2b_classifier, name: faker_names[0], classifier_id: faker_ids[0])
        create(:b2b_classifier, name: faker_names[1], classifier_id: faker_ids[1])
        create(:b2b_classifier, name: faker_names[2], classifier_id: faker_ids[2])
      end

      it 'return matches objects' do
        search_object = faker_names[2]
        search_result = B2bClassifier.search_by_name_or_id(search_object).pluck(:name)
        expect(search_result).to include(search_object)
        expect(search_result).not_to include(faker_names[0], faker_names[1])
      end
      it 'сase insensitive and return matches objects' do
        search_object = faker_names[2]
        search_result = B2bClassifier.search_by_name_or_id(search_object.upcase).pluck(:name)
        expect(search_result).to include(search_object)
        expect(search_result).not_to include(faker_names[0], faker_names[1])
      end

      it 'return matches object when search by classifiers ids' do
        search_object = faker_names[2]
        search_result = B2bClassifier.search_by_name_or_id(faker_ids[2]).pluck(:name)
        expect(search_result).to include(search_object)
        expect(search_result).not_to include(faker_names[0], faker_names[1])
      end
    end
  end
end
