require 'json'
require 'fileutils'
require './cookies'

class Chapter
  attr_accessor :id, :book

  def initialize(book, id)
    @id = id
    @book = book
  end

  def cache_path
    "#{book.cache_dir}/#{id}.json"
  end

  def get_cached_data
    JSON.parse(File.read(cache_path))
  end

  def get_data!
    return get_cached_data if File.exist?(cache_path)
    # -x #{PM.available_proxy.to_s} \
    request = <<-EOF
      curl 'https://www.blinkist.com/api/books/#{book.id}/chapters/#{id}' \
      -H 'authority: www.blinkist.com' \
      -H 'accept: application/json, */*' \
      -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8,ru;q=0.7' \
      -H 'cookie: #{COOKIE}' \
      -H 'referer: https://www.blinkist.com/en/nc/reader/12-rules-for-life-en' \
      -H 'user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36' \
      -H 'x-csrf-token: #{TOKEN}' \
      -H 'x-requested-with: XMLHttpRequest'
    EOF
    # puts request
    begin
      response = JSON.parse(`#{request}`)
    rescue
      puts request
      book.logger.error("#{slug}; #{e.message}")
      # raise
    end
    File.write(cache_path, JSON.pretty_generate(response))
    sleep SLEEP
    response
  end

end
