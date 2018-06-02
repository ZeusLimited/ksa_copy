require 'nokogiri'
require 'csv'
require 'open-uri'

PAGE_URL_OKVED = "http://www.classifikators.ru"
ROOT_NODES_OKVED = "/okved"

def get_nodes_okved(link, csv, parent_code)
  url = URI.encode(PAGE_URL_OKVED + link)
  puts "GET: #{url}"
  page = Nokogiri::HTML(open(url))

  page.css('table.table tr').each do |tr|
    td_code, td_name = tr.css('td')
    next unless td_code && td_name

    code = td_code.text
    link = td_name.at_css('a')
    name = td_name.text
    link = link.child.to_s.match('\d+\.\d+') ? nil : link if link

    next if link && link['href'] == '/okved/'

    csv << [code, parent_code, td_name.child]

    get_nodes_okved(link['href'], csv, code) if link
  end
end


namespace :export_okved do
  desc "Экспорт из инета в csv"
  task :csv => :environment do
    time_begin = Time.now
    CSV.open("./tmp/okved2.csv", "wb") { |csv| get_nodes_okved(ROOT_NODES_OKVED, csv, nil) }
    time_end = Time.now

    puts
    puts "it's done for #{time_end - time_begin} seconds."
  end
end
