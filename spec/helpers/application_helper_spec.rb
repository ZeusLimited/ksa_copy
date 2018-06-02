require 'spec_helper'

describe ApplicationHelper do
  IE9 = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"

  describe "#if_browser_is_supported" do
    it "supported" do
      expect(helper.if_browser_is_supported { "test" }).to eq("test")
    end
  end

  describe "short_text" do
    it "text" do
      expect(short_text("abc")).to eq("abc")
    end

    it "abbr" do
      expect(short_text("abcdefghi", 5)).to eq(content_tag(:abbr, 'ab...', title: "abcdefghi"))
    end
  end

  describe '#next_sort_direction' do
    context 'when i pass asc to params' do
      it 'return desc' do
        expect(helper.send(:next_sort_direction, 'asc')).to eq('desc')
      end
    end
    context 'when i pass desc to params' do
      it 'return asc' do
        expect(helper.send(:next_sort_direction, 'desc')).to eq('asc')
      end
    end
  end

  describe '#sort_icon' do
    let(:params) do
      {
        sort_column: 'a',
        sort_direction: 'asc'
      }
    end
    context 'when current column not equal sort column' do
      it 'return empty string' do
        expect(helper.send(:sort_icon, 'b', params)).to eq('')
      end
    end
    context 'when current column equal sort column' do
      context 'and sort_direction equal asc' do
        it 'return icon-chevron-up' do
          expect(helper.send(:sort_icon, 'a', params)).to eq('icon-chevron-up')
        end
      end

      context 'and sort_direction equal desc' do
        it 'return icon-chevron-up' do
          params[:sort_direction] = 'desc'
          expect(helper.send(:sort_icon, 'a', params)).to eq('icon-chevron-down')
        end
      end
    end
  end

  describe '#rep_prd' do
    before(:all) { class ReportClass;end }

    let(:company_name) { Faker::Company.name }
    let(:path) { Faker::Lorem.characters(5) }
    let(:result_link) do
      <<-HTML
      <div class="alert alert-danger">
        <strong>Внимание!</strong>
        <span>Техническое задание к отчёту</span>
        <a href="/#{path}" target="_blank">скачать</a>
      </div>
      HTML
    end

    before(:example) do
      allow(helper).to receive(:legal_filename).and_return(path)
      allow(Setting).to receive(:company).and_return(company_name)
    end

    it 'return valid link' do
      expect(helper.rep_prd(ReportClass)).to eq(result_link)
    end

    context 'when company is set' do
      context 'and company is equal' do
        it 'return link' do
          expect(helper.rep_prd(ReportClass, company_name)).to eq(result_link)
        end
      end

      context 'and company is not equal' do
        it 'return nil' do
          expect(helper.rep_prd(ReportClass, Faker::Company.name)).to be_nil
        end
      end
    end
  end
end
