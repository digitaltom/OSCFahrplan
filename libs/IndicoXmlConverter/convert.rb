#!/usr/bin/env ruby

require "rubygems"
require "xml/libxml"
require "uri"
require "net/http"
require "time"

URL = "http://conference.opensuse.org/indico//conferenceOtherViews.py?confId=2&view=xml&fr=no"

def escape_xml(input)
  return input.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;')
end


indico_string = Net::HTTP.get_response( URI.parse( URL ) ).body
indico_doc = XML::Document.string( indico_string )

schedule_doc = XML::Document.string( "<schedule/>" )

# Creating header
schedule_conference = XML::Node.new( "conference" )
schedule_doc.root << schedule_conference

schedule_conference << XML::Node.new("title", "openSUSE Conference 2011" )
schedule_conference << XML::Node.new("subtite", "rwx3" )
schedule_conference << XML::Node.new("venue", "Zentrifuge" )
schedule_conference << XML::Node.new("city", "Nuemberg, Germany" )
schedule_conference << XML::Node.new("start", "2011-09-11" )
schedule_conference << XML::Node.new("end", "2011-09-14" )
schedule_conference << XML::Node.new("days", "4" )
schedule_conference << XML::Node.new("release", Time.now.strftime("Version %m/%d/%Y %H:%M") )
schedule_conference << XML::Node.new("day_change", "00:00" )
schedule_conference << XML::Node.new("timeslot_duration", "00:30" )


talks = indico_doc.find "//session/contribution"  

# iterate over days
dates = talks.map{|talk| talk.find_first( "startDate" ).content[0,10] }.uniq.sort
roomnames = talks.map{|talk| talk.find_first( "location/room" ).content }.uniq.sort

dates.each_with_index do |date, i| 
  day = XML::Node.new( "day" )
  day["date"] = date
  day["index"] = "#{i+1}"
  schedule_doc.root << day

  #Rooms
  roomnames.each do |roomname|
    room = XML::Node.new( "room" )
    room["name"] = roomname
    day << room

    # get talks for that day / room
    talks = indico_doc.find "//session/contribution[starts-with(startDate, '#{date}') and location/room = '#{roomname}']"
    talks.each do |talk|
      event = XML::Node.new( "event" )
      event["id"] = talk.find_first( "ID" ).content
      event << XML::Node.new("start", talk.find_first( "startDate" ).content[11,5] )
      t1 = Time.parse( talk.find_first( "startDate" ).content )
      t2 = Time.parse( talk.find_first( "endDate" ).content )
      hours = (((t2 - t1).to_i/60)/60).to_s.rjust(2, '0')
      minutes = (((t2 - t1).to_i/60)%60).to_s.rjust(2, '0')
      event << XML::Node.new("duration", "#{hours}:#{minutes}" )
      event << XML::Node.new("room", talk.find_first( "location/room" ).content )
      event << XML::Node.new("slug", " " )
      event << XML::Node.new("title", escape_xml( talk.find_first( "title" ).content ) )
      event << XML::Node.new("subtitle", " " )
      track = talk.find_first( "track" ).nil? ? "unknown" : talk.find_first( "track" ).content
      event << XML::Node.new("track", track )
      type = talk.find_first( "type/name" ).nil? ? "unknown" : talk.find_first( "type/name" ).content
      event << XML::Node.new("type", type )
      event << XML::Node.new("language", "en" )
      event << XML::Node.new("abstract", " " )
      event << XML::Node.new("description", escape_xml( talk.find_first( "abstract" ).content ) )
      persons = XML::Node.new("persons")
      event << persons
      talk.find( "speakers/user" ).each do |speaker|
        name = "#{speaker.find_first( "name" )['first']} #{speaker.find_first( "name" )['last']}"
        person = XML::Node.new("person", name )
        person["id"] = ""
        persons << person
      end
      event << XML::Node.new("links", " " )

      room << event
    end

    # add the breaks
    breaks = indico_doc.find "//breaks"


  end

end


puts schedule_doc
