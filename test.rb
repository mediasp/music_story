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

def upload_file(filename)
  File.open(filename, 'r') do |file|
    ci_file = CI::File.new
    ci_file.mime_type = 'image/jpeg'
    ci_file.content = file.read
    ci_file.store!
    ci_file
  end
end


def set_artist_image(params)
  Dir.chdir(File.expand_path('~/Projects/msp')) do
    cmd = "bin/msp script ../msp-ops-scripts/ingestion/upload_one_off_image.rb '#{params.to_json}'"
    $stderr.puts cmd
    $stderr.puts `#{cmd}`
  end
end

# FIXME use optparse, lol
def has_switch(switch_name)
! @switches.select {|a| a.index(switch_name) == 2 }.empty?
end

def xml_files
[*switch_value("xml-file") || Dir[@xml_dir + "/*.xml"]]
end

require 'rubygems'

require 'ci-api'
CI::MediaFileServer.configure(
'api@mediaserviceprovider.com', 'chom77gup',
:host         => 'msp.api.cissme.com',
:port         => 80,
:protocol     => :http,
:base_path    => '/',
:logger       => nil,
:open_timeout => 60,
:read_timeout => 60
)


require 'pp'
require 'ci-api'
require 'music_story'
xml_file = File.expand_path('~/raid/20120402/music-story-data-archambault-10GH31-2012-04-02-45-01.xml')

@xml_dir = File.expand_path '~/raid/20120402'

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

@sequel.artist_repo.get_all.each do |ms_artist|

  title = ms_artist.name

  $stderr.puts("looking for #{title}")

  found = msp_db[:artists].filter(:title => /#{title}/i).all

  msp_artist = found.find do |artist_blob|
    $stderr.puts("  #{artist_blob.inspect}")
    found.size == 1 or choice_prompt("Select msp artist?") == 'y'
  end

  if ! msp_artist
    $stderr.puts("no MSP artist msp_artist.")
    next
  end


  CONSTANT_DESCRIPTION_VALUES = {
    :lang_code => "fr",
    :credits   => "Music Story",
    :use       => true,
    :source_id => music_story_licensor[:id],
    :source_property_type => 'biography'

  }

  $stderr.puts("Adding description for artist id:#{msp_artist[:id]} - #{msp_artist[:title]}")

  artist_text_type, artist_text_body = [:plain_text_bio, :plain_text_summary].
  map {|prop| [prop, ms_artist.send(prop)] }.
  find {|prop, text| ! text.nil? }

  if artist_text_body.nil?
    $stderr.puts("No description for music story artist, sad times")
    next
  end

  def now_utc ; Time.now.utc ; end

  description_values = {
    :base_id => msp_artist[:id],
    :updated_at => now_utc,
    :created_at => now_utc,
    :body => artist_text_body,
    #:source_property_type => artist_text_type.to_s,
    :source_property_id   => ms_artist.id,
  }.merge(CONSTANT_DESCRIPTION_VALUES)

  $stderr.puts("Confirm insert:")
  pp description_values

  if choice_prompt("Confirm insert?") == 'n'
    $stderr.puts("quitting on user instruction")
    next
  end

  img_dir = switch_value("img-dir")

  filter_params = {}.tap do |_h|
    [:base_id , :source_property_type, :lang_code, :source_id].map do |key|
      _h[key] = description_values[key]

    end
  end
  if  msp_db[:descriptions].filter(filter_params).count > 0
    $stderr.puts "Overriding existing description!"
    msp_db[:descriptions].filter(filter_params).update(description_values)
  else
    msp_db[:descriptions].insert(description_values)
  end

  if ! ms_artist.image_filename.nil?
    image_file = File.join(File.expand_path(img_dir), ms_artist.image_filename)

    if ! File.exists?(image_file)
      $stderr.puts("no image file called: #{image_file}")
    else
      $stderr.puts("using image file #{image_file}")
      image_params = {
        "source_data"      => {
          "source_id"       => ms_artist.id,
          "source_type"     => "music_story",
          "licensor_id"     => music_story_licensor[:id]
        },
        "credits"         => "Music Story",
        "mime_type"      => "image/jpeg",
        "image_filename" => image_file,
        "artist_id"      => msp_artist[:id]
      }
      $stderr.puts "Replacing artist image #{msp_artist[:primary_image_id]} of artist: #{msp_artist[:id]}"
      set_artist_image(image_params)

    end
  else
    $stderr.puts("no image define for #{ms_artist.name}")
  end
end
