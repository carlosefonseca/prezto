#!/usr/bin/env ruby

require "time"
require "json"

def format_time(time)
  time.strftime("%H:%M")
end

def shorten(name)
  name.length > 11 ? "#{name[0..10]}…" : name
end

def other(event)
  return "" unless event
  "#{format_time(event[:start])}\n#{shorten(event[:name])}"
end

def processEvent(lines)
  lines = lines.split("\n", 2)
  line1 = lines[0].split(";")
  start = Time.parse(line1[0])
  delta = start - Time.now()
  name = line1[1]
  zoom = lines[1][/https:\/\/\w+\.?zoom.us\/[^\s\"]+/]
  { start: start, delta: delta, name: name, location: zoom }
end

def no_events()
  JSON.dump({ str: Time.now().strftime("%B %d"), name: nil, time: nil, loc: nil, color: "black" })
end
data = `icalBuddy -ic "carlos.fonseca@talkdesk.com" -n -eed -eep "attendees" -ea  -nc -b "•"  -ps "|;|\n|" -po "datetime,title,location,notes" eventsToday`

if data.empty?
puts no_events
  return
end

parsed = data[1..].split("•").map { |l| processEvent(l) }.reject { |e| (e[:delta] / 60) < -30 }

if parsed.empty?
  puts no_events
  return
end

(closest_event, index) = parsed.each_with_index.min_by { |e, i| (e[:delta]).abs }

parsed = parsed[index..]

mins = (closest_event[:delta] / 60).round
delta = if mins > 90
    "#{(mins / 60.0).ceil}h"
  else
    "#{mins}m"
  end

name = closest_event[:name]
short_name = shorten(name)
time = format_time(closest_event[:start])
loc = nil
count = parsed.length

color = if mins <= 1
    loc = closest_event[:location]
    "red"
  elsif mins <= 5
    loc = closest_event[:location]
    "orange"
  elsif mins <= 15
    "yellow"
  elsif mins <= 30
    "blue"
  else
    "black"
  end

zoom = loc ? "🔗" : ""

str = if mins <= 0
    "Now #{zoom}\n#{short_name}\n\n#{count} left\n#{other(parsed[1])}"
  else
    "#{short_name}\n#{time} #{zoom}\n#{delta}\n\n#{count} left"
  end

puts JSON.dump({ str: str, name: name, time: time, loc: loc, color: color })
