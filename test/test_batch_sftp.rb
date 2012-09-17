require 'helpers'
require 'tmpdir'
require 'tempfile'
require 'fileutils'
require 'music_story/repository/batch_sftp'

class MockSFTPSession

  class MockEntry
    attr_reader :name
    def initialize(props)
      @name = props[:name]
    end
  end

  class MockDir
    def initialize(dir) ; @dir = dir ; end

    def [](base, pattern)
      Dir[File.join(@dir, base, pattern)].map do |p|
        MockEntry.new(:name => File.basename(p))
      end
    end
  end

  def initialize(dir) ; @dir = dir        ; end
  def dir             ; MockDir.new(@dir) ; end

  def upload!(local_path, remote_path)
    local_remote_path = File.join(@dir, remote_path)
    FileUtils.cp(local_path, local_remote_path)
    nil
  end

  def rename(src, dest, flags_ignored)
    local_src = File.join(@dir, src)
    local_dest = File.join(@dir, dest)
    FileUtils.mv(local_src, local_dest)
  end

  def download!(remote_dir, local_dir, options={})
    raise 'options not supported' unless options == {:recursive => true}

    local_remote_dir = File.join(@dir, remote_dir)
    FileUtils.cp_r(local_remote_dir, local_dir)
  end
end

describe "MusicStory::Repository::BatchSFTP" do
  include FileUtils

  before do
    @tempdir = Dir.mktmpdir
    mock_sftp_session = MockSFTPSession.new(@tempdir)
    repository =  MusicStory::Repository::BatchSFTP.new('host', 'user')
    @session = MusicStory::Repository::BatchSFTP::SessionWrapper.
      new(repository, mock_sftp_session)
  end

  attr_reader :session

  after do
    rm_r(@tempdir) unless @tempdir.nil?
  end

  def tree(paths)
    @files_in_tree = []
    paths.each do |local_path|
      path = File.join(@tempdir, local_path)

      if path[-1].chr == '/'
        mkdir_p(path)
      else
        @files_in_tree << local_path
        File.open(path, 'w') {|f| f.puts 'empty' }
      end
    end
  end

  def files_in_tree ; @files_in_tree ; end

  describe "#connect" do
    it "connects to the sftp site using the given credentials"
  end

  describe "#new_available?" do

    def tree(dirs)
      super([
          'noise',
          'music-story-data-2010-02-01.log',
          'processed/',
          'processed/music-story-data-2010-02-01/',
          'processing/',
          'processing/music-story-data-2010-01-20'
        ] + dirs)
    end

    it "returns false if there are no batches in the directory" do
      tree []
      assert ! session.new_available?
    end

    it "returns false if there is a batch in the directory, but it has no " +
      "delivery.complete file" do

      tree [
        'music-story-data-2010-01-01/'
      ]

      assert ! session.new_available?
    end

    it "returns true if there is a batch in the directory that has a " +
      "delivery.complete file" do

      tree [
        'music-story-data-2010-01-01/',
        'music-story-data-2010-01-01/delivery.complete',
      ]

      assert session.new_available?
    end

    it "returns true if there are two batches in the directory; one with a " +
      "delivery.complete file, and one without" do

      tree [
        'music-story-data-2010-01-01/',
        'music-story-data-2010-01-01/delivery.complete',
        'music-story-data-2010-02-01/',
      ]

      assert session.new_available?
    end

  end

  describe "#processed_batches" do

    def tree(dirs)
      super([
          'noise',
          'music-story-data-2008-01-01.log',
          'music-story-data-2008-02-01.log',
          'music-story-data-2008-03-01.log',
          'music-story-data-2009-02-01/',
          'music-story-data-2009-02-01/delivery.complete',
          'processing/',
          'processing/music-story-data-2009-03-01',
        ] + dirs)
    end

    it "returns an empty list if there are no batches in the processed " +
      "directory" do
      tree []
      assert session.processed_batches.empty?
    end

    it "returns a Batch with state 'processed' if there is batch in the " +
      "processed directory" do

      tree [
        'processed/music-story-data-2010-01-01/'
      ]

      batch = session.processed_batches.first
      assert_equal '/processed/music-story-data-2010-01-01', batch.path
      assert_equal :processed, batch.state
    end

  end

  describe "#processing_batches" do

    def tree(dirs)
      super([
          'noise',
          'music-story-data-2008-01-01.log',
          'music-story-data-2009-02-01/',
          'music-story-data-2009-02-01/delivery.complete',
          'processed/',
          'processed/music-story-data-2008-01-01',
        ] + dirs)
    end


    it "returns an empty list if there are no directories inside the " +
      "processing directory" do
      tree []
      assert session.processing_batches.empty?
    end

    it "returns a Batch if there is a directory inside the processing " +
      "directory" do
      tree [
        'processing/music-story-data-2010-01-01/'
      ]

      batch = session.processing_batches.first
      assert_equal '/processing/music-story-data-2010-01-01', batch.path
      assert_equal :processing, batch.state
    end

    it "returns multiple Batches if there are multiple directories in the " +
      "processing directory" do

      tree [
        'processing/music-story-data-2010-01-01/',
        'processing/music-story-data-2010-02-01/'
      ]

      batches = session.processing_batches.sort {|l, r| l.path <=> r.path }

      batch = batches.shift
      assert_equal '/processing/music-story-data-2010-01-01', batch.path
      assert_equal :processing, batch.state

      batch = batches.shift
      assert_equal '/processing/music-story-data-2010-02-01', batch.path
      assert_equal :processing, batch.state
    end
  end

  describe "#new_batches" do

    def tree(dirs)
      super([
          'noise',
          'music-story-data-2010-02-01.log',
          'processed/',
          'processed/music-story-data-2010-02-01/',
          'processing/',
          'processing/music-story-data-2010-01-20/'
        ] + dirs)
    end

    it "returns an empty list if there are no batches in the directory" do
      tree []
      assert session.new_batches.empty?
    end

    it "returns an empty list if there is a batch in the directory, but it has no " +
      "delivery.complete file" do
      tree [
        'music-story-data-2010-01-01/'
      ]
      assert session.new_batches.empty?
    end

    it "returns a single Batch if there is a batch in the directory that has a " +
      "delivery.complete file" do
      tree [
        'music-story-data-2010-01-01/',
        'music-story-data-2010-01-01/delivery.complete'
      ]

      batch = session.new_batches.first
      assert batch
      assert_equal '/music-story-data-2010-01-01', batch.path
      assert_equal :new, batch.state
    end

    it "returns a single Batch if there are two batches in the directory; one with a " +
      "delivery.complete file, and one without" do
      tree [
        'music-story-data-2010-01-01/',
        'music-story-data-2010-01-01/delivery.complete',
        'music-story-data-2010-02-01/'
      ]

      batch = session.new_batches.first
      assert batch
      assert_equal '/music-story-data-2010-01-01', batch.path
      assert_equal :new, batch.state
    end
  end

  describe "#mark_processing" do
    it "moves the batch directory in to the processing directory" do
      tree [
        "processed/",
        "processing/",
        "music-story-data-2010-01-01/",
        "music-story-data-2010-01-01/delivery.complete",
        "music-story-data-2010-01-01/01.xml"
      ]

      batch = session.new_batches.first
      assert batch
      assert_equal :new, batch.state
      assert_equal '/music-story-data-2010-01-01', batch.path

      session.mark_processing(batch)

      assert_equal :processing, batch.state
      assert_equal '/processing/music-story-data-2010-01-01', batch.path
    end
  end

  describe "#mark_processed" do
    it "moves the batch directory in to the processed directory" do
      tree [
        "processed/",
        "processing/music-story-data-2010-01-01/",
        "processing/music-story-data-2010-01-01/01.xml"
      ]

      batch = session.processing_batches.first
      assert batch
      assert_equal :processing, batch.state
      assert_equal '/processing/music-story-data-2010-01-01', batch.path

      session.mark_processed(batch)

      assert_equal :processed, batch.state
      assert_equal '/processed/music-story-data-2010-01-01', batch.path
    end

    it "optionally takes a log file that it copies to the base directory" +
      " following the name of the batch" do
      tree [
        "processed/",
        "processing/music-story-data-2010-01-01/",
        "processing/music-story-data-2010-01-01/01.xml"
      ]

      batch = session.processing_batches.first
      assert batch
      assert_equal :processing, batch.state
      assert_equal '/processing/music-story-data-2010-01-01', batch.path

      logfile = Tempfile.new('music-story.log')
      logfile.puts 'this is so informative'
      logfile.flush

      session.mark_processed(batch, logfile.path)

      assert_equal :processed, batch.state
      assert_equal '/processed/music-story-data-2010-01-01', batch.path

      assert File.exists?(File.join(@tempdir, 'music-story-data-2010-01-01.log'))
    end
  end

  describe "#download" do
    it "can download all the files in the given batch to the given location" do
      tree [
        "processing/music-story-data-2010-01-01/",
        "processing/music-story-data-2010-01-01/img/",
        "processing/music-story-data-2010-01-01/img/dog.jpeg",
        "processing/music-story-data-2010-01-01/img/cat.png",
        "processing/music-story-data-2010-01-01/01.xml",
        "processing/music-story-data-2010-01-01/02.xml",
        "processing/music-story-data-2010-01-01/03.xml"
      ]

      batch = session.processing_batches.first
      assert_equal '/processing/music-story-data-2010-01-01', batch.path


      Dir.mktmpdir do |out_dir|
        session.download(batch, out_dir)

        files_in_tree.each do |file|
          looking_for = file.split("/")[1..-1].join('/')
          assert File.exists?(File.join(out_dir, looking_for)), looking_for
        end
      end
    end
  end

end
