# -*- coding: utf-8 -*-
@switches, @args = ARGV.partition {|arg| /^\-\-/.match(arg) }

def switch_value(switch_name)
  found = @switches.select {|a| a.index(switch_name) == 2 }.first
  found && found.split("=").last
end

def choice_prompt(message, choices=['y', 'n'])
  $stdout.puts(message + "(#{choices.join("/")})?")

  while ! choices.include?(answer = $stdin.readline.strip)
    $stderr.puts("please select from #{choices.join(", ")}")
  end

  answer
end

# FIXME use optparse, lol
def has_switch(switch_name)
  ! @switches.select {|a| a.index(switch_name) == 2 }.empty?
end

def xml_files
  [*switch_value("xml-file") || Dir[@xml_dir + "/*.xml"]]
end

require 'rubygems'
require 'pp'
require 'music_story'
xml_file = '/home/nick/raid/20120402/music-story-data-archambault-10GH31-2012-04-02-45-01.xml'

@xml_dir = '/home/nick/raid/20120402'

sqlite = false

if sqlite
  db_file = switch_value("db") || "music_story.db"
  $stderr.puts("using db file #{db_file}")
  @db = Sequel.sqlite(db_file)
else
  @db = Sequel.connect("mysql://msp:msp@gomorrah/music_story", :encoding => 'utf8')
end

@sequel = MusicStory::Repository::Sequel.new(@db)

def import_db
  @sequel.create_tables!

  $stderr.puts("Loading data from #@xml_dir:")

  xml_files.each do |filename|
    $stderr.puts("  #{filename}")
    begin
      MusicStory::Utils::XMLToDBImporter.import_file_into_db(filename, @db)
    rescue => e
      $stderr.puts("  ERROR: #{e}")
      $stderr.puts("  xml import not complete")
    end
  end
end

if sqlite
  if ! File.exists?(db_file)
    $stderr.puts("importing db to #{db_file}")
    import_db
    # FIXME nuke does not work with mysql
  elsif has_switch("nuke")
    $stderr.puts("nuking #{db_file}")
    `rm #{db_file}`
    import_db
  end
else
  if has_switch("nuke")
    @sequel.drop_tables!
    import_db
  end
end

msp_db = Sequel.connect(switch_value("msp-database"), :encoding => 'utf8')

music_story_licensor = msp_db[:licensors].filter(:title => "Music Story").first
if music_story_licensor.nil?
  $stderr.puts("no music story licensor, barfing")
  exit 1
end

title = @args.first

$stderr.puts("looking for #{title}")

found = msp_db[:artists].filter(:title => /#{title}/i).all

selected = found.find do |artist_blob|
  $stderr.puts("  #{artist_blob.inspect}")
  choice_prompt("Select msp artist?") == 'y'
end

if ! selected
  stderr.puts("no artist selected.")
  exit 1
end

ms_artist = @sequel.artist_repo.get_by_property(:name, title)
if ms_artist
  $stderr.puts("found #{ms_artist.name} in music story")
else
  $stderr.puts("no artist #{title} found in music story")
  exit 1
end


CONSTANT_DESCRIPTION_VALUES = {
  :lang_code => "fr",
  :credits   => "Music Story",
  :use       => true,
  :source_id => music_story_licensor[:id]
}

$stderr.puts("Adding description for artist id:#{selected[:id]} - #{selected[:title]}")

artist_text_type, artist_text_body = [:plain_text_bio, :plain_text_summary].
  map {|prop| [prop, ms_artist.send(prop)] }.
  find {|prop, text| ! text.nil? }

if artist_text_body.nil?
  $stderr.puts("No description for music story artist, sad times")
  exit 1
end

now_utc = Time.now.utc

description_values = {
  :base_id => selected[:id],
  :updated_at => now_utc,
  :created_at => now_utc,
  :body => artist_text_body,
  :source_property_type => artist_text_type.to_s,
  :source_property_id   => ms_artist.id,
}.merge(CONSTANT_DESCRIPTION_VALUES)

$stderr.puts("Confirm insert:")
pp description_values

if choice_prompt("Confirm insert?") == 'n'
  $stderr.puts("quitting on user instruction")
  exit 1
end

msp_db[:descriptions].insert(description_values)
