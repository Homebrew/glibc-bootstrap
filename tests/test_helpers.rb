# frozen_string_literal: true

require "digest"
require_relative "test_helper"

# Exercise staging and packaging through the build scripts' shell helpers.
class BuildHelpersTest < BootstrapTest
  def setup
    super
    @prefix = @root/"prefix"
    @packages = @root/"packages"
  end

  def run_shell(command, environment = {})
    capture(
      { "UTILS" => (ROOT/"utils.sh").to_s, "PREFIX" => @prefix.to_s,
        "PKGDIR" => @packages.to_s, "BUILD_JOBS" => "2" }.merge(environment),
      "bash", "-c", %Q(source "$UTILS"; #{command})
    )
  end

  def test_package_preserves_contents_and_cleans_staging
    _, error, status = run_shell(
      'prepare_build; mkdir "$PREFIX/bin"; printf payload > "$PREFIX/bin/tool"; package example 1.0',
    )
    assert_predicate status, :success?, error
    archives = @packages.glob("bootstrap-*-example-1.0.tar.gz")
    assert_equal 1, archives.length
    output, error, status = capture("tar", "-xOf", archives.fetch(0).to_s, "./bin/tool")
    assert_predicate status, :success?, error
    assert_equal "payload", output
    assert_empty @prefix.children
  end

  def test_existing_staging_contents_are_preserved
    @prefix.mkpath
    marker = @prefix/"unfinished-build"
    marker.write("keep")
    _, error, status = run_shell("prepare_build")
    refute_predicate status, :success?
    assert_equal "keep", marker.read
    assert_includes error, "not empty"
  end

  def test_packages_cannot_be_inside_staging
    _, error, status = run_shell("prepare_build", "PKGDIR" => (@prefix/"packages").to_s)
    refute_predicate status, :success?
    assert_includes error, "separate package directory"
  end

  def test_symlinked_staging_is_rejected
    @packages.mkpath
    File.symlink(@packages, @prefix)
    _, error, status = run_shell("prepare_build")
    refute_predicate status, :success?
    assert_includes error, "not symlinks"
  end

  def test_invalid_job_count_is_rejected
    %w[0 -1 two].each do |value|
      _, error, status = run_shell("prepare_build", "BUILD_JOBS" => value)
      refute_predicate status, :success?
      assert_includes error, "positive integer"
    end
  end

  def test_unprepared_prefix_cannot_be_packaged
    _, _, status = run_shell("package example 1.0")
    refute_predicate status, :success?
    refute_path_exists @packages
  end

  def test_checksums_accept_matching_and_reject_changed_content
    source = @root/"source archive"
    source.write("source")
    environment = { "ARCHIVE" => source.to_s, "DIGEST" => Digest::SHA256.hexdigest("source") }
    command = 'verify_checksum "$ARCHIVE" "$DIGEST"'
    _, error, status = run_shell(command, environment)
    assert_predicate status, :success?, error
    source.write("changed")
    _, _, status = run_shell(command, environment)
    refute_predicate status, :success?
  end
end
