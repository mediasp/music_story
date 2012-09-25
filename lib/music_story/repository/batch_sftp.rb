require 'net/sftp'
require 'music_story/model/batch'

module MusicStory

  # Gives access to whole batches of music story data that are kept somewhere
  # on an sftp site somwhere that music story can constantly deliver new data.
  # Once downloaded, this data can be accessed using the xml repository, or
  # imported in to a local database
  class Repository::BatchSFTP

    # the presence of this file inside a batch directory tells us that the sender
    # has finished sending it
    DELIVERY_COMPLETE = 'delivery.complete'

    # some sub dirs we use to manage the flow of data
    DIR_PROCESSING = 'processing'
    DIR_PROCESSED  = 'processed'

    # memoised flag from sftp rename methods
    RENAME_NATIVE = Net::SFTP::Constants::RenameFlags::NATIVE

    def initialize(host, username, options={})
      @host = host
      @username = username
      @options = options
      @basedir = options[:basedir] || '/'
      @batch_pattern = options[:batch_pattern] || 'music-story-data-*'
      @logger = options[:logger] || Logger.new('/dev/null')
    end

    # start talking to the remote server, yielding the session to the block,
    # which is closed after the block finishes executing.
    # The block is yielded a wrapper object that lets you use the access methods
    # in the repository, minus the first argument, for instance:
    #    repo.connect do |session|
    #      batch = session.new_batches.first
    #      session.download(batch, '/tmp/dir')
    #    end
    def connect(&block)
      return_result = nil
      # the sftp.start method does not seem to return the last thing you execute
      start_sftp_session do |sftp_session|
        return_result = yield SessionWrapper.new(self, sftp_session)
      end
      return_result
    end

    def start_sftp_session(&block)
      cnx_options = (@options[:net_sftp_options] || {}).
        merge(:password => @options[:password])

      @logger.info("Starting sftp session to '#{@host}'")
      Net::SFTP.start(@host, @username, cnx_options) do |sftp_session|
        block.call(sftp_session)
      end.tap do
        @logger.info("Finished sftp session to '#{@host}'")
      end
    end

    #
    # the following methods should be accessed by using connect, and not directly
    #

    # return a list of batches on the sftp that are in the processed state, i.e
    # live in the `processed` directory
    def processed_batches(w)
      dir = join(@basedir, DIR_PROCESSED)
      w.sftp.dir[dir, '*'].map do |entry|
        Model::Batch.new(:path => join(dir, entry.name), :state => :processed)
      end
    end

    # return a list of batches on the sftp site that are in the processing
    # state, i.e live in the `processing` directory
    def processing_batches(w)
      dir = join(@basedir, DIR_PROCESSING)
      w.sftp.dir[dir, '*'].map do |entry|
        Model::Batch.new(:path => join(dir, entry.name), :state => :processing)
      end
    end

    # return a list of all the batches on the sftp site that are ready to
    # be downloaded or we can start processing them
    def new_batches(w)
      @logger.debug("Looking for new batches in remote dir '#@basedir' with pattern #@batch_pattern")
      complete_dirs = w.sftp.dir[@basedir, @batch_pattern].select do |entry|
        w.sftp.dir[join(@basedir, entry.name), DELIVERY_COMPLETE].any?.tap do |f|
          if f
            @logger.debug("  Found new batch: #{entry.name}")
          else
            @logger.debug("  Incomplete batch: #{entry.name}")
          end
        end
      end

      complete_dirs.map do |entry|
        Model::Batch.new(:path => join(@basedir, entry.name),
          :state => :new)
      end
    end

    # download a batch.  Should work for a batch in any state
    def download(w, batch, local_dir)
      @logger.info("Downloading #{batch.path} to #{local_dir}...")
      w.sftp.download!(batch.path, local_dir, :recursive => true) do |event, downloader, *args|
        case event
        when :open then
          # args[0] : file metadata
          @logger.debug "Starting download: #{args[0].remote} -> #{args[0].local} (#{args[0].size}) bytes"
        when :close then
          # args[0] : file metadata
          @logger.debug "Finished download: #{args[0].remote}"
        when :finish then
          @logger.debug "Download complete"
        end
      end
    end

    # return true if there are any batches available
    def new_available?(w)
      new_batches(w).any?
    end

    # move a batch in to the processing state, moving its location on the remote
    # fs
    def mark_processing(w, batch)
      new_name = join(@basedir, DIR_PROCESSING, File.basename(batch.path))
      w.sftp.rename(batch.path, new_name, RENAME_NATIVE)
      batch.path = new_name
      batch.state = :processing
    end

    # move a batch in to the processed state, moving its location on the remote
    # fs
    def mark_processed(w, batch, path_to_logfile=nil)
      batch_basename = File.basename(batch.path)
      new_name = join(@basedir, DIR_PROCESSED, batch_basename)
      w.sftp.rename(batch.path, new_name, RENAME_NATIVE)
      batch.path = new_name
      batch.state = :processed

      if path_to_logfile
        remote_logfile_path = join(@basedir, batch_basename + '.log')
        uploader = w.sftp.upload!(path_to_logfile, remote_logfile_path)
      end
    end

    private

    # less chars ftw
    def join(*args) ; File.join(*args) ; end
  end

  class Repository::BatchSFTP::SessionWrapper

    attr_reader :sftp

    def initialize(repository, sftp_session)
      @repository = repository
      @sftp = sftp_session
    end

    def method_missing(name, *args, &block)
      @repository.send(name, *([self] + args), &block)
    end

    def respond_to?(name)
      @repository.respond_to?(name)
    end
  end
end
