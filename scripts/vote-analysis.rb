#!/usr/bin/env ruby
#
# Go to http://vtr.aec.gov.au/, click "Senate Downloads" and get:
#
# * First Preferences by Division by Vote Type CSV
# * Votes by Division CSV
#
# Then run:
#   ./vote-analysis.rb 'Pirate Party' \
#     SenateFirstPrefsByDivisionByVoteTypeDownload-NNNNN.csv \
#     SenateVotesCountedByDivisionDownload-NNNNN.csv | sort | tail
#
# This will show you something like:
#
#   0.5625,507/90135,QLD,Dickson
#   0.566,512/90459,QLD,Bonner
#   0.5808,397/68350,TAS,Bass
#   0.5905,415/70275,TAS,Franklin
#   0.6084,578/94997,QLD,Lilley
#   0.6,528/87999,QLD,Moreton
#   0.6762,645/95392,QLD,Ryan
#   0.6922,633/91452,QLD,Griffith
#   0.7111,648/91121,QLD,Brisbane
#   0.8251,560/67868,TAS,Denison
#
# i.e. the Pirate Party in Denison in Tasmania had 0.8251% of the primary vote
# (525 of 61326 total votes).  Note that this is the percentage of *total*
# votes, not the percentage of *formal* votes, so figures shown by the AEC
# will be slightly higher (they use percentage of formal votes).
#
# If you want to see the percentage of votes by division for some other party,
# use their name instead of the Pirates.
#
# Note: error checking is very, very, thin on the ground, so everything will
# break if the CSV format changes for any reason.  Frankly there's probably
# better ways of doing this sort of analysis than randomly hacking ruby code,
# but it was easy for me to put this together in a hurry.
#
# @tserong
#

if ARGV.length != 3
  puts "Usage: #{$0} 'Party Name' first-prefs.csv votes.csv"
  exit
end

require 'csv'

# first prefs by division
fp = {}

CSV.foreach(ARGV[1]) do |row|
  next unless row.length == 17 && row[7] == ARGV[0]
  
  if fp[row[1]]
    fp[row[1]][:votes] += row[16].to_i
  else
    fp[row[1]] = {
      :votes => row[16].to_i,
      :state => row[0],
      :name  => row[2]
    }
  end
end

CSV.foreach(ARGV[2]) do |row|
  next unless row.length == 11
  next unless fp[row[0]]

  total = row[9].to_i
  percentage = (fp[row[0]][:votes].to_f / total.to_f * 100.0).round(4)
  puts "#{percentage},#{fp[row[0]][:votes]}/#{total},#{fp[row[0]][:state]},#{fp[row[0]][:name]}"
end
