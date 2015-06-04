require 'spec_helper'
require 'tmpdir'

archive_provider = Puppet::Type.type(:archive).provider(:default)

describe archive_provider do
  let(:resource){
    Puppet::Type::Archive.new({
      :name => '/tmp/example.zip',
      :source => 'http://home.lan/example.zip'
    })
  }

  let(:provider){
    archive_provider.new(resource)
  }

  let(:zipfile){
    File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'files', 'test.zip'))
  }

  it '#checksum?' do
    Dir.mktmpdir do |dir|
      resource[:path] = File.join(dir, resource[:filename])
      FileUtils.cp(zipfile, resource[:path])

      resource[:checksum] = '377ec712d7fdb7266221db3441e3af2055448ead'
      resource[:checksum_type] = :sha1
      expect(provider.checksum?).to eq true

      resource[:checksum] = '557e2ebb67b35d1fddff18090b6bc26b'
      resource[:checksum_type] = :md5
      expect(provider.checksum?).to eq true

      resource[:checksum] = '557e2ebb67b35d1fddff18090b6bc26b'
      resource[:checksum_type] = :sha1
      expect(provider.checksum?).to eq false
    end
  end

  it '#extract' do
    Dir.mktmpdir do |dir|
      resource[:path] = File.join(dir, resource[:filename])
      extracted_file = File.join(dir, 'test')
      FileUtils.cp(zipfile, resource[:path])

      resource[:extract] = :true
      resource[:creates] = extracted_file
      resource[:extract_path] = dir

      provider.extract
      expect(File.read(extracted_file)).to eq "hello world\n"
    end
  end

  it '#extracted?' do
    Dir.mktmpdir do |dir|
      resource[:path] = File.join(dir, resource[:filename])
      extracted_file = File.join(dir, 'test')
      FileUtils.cp(zipfile, resource[:path])

      resource[:extract] = :true
      resource[:creates] = extracted_file
      resource[:extract_path] = dir

      expect(provider.extracted?).to eq false
      provider.extract
      expect(provider.extracted?).to eq true
    end
  end

  it '#cleanup' do
    Dir.mktmpdir do |dir|
      resource[:path] = File.join(dir, resource[:filename])
      extracted_file = File.join(dir, 'test')
      FileUtils.cp(zipfile, resource[:path])

      resource[:extract] = :true
      resource[:cleanup] = :true
      resource[:creates] = extracted_file
      resource[:extract_path] = dir

      provider.extract
      provider.cleanup
      expect(File.exist? resource[:path]).to eq false
    end
  end

  it '#create' do
    Dir.mktmpdir do |dir|
      resource[:path] = File.join(dir, resource[:filename])
      extracted_file = File.join(dir, 'test')
      FileUtils.cp(zipfile, resource[:path])

      resource[:extract] = :true
      resource[:cleanup] = :true
      resource[:creates] = extracted_file
      resource[:extract_path] = dir

      provider.create
      expect(File.read(extracted_file)).to eq "hello world\n"
      expect(File.exist? resource[:path]).to eq false
    end
  end
end
