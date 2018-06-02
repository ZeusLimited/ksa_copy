require 'nokogiri'
require 'csv'
require 'open-uri'

PAGE_URL_OKDP = "http://www.classifikators.ru"
ROOT_NODES_OKDP = "/okpd"

def get_nodes_okdp(link, csv, parent_code)
  url = PAGE_URL_OKDP + link
  puts "GET: #{url}"
  page = Nokogiri::HTML(open(url))

  page.css('table.table tr').each do |tr|
    td_code, td_name = tr.css('td')
    next unless td_code && td_name

    code = td_code.text
    link = td_name.at_css('a')
    name = td_name.child

    if link
      csv << [code, parent_code, name]
      get_nodes_okdp(link['href'], csv, code)
    end
  end
end


namespace :export_okdp do
  desc "Экспорт из инета в csv"
  task :csv => :environment do
    time_begin = Time.now
    CSV.open("./tmp/okpd2.csv", "wb") { |csv| get_nodes_okdp(ROOT_NODES_OKDP, csv, nil) }
    time_end = Time.now

    puts
    puts "it's done for #{time_end - time_begin} seconds."
  end
end
