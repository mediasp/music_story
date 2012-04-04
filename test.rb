
@switches, @args = ARGV.partition {|arg| /^\-\-/.match(arg) }

def switch_value(switch_name)
  @switches.select {|a| a.index(switch_name) == 2 }.first.split("=").last
end


# FIXME use optparse, lol
def has_switch(switch_name)
  ! @switches.select {|a| a.index(switch_name) == 2 }.empty?
end

def xml_files
  Dir[@xml_dir + "/*.xml"]
end

require 'rubygems'
require 'music_story'
xml_file = '/home/nick/raid/20120402/music-story-data-archambault-10GH31-2012-04-02-45-01.xml'

@xml_dir = '/home/nick/raid/20120402'

db_file = switch_value("db") || "music_story.db"

$stderr.puts("using db file #{db_file}")

@db = Sequel.sqlite(db_file)
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

if ! File.exists?(db_file)
  $sdterr.puts("importing db to #{db_file}")
  import_db
elsif has_switch("nuke")
  $stderr.puts("nuking #{db_file}")
  `rm #{db_file}`
  import_db
end


puts @sequel.artist_repo.get_all
