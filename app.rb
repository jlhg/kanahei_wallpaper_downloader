require "nokogiri"
require "open-uri"
require "pry"
require "concurrent"
require "fileutils"

base_url = "http://www.kanahei.com/kabegami/page"
pool = Concurrent::FixedThreadPool.new(5)
base_output_dir = "output"

(1..10).each do |i|
  doc = Nokogiri::HTML(open(File.join(base_url, i.to_s)))
  doc.css("a[href^='http://www.kanahei.com/upload']").each do |element|
    url = element.attr("href")
    m = url.match %r{http://www.kanahei.com/upload/(\d+)/(\d+)/(.+)(4x3|16x9|800_600|1280_1024|1920_1200|1600_1200|1024_768)(.jpg)}
    binding.pry if m.nil?
    file_name = "#{m[1]}_#{m[2]}_#{m[3]}#{m[4]}#{m[5]}"
    output_file_path = File.join(base_output_dir, m[4], file_name)
    FileUtils.mkdir_p File.join(base_output_dir, m[4])
    pool.post do
      `wget #{url} -O #{output_file_path}`
    end
  end
end

pool.shutdown
pool.wait_for_termination
