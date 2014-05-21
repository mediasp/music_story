require 'helpers'

describe 'MusicStory::Model::Batch' do
  describe '#date' do
    it 'returns nil if there is no date found in the path' do
      batch = MusicStory::Model::Batch.new(:path => '/some/folder/and/file')
      assert batch.date.nil?
    end

    it 'returns a Date object extracted from the path' do
      batch = MusicStory::Model::Batch.new(:path => '/some/folder/and/file-2010-01-01')
      assert_equal Date.new(2010, 1, 1), batch.date
    end

    it 'ignores a date that is not part of the filename' do
      batch = MusicStory::Model::Batch.new(:path => '/some/2012-12-12/and/file-2010-01-01')
      assert_equal Date.new(2010, 1, 1), batch.date
    end
  end
end
