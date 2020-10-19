#!/usr/bin/env ruby

require "rest-client"
require 'Base64'
require 'json'
require 'highline/import'
require 'security'

credentials = Security::InternetPassword.find(server: "talkdesk.atlassian.net")

if credentials
  token = "#{credentials.attributes["acct"]}:#{credentials.password}"
else
  puts "No credentials found on keychain."
  puts "Go to https://id.atlassian.com/manage-profile/security/api-tokens and create an API token."
  puts "Enter it here along with your email. It'll be saved on Keychain."
  email = ask("email: ")
  apiKey = ask("api key: ")
  Security::InternetPassword.add("talkdesk.atlassian.net", email, apiKey)

  token = "#{email}:#{apiKey}"
end

txt = File.read(ARGV[0])

ticketIds = txt.split("\n").uniq.map { |l|
  m = l.match(/^\[?(iOS|MOB[OP])\D(\d+)\D.\]?.*/i)
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

    puts "Line without ticket"
    [nil, line, nil]

  end

end

outTxt = ticketWithStatus.reject{ |_,line,status| status == "Closed" || line.empty? }.map{ |_,line,_| line }.join("\n")+"\n"

File.write(ARGV[0], outTxt)
