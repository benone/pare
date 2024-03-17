require 'json'
require 'fileutils'
require './cookies'

class Book
  attr_accessor :slug, :id, :chapters

  def initialize(slug)
    FileUtils.mkdir_p("data/#{slug}")
    @slug = slug
    @id = nil
    @chapters = []
  end

  def cache_dir
    "data/#{slug}"
  end

  def cache_path
    "#{cache_dir}/book.json"
  end

  def get_cached_data
    JSON.parse(File.read(cache_path))
  end

  def logger
    @logger ||= Logger.new("info.log")
  end

  def get_data!
    return get_cached_data if File.exist?(cache_path)
    # -x #{PM.available_proxy.to_s} \
    request = <<-EOF
      curl 'https://www.blinkist.com/api/books/#{slug}/chapters' \
      -H 'authority: www.blinkist.com' \
      -H 'accept: application/json, */*' \
      -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8,ru;q=0.7' \
      -H 'cookie: #{COOKIE}' \
      -H 'referer: https://www.blinkist.com/en/nc/reader/12-rules-for-life-en' \
      -H 'user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36' \
      -H 'x-csrf-token: #{TOKEN}' \
      -H 'x-requested-with: XMLHttpRequest'
    EOF

    begin
      response = JSON.parse(`#{request} 2>/dev/null`)
    rescue
      puts request
      # raise
    end
    File.write(cache_path, JSON.pretty_generate(response))
    sleep SLEEP
    response
  end

  def get_full_data
    started_at = Time.now
    data = get_data!

    @id = data['book']['id'] rescue return
    # @chapters = data['chapters']

    data['chapters'].each do |chapter_data|
      chapter = Chapter.new(self, chapter_data['id'])
      data = chapter.get_data!
      puts data
      @chapters << chapter
    end
    logger.info("#{slug}; #{Time.now - started_at} sec; #{@chapters.size} chapters")
    data
    rescue Exception => e
      puts "Error with #{slug}"
      logger.error("#{slug}; #{e.message}")
  end

end
