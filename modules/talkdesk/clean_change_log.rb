#!/usr/bin/env ruby

require "rest-client"
require 'Base64'
require 'json'
require 'security'

if ARGV[0] == "--help"
  name = File.basename($0)

  if STDOUT.tty?
    BOLD="\033[1m"
    CLEAR="\033[0m"
  else
    BOLD=""
    CLEAR=""
  end
  

  puts """
Script to help with the change log file by interacting with JIRA.
On the first run, it will ask you to setup an API key, which will be stored in your Keychain.

USAGE:
  #{BOLD}#{name} <file.txt>#{CLEAR}
    Cleans the specified change log file, removing the closed tickets.

  #{BOLD}#{name} --reset#{CLEAR}
    Removes the stored credentials from Keychain.

  #{BOLD}#{name} --add-issue <MOB-123> <file.txt>#{CLEAR}
    Fetches the specified issue's name and appends to the change log

  #{BOLD}#{name} --add-clean <MOB-123> <file.txt>#{CLEAR}
    Fetches the specified issue's name, appends to the change log and then cleans the whole file.

  #{BOLD}#{name} --get-issue <MOB-123> [<fields>]#{CLEAR}
    Fetches the specified issue, returning the full JSON.
    Add comma-separated fields e.g. `status,summary,parent` to limit the returned data to those fields.
"""
  exit
end

if ARGV[0] == "--reset"
  Security::InternetPassword.delete(server: "talkdesk.atlassian.net")
  exit
end

credentials = Security::InternetPassword.find(server: "talkdesk.atlassian.net")

if credentials
  token = "#{credentials.attributes["acct"]}:#{credentials.password}"
else

  raise "No Credentials and not a TTY. Aborting!" unless $stdout.tty?

  puts "No credentials found on keychain."
  puts "Go to https://id.atlassian.com/manage-profile/security/api-tokens and create an API token."
  puts "Enter it here along with your email. It'll be saved on Keychain."
  print "Email: "
  email = $stdin.gets.chomp
  print "API Key: "
  apiKey = $stdin.gets.chomp
  token = "#{email}:#{apiKey}"

  begin
    puts "Testing…"
    url = "https://talkdesk.atlassian.net/rest/api/3/myself"
    r = RestClient.get(url, {:authorization => "Basic #{Base64.strict_encode64(token)}"})
    puts "Hello #{JSON.parse(r)["displayName"]}!"
    Security::InternetPassword.add("talkdesk.atlassian.net", email, apiKey)
    
  rescue => exception
    puts exception
    puts "Please try again! Aborting"
    exit 1
  end
end

if ARGV[0] == "--get-issue"
  id = ARGV[1] || raise("No issue specified!")
  url = "https://talkdesk.atlassian.net/rest/api/3/issue/#{id}?fields=#{ARGV[2]}"
  r = RestClient.get(url, {:authorization => "Basic #{Base64.strict_encode64(token)}"})
  puts r
  exit
end


if ["--add-issue", "--add-clean"].include? ARGV[0]
  id = ARGV[1] || raise("No issue specified!")
  file = ARGV[2] || raise("No file specified!")
  url = "https://talkdesk.atlassian.net/rest/api/3/issue/#{id}?fields=summary"
  r = RestClient.get(url, {:authorization => "Basic #{Base64.strict_encode64(token)}"})
  json = JSON.parse(r)
  summary = json["fields"]["summary"].sub(/\[iOS\] /i, "")
  key = json["key"]
  line = "#{key} #{summary}"
  open(file, 'a') { |f|
    f.puts line
  }
  exit if ARGV[0] == "--add-issue"
  ARGV[0] = file
end

txt = File.read(ARGV[0])

ticketIds = txt.gsub(/\[iOS\] /i, "").split("\n").uniq.map { |l|
  m = l.match(/^\[?(iOS|MOB|MOB[OP])\D(\d+)\D.\]?.*/i)
  if m
    ["#{m[1]}-#{m[2]}", l]
  else
    [nil, l]
  end
}

ticketWithStatus = ticketIds.map do |id, line|

  if id

    url = "https://talkdesk.atlassian.net/rest/api/3/issue/#{id}?fields=status"
    r = RestClient.get(url, {:authorization => "Basic #{Base64.strict_encode64(token)}"})
    json = JSON.parse(r)

    status = json["fields"]["status"]["name"]
    puts "#{id} => #{status}"

    [id, line, status]

  else

    puts "??? - #{line}"
    [nil, line, nil]

  end

end

outTxt = ticketWithStatus.reject{ |_,line,status| status == "Closed" || line.empty? }.map{ |_,line,_| line }.join("\n")+"\n"

File.write(ARGV[0], outTxt)
