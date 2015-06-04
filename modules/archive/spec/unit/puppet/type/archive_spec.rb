require 'spec_helper'
require 'puppet'

describe Puppet::Type::type(:archive) do
  let(:resource) { Puppet::Type.type(:archive).new(
    :path   => '/tmp/example.zip',
    :source => 'http://home.lan/example.zip'
  )}

  it 'resource defaults' do
    resource[:path].should eq '/tmp/example.zip'
    resource[:name].should eq '/tmp/example.zip'
    resource[:filename].should eq 'example.zip'
    resource[:extract].should eq :false
    resource[:cleanup].should eq :true
    resource[:checksum_type].should eq :none
    resource[:checksum_verify].should eq :true
    resource[:extract_flags].should eq :undef
  end

  it 'verify resource[:path] is absolute filepath' do
    expect {
      resource[:path] = 'relative/file'
    }.to raise_error(Puppet::Error, /archive path must be absolute: /)
  end

  it 'verify resoource[:source] is valid source' do
    expect {
      resource[:source] = 'http://home.lan/example.zip'
      resource[:source] = 'https://home.lan/example.zip'
      resource[:source] = 'ftp://home.lan/example.zip'
    }.to_not raise_error

    expect {
      resource[:source] = 'afp://home.lan/example.zip'
    }.to raise_error(Puppet::Error, /invalid source url: /)
  end

  it 'verify resource[:checksum] is valid' do
    expect {
      resource[:checksum] = '557e2ebb67b35d1fddff18090b6bc26b'
    }.to_not raise_error

    expect {
      resource[:checksum] = 'too_short'
    }.to raise_error(Puppet::Error, /Invalid value/)

    expect {
      resource[:checksum] = '557e'
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

  it 'verify resource[:checksum_type] is valid' do
    expect {
      [:none, :md5, :sha1, :sha2, :sha256, :sha384, :sha512].each do |type|
        resource[:checksum_type] = type
      end
    }.to_not raise_error

    expect {
      resource[:checksum_type] = :crc32
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

  describe 'autorequire parent path' do
    # Need to import puppet's crazy monkey patch to test:
    class Object
      alias :must :should
      alias :must_not :should_not
    end

    before :each do
      @file_tmp = Puppet::Type.type(:file).new(:name => '/tmp')
      @catalog = Puppet::Resource::Catalog.new
      @catalog.add_resource @file_tmp
    end

    it 'should require archive parent' do
      example_archive = described_class.new(
        :path   => '/tmp/example.zip',
        :source => 'http://home.lan/example.zip'
      )
      @catalog.add_resource example_archive

      req = example_archive.autorequire
      req.size.should == 1
      req[0].target.must == example_archive
      req[0].source.must == @file_tmp
    end
  end
end
