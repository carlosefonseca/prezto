#!/usr/bin/env ruby
original = ARGF.read

def processLine(original)
  line_width = 14

  if original.length <= line_width
    puts original
    return
  end

  tt = original.split(" ")
  txt = ""

  loop do
    line = tt.shift

    while tt.empty? == false && (line + tt.first).length < line_width
      line = "#{line} #{tt.shift}".strip
    end

    txt += line
    if tt.empty?
      break
    end
    txt += "\n"
  end
  puts txt.strip()
end

original.split("\n").each { |line| processLine(line) }
