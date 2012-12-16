#!/usr/bin/env ruby -w

Thread.abort_on_exception = true

require 'rubygems'
require 'pcaplet'
require 'webrick'

class Sized < Array

  def initialize(size)
    super()
    @size = size
  end

  def <<(obj)
    super
    shift if length > @size
    return self
  end

end

class Capture

  attr_accessor :urls
  
  def initialize(interface)
    @urls = Sized.new 1000
    @interface = interface
  end

  def run
    rd, wr = IO.pipe

    fork do
      rd.close

      httpdump = Pcaplet.new "-i #{@interface} -s 1500"

      filter = Pcap::Filter.new 'tcp and dst port 80', httpdump.capture

      httpdump.add_filter filter

      httpdump.each_packet do |pkt|
        data = pkt.tcp_data
        next unless data
        request_line, data = data.split("\r\n", 2)
        next unless data
        next unless request_line =~ /^GET\s+(\S+)/ 
        path = $1
        headers = data.split("\r\n\r\n", 2).first.split("\r\n")
        headers = headers.map { |line| line.split(': ', 2) }.flatten
        next unless headers.length % 2 == 0
        headers = Hash[*headers]

        host = headers['Host'] || pkt.dst.to_s

        host << ":#{pkt.dst_port}" if pkt.dport != 80
        url = "http://#{host}#{path}"

        wr.puts [pkt.src.to_s, pkt.sport, url].inspect
      end

      wr.close
    end

    wr.close

    Thread.start do
      until rd.eof? do
        line = rd.gets
        break if line.nil?
        @urls << eval(line)
      end
    end
  end

end

class CaptureServlet < WEBrick::HTTPServlet::AbstractServlet

  def self.get_instance(server, *options)
    @servlet ||= new(server, options.first)
    return @servlet
  end

  def initialize(server, capture)
    @capture = capture
  end

  def do_GET(request, response)
    if request.request_uri.path != '/' then
      response.status = 404
      return
    end

    response.status = 200
    response['Content-Type'] = 'text/html'

    content = []
    content << "<title>#{@capture.urls.length} Most Recent Requests</title>"
    content << '<ol>'
    @capture.urls.reverse_each do |(host, src_port, url)|
      content << "<li>#{host}:#{src_port}: <a href=\"#{url}\">#{url}</a>"
    end
    content << '</ol>'

    response.body = content.join("\n")
  end

end

raise ArgumentError, "#{$0} INTERFACE" if ARGV.empty?

capture = Capture.new ARGV.shift
capture.run

server = WEBrick::HTTPServer.new :Port => 8000
server.mount '/', CaptureServlet, capture
server.start

