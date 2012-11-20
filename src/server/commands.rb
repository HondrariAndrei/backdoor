#!/usr/bin/env ruby

require 'base64'

module Commands
    def run_command(cmd)
        begin
            return `#{cmd}`
        rescue Exception => e
            return e.to_s
        end # rescue
    end
    
    def get_command(filename)
        if !File.exist?(filename) then
            return "File: " + filename + " does not exist."
        end
        file = File.open(filename, "rb")
        return file.read
    end
end
