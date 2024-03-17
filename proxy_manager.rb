require 'net/http'
require 'faraday'
class ProxyManager

  class Proxy
    attr_reader   :address
    attr_reader   :port
    attr_accessor :last_used

    def initialize(address, last_used=nil)
      @address,@port    = address.split(':')
      @last_used  = last_used
    end

    def used_since?(time)
      @last_used && @last_used > time
    end

    def to_s
      "http://#{@address}:#{@port}"
    end

    def get_address
      [@address,@port]
    end

    def conn
      Faraday.new(proxy: to_s, ssl: { verify: false })
    end

    def test
      begin
        if res = conn.get('https://poolcrm.ru/login') && res.status == 200
          true
        else
          false
        end
      rescue => e
        p e.message
        false
      end
    end
  end

  def self.from_proxy_file(path="proxies.txt", delay = 60)
    proxies = IO.readlines(path).map { |line| line.strip }

    new(proxies, delay)
  end

  def remove_fake
    @proxies.delete_if {|p| !p.test }
  end

  def self.from_url(url, delay = 60)
    proxies = Faraday.get(url).body.split.map(&:strip)
    new(proxies, delay)
  end

  def initialize(proxies, delay=60)
    raise ArgumentError, "proxies must contain at least 1 proxy" if proxies.empty?
    raise ArgumentError, "proxies must be unique, but duplicates were found: #{duplicates(proxies).join(', ')}" if proxies.size != proxies.uniq.size

    @addresses  = proxies
    @delay      = delay
    @proxies    = proxies.map { |address| Proxy.new(address) }
  end

  def duplicates(list)
    list.group_by { |e| e }.select { |k,v| v.size > 1 }.map(&:first)
  end

  #   A proxy that hasn't been used for at least #delay seconds.
  #   If none is available, the method will block until one becomes available
  def available_proxy
    proxy = @proxies.shift
    @proxies << proxy

    if proxy.last_used then
      nap_time  = @delay - (Time.now - proxy.last_used)
      sleep(nap_time) if nap_time > 0
    end
    proxy.last_used = Time.now

    proxy
  end

  #   This will block until n proxies are available
  def available_proxies(n)
    return nil if n > @proxies.size

    proxies = @proxies.shift(n)
    proxy   = proxies.last
    @proxies.concat(proxies)

    if proxy.last_used then
      nap_time  = @delay - (Time.now - proxy.last_used)
      sleep(nap_time) if nap_time > 0
    end
    proxies.each do |proxy|
      proxy.last_used = Time.now
    end

    proxies
  end

  def self.from_base_url
    from_url "http://work.a-poster.info/prx/perm_socks.txt"
    # self.from_url "http://worldofproxy.com/getx_lFEMdS1SzLf2TPg1_0_______.html"
  end

  def read_url(url, redirect = nil) # FIXME - remove in future
    p "redirect #{url} #{redirect}" if redirect
    if redirect.to_i > 10
      p "redirect to big - #{redirect}"
      return nil
    end
    begin
      tries ||= 50
      proxy = self.available_proxy
      address,port = proxy.get_address
      Net::HTTP.new(url, nil, address,port.to_i).start do |http|
          req = Net::HTTP::Get.new URI(url)
          @response = http.request req
          case @response
          when Net::HTTPSuccess, Net::HTTPOK
            p "ok ) #{url}"
            return @response.body
          when Net::HTTPRedirection
            p "redirect: #{@response['location']}"
            return read_url(@response['location'], redirect.to_i + 1)
          else
            p "#{address}:#{port}"
            raise "can't open: #{@response.code}"
          end
        end
    rescue => e
      p "#{tries} #{e.message}"
      @proxies.delete proxy if @response.code.in? %w(400 501 502 503 504 400 403 407)
      retry if (tries-=1) >= 0
    end
  end

  def remove(proxy)
    @proxies.delete proxy
  end


  def proxy_available?
    !@proxies.first.used_since?(Time.now-@delay)
  end

  def available_count
    time  = Time.now-@delay
    index = @proxies.find_index { |proxy| proxy.used_since?(time) }

    index ? index : @proxies.size
  end
end
