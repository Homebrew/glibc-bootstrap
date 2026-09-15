# frozen_string_literal: true

require_relative "test_helper"

# Test publication against a local Git remote and a gh stub.
class ReleaseTest < BootstrapTest
  def setup
    super
    git("init", "--initial-branch=main")
    git("config", "user.name", "Test")
    git("config", "user.email", "test@example.invalid")
    git("config", "commit.gpgsign", "false")
    git("config", "tag.gpgsign", "false")
    git("config", "core.hooksPath", File::NULL)
    (@root/"state").write("first")
    git("add", "state")
    git("commit", "-m", "First")
    @first = git("rev-parse", "HEAD")
    (@root/"state").write("second")
    git("commit", "-am", "Second")
    @second = git("rev-parse", "HEAD")
    git("remote", "add", "origin", @root.to_s)
    @bin = @root/"bin"
    @bin.mkpath
    (@bin/"gh").write <<~'SH'
      #!/bin/bash
      printf "%s\n" "$@" > "$RELEASE_ARGUMENTS"
    SH
    (@bin/"gh").chmod(0755)
    (@root/"bootstrap-binaries").mkpath
    (@root/"bootstrap-binaries/example.tar.gz").write("fixture")
  end

  def git(*args)
    output, error, status = capture("git", "-C", @root.to_s, *args)
    raise error unless status.success?

    output.strip
  end

  def release(sha: @second, validate_only: false)
    capture(
      { "PATH" => "#{@bin}:#{ENV.fetch("PATH")}", "TAG" => "1.0.0", "GITHUB_SHA" => sha,
        "GITHUB_REPOSITORY" => "example/bootstrap", "RELEASE_ARGUMENTS" => (@root/"arguments").to_s },
      "bash", (ROOT/".github/scripts/release.sh").to_s, *(validate_only ? ["--validate-only"] : []),
      chdir: @root
    )
  end

  def test_new_tag_targets_built_commit_when_main_has_advanced
    git("checkout", "--detach", @first)
    _, error, status = release(sha: @first)
    assert_predicate status, :success?, error
    args = (@root/"arguments").read.lines(chomp: true)
    assert_equal @first, args.fetch(args.index("--target")+1)
    assert_includes args, "bootstrap-binaries/example.tar.gz"
  end

  def test_matching_lightweight_tag_is_accepted
    git("tag", "1.0.0")
    _, error, status = release
    assert_predicate status, :success?, error
  end

  def test_matching_annotated_tag_is_accepted
    git("tag", "-a", "1.0.0", "-m", "Release")
    _, error, status = release
    assert_predicate status, :success?, error
  end

  def test_tag_for_another_commit_is_rejected
    [false, true].each do |annotated|
      git("tag", "1.0.0", @first, *(annotated ? ["-a", "-m", "Earlier release"] : []))
      [false, true].each do |validate_only|
        _, _, status = release(validate_only: validate_only)
        refute_predicate status, :success?
        refute_path_exists @root/"arguments"
      end
      git("tag", "--delete", "1.0.0")
    end
  end

  def test_preflight_validates_without_publishing_and_publication_rechecks
    _, error, status = release(validate_only: true)
    assert_predicate status, :success?, error
    refute_path_exists @root/"arguments"
    git("tag", "1.0.0", @first)
    _, _, status = release
    refute_predicate status, :success?
    refute_path_exists @root/"arguments"
  end

  def test_remote_failure_prevents_publication
    git("remote", "set-url", "origin", (@root/"missing").to_s)
    _, _, status = release
    refute_predicate status, :success?
    refute_path_exists @root/"arguments"
  end

  def test_no_archives_prevents_publication
    (@root/"bootstrap-binaries/example.tar.gz").unlink
    _, _, status = release
    refute_predicate status, :success?
    refute_path_exists @root/"arguments"
  end

  def select_build(event, base, head)
    output = @root/"build-output"
    output.write("")
    _, error, status = capture(
      { "EVENT" => event, "BASE_SHA" => base, "HEAD_SHA" => head, "GITHUB_OUTPUT" => output.to_s },
      "bash", (ROOT/".github/scripts/select-build.sh").to_s, chdir: @root
    )
    assert_predicate status, :success?, error
    output.read
  end

  def test_build_selection_covers_shared_helpers_and_skips_docs
    [
      ["utils.sh", "true"],
      ["README.md", "false"],
      [".github/scripts/check-elf.rb", "true"],
    ].each do |filename, expected|
      base = git("rev-parse", "HEAD")
      path = @root/filename
      path.dirname.mkpath
      path.write("changed")
      git("add", filename)
      git("commit", "-m", "Change fixture")
      %w[pull_request push].each do |event|
        assert_equal "build=#{expected}\n", select_build(event, base, git("rev-parse", "HEAD"))
      end
    end
  end

  def test_missing_base_falls_back_to_full_build
    %w[pull_request push].each do |event|
      assert_equal "build=true\n", select_build(event, "1"*40, @second)
    end
  end

  def test_pr_selection_excludes_changes_only_on_base_branch
    (@root/"utils.sh").write("base branch change")
    git("add", "utils.sh")
    git("commit", "-m", "Change build helper on main")
    base = git("rev-parse", "HEAD")
    git("checkout", "--detach", @second)
    (@root/"README.md").write("docs-only PR")
    git("add", "README.md")
    git("commit", "-m", "Change docs on PR")
    head = git("rev-parse", "HEAD")
    assert_equal "build=false\n", select_build("pull_request", base, head)
    assert_equal "build=true\n", select_build("push", base, head)
  end

  def test_releases_and_initial_pushes_always_build
    %w[workflow_dispatch push].each do |event|
      assert_equal "build=true\n", select_build(event, "0"*40, @second)
    end
  end
end
