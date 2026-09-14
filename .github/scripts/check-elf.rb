#!/usr/bin/env ruby
# frozen_string_literal: true

require "find"
require "open3"

# Check the architecture and glibc requirements of unpacked bootstrap binaries.
module BootstrapELF
  def self.check(directory, architecture)
    # These ceilings follow the minimum runtime versions documented in README.md.
    machine, maximum = {
      "x86_64" => ["Advanced Micro Devices X86-64", [2, 13]],
      "arm64"  => ["AArch64", [2, 17]],
    }.fetch(architecture)
    count = 0
    Find.find(directory) do |path|
      next if File.symlink?(path) || !File.file?(path)
      next if File.binread(path, 4) != "\x7FELF".b

      count += 1
      output, status = Open3.capture2(
        { "LC_ALL" => "C" }, "readelf", "--file-header", "--version-info", path
      )
      raise "readelf failed for #{path}" unless status.success?
      raise "Unexpected architecture: #{path}" if output[/Machine:\s*([^\n]*)/, 1]&.strip != machine

      output.scan(/Name:\s+(GLIBC_\S*)/).flatten.each do |requirement|
        version = requirement[/\AGLIBC_([0-9]+(?:\.[0-9]+)+)\z/, 1]
        raise "Unrecognized glibc requirement #{requirement}: #{path}" unless version

        if (version.split(".").map(&:to_i) <=> maximum).positive?
          raise "#{path} requires glibc #{version}, newer than #{maximum.join(".")}"
        end
      end
    end
    raise "No ELF binaries found" if count.zero?

    count
  end
end

if $PROGRAM_NAME == __FILE__
  abort "Usage: #{$PROGRAM_NAME} <x86_64|arm64> <directory>" if ARGV.length != 2
  begin
    count = BootstrapELF.check(ARGV.fetch(1), ARGV.fetch(0))
    puts "Checked #{count} ELF files for #{ARGV.fetch(0)}"
  rescue => e
    abort e.message
  end
end
