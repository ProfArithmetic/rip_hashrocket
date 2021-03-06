require "rip_hashrocket/version"

module RipHashrocket
  def self.process(options)
    directory = options[0] || Dir.pwd
    backup = options[1] || false

    filecount = 0
    linecount = 0
    rbfiles = File.join(directory ,"**", "*.rb")
    rhtmlfiles = File.join(directory, "**", "*.rhtml")
    erbfiles = File.join(directory, "**", "*.erb.html")

    scanned_files = ( Dir.glob(erbfiles) + Dir.glob(rhtmlfiles) + Dir.glob(rbfiles) )

    scanned_files.each do |filename|
      file = File.new(filename, "r+")

      made_changes = false
      lines = file.readlines

      lines.each_with_index do |line, i|
        newline = line.replace_rockets(line)
        if newline != line
          lines[i] = newline
          made_changes = true
          linecount += 1
        end
      end

      file.close
      if made_changes
        filecount += 1
        if backup
          File.rename(filename, filename + ".bak")
        else
          File.delete(filename)
        end

        file = File.new(filename, "w+")
        file.puts(lines.join)
        file.close
      end
    end
    p "Hash Rockets has upgraded hash syntax on #{linecount} lines in #{filecount} out of #{scanned_files.count} source files tested"
  end
end

class String
  def replace_rockets(s)
    s.gsub(/:([0-9a-z_\-.]*)(\s{0,})=>(\s{0,})/) do |n|
      #puts "n: #{n}"
      n.include?('-') ? n : "#{$1} : #{$2!=' '?$2:''}#{$3}".squeeze(' ')
    end
  end
end
