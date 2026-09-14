# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
# Required when these tests run outside the Homebrew style environment.
# rubocop:disable Lint/RedundantRequireStatement
require "pathname"
# rubocop:enable Lint/RedundantRequireStatement
require "tmpdir"

# Isolate every test's files in a temporary directory.
class BootstrapTest < Minitest::Test
  ROOT = Pathname(__dir__).parent.freeze

  def setup
    @root = Pathname(Dir.mktmpdir("bootstrap-test"))
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def capture(*args, **options)
    output, error, status = Open3.capture3(*args, **options)
    [output, error, status]
  end
end
