require 'fileutils'
require 'tempfile'
require 'rscribd'

date = Time.new

today = date.strftime("%m-%d-%Y")

final_output_file_name = "Danik-Bhaskar-Jaipur-#{today}"

output_path = File.join(Dir.tmpdir, Dir.mktmpdir, final_output_file_name)

FileUtils.mkdir_p(output_path)
FileUtils.cd(output_path)

base_url = "http://digitalimages.bhaskar.com/epaperpdf/#{date.strftime("%d%m%Y")}"

pages = (1..24)

city_bhaskar_pages = (25..28)

file_number = (date - 86400).strftime("%d").to_i

pages.each do |page|
  system "wget --output-document #{page}.pdf #{base_url}/#{file_number}JAIPURCITY-PG#{page}-0.PDF || rm #{page}.pdf"
end

city_bhaskar_pages.each do |page|
  page_to_fetch = page - 24
  system "wget --output-document #{page}.pdf #{base_url}/#{file_number}CBHASKAR-PG#{page_to_fetch}-0.PDF || rm #{page}.pdf"
end

files_to_combine = Dir.glob('**/*.pdf').sort_by{ |f| File.ctime(f) }

p FileUtils.pwd

system "pdftk #{files_to_combine.join(' ')} output #{final_output_file_name}.pdf"

Scribd::API.instance.key = ENV['SCRIBD_KEY']
Scribd::API.instance.secret = ENV['SCRIBD_SECRET']

Scribd::User.login ENV['SCRIBD_USERNAME'], ENV['SCRIBD_PASSWORD']

Scribd::Document.upload(:file => "#{final_output_file_name}.pdf")

