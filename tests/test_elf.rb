# frozen_string_literal: true

require_relative "test_helper"

# Exercise the command-line checker with controlled readelf output.
class ElfCheckTest < BootstrapTest
  def setup
    super
    @unpacked = @root/"unpacked"
    @unpacked.mkpath
    (@unpacked/"binary").binwrite("\x7FELF")
    @bin = @root/"bin"
    @bin.mkpath
    (@bin/"readelf").write <<~SH
      #!/bin/bash
      cat "$READELF_OUTPUT"
      exit "${READELF_STATUS:-0}"
    SH
    (@bin/"readelf").chmod(0755)
    @output = @root/"readelf-output"
  end

  def check(architecture, output, readelf_status: "0")
    @output.write(output)
    capture(
      { "PATH" => "#{@bin}:#{ENV.fetch("PATH")}", "READELF_OUTPUT" => @output.to_s,
        "READELF_STATUS" => readelf_status },
      RbConfig.ruby, (ROOT/".github/scripts/check-elf.rb").to_s, architecture, @unpacked.to_s
    )
  end

  def test_accepts_documented_runtime_floors
    [["x86_64", "Advanced Micro Devices X86-64", "2.13"],
     ["arm64", "AArch64", "2.17"]].each do |arch, machine, version|
      output, error, status = check(arch, <<~ELF)
        Machine: #{machine}
        Name: GLIBC_2.2.5  Flags: none  Version: 3
        Name: GLIBC_#{version}  Flags: none  Version: 2
        Name: GLIBCXX_3.4.30  Flags: none  Version: 4
      ELF
      assert_predicate status, :success?, error
      assert_includes output, "Checked 1 ELF files for #{arch}"
    end
  end

  def test_rejects_newer_runtime_requirements
    [
      ["x86_64", "Advanced Micro Devices X86-64", "2.14"],
      ["x86_64", "Advanced Micro Devices X86-64", "2.13.1"],
      ["x86_64", "Advanced Micro Devices X86-64", "2.100"],
      ["arm64", "AArch64", "2.18"],
    ].each do |arch, machine, version|
      _, error, status = check(arch, "Machine: #{machine}\nName: GLIBC_#{version}  Flags: none\n")
      refute_predicate status, :success?
      assert_includes error, "requires glibc #{version}"
    end
  end

  def test_rejects_unrecognized_glibc_requirements
    [["x86_64", "Advanced Micro Devices X86-64", "2.13"],
     ["arm64", "AArch64", "2.17"]].each do |arch, machine, version|
      %w[GLIBC_ABI_DT_RELR GLIBC_PRIVATE GLIBC_2.2.5_UNKNOWN GLIBC_].each do |requirement|
        _, error, status = check(arch, <<~ELF)
          Machine: #{machine}
          Name: GLIBC_#{version}  Flags: none  Version: 2
          Name: #{requirement}  Flags: none  Version: 3
        ELF
        refute_predicate status, :success?
        assert_includes error, "Unrecognized glibc requirement #{requirement}"
      end
    end
  end

  def test_rejects_wrong_or_missing_architecture
    ["Machine: AArch64\n", ""].each do |header|
      _, error, status = check("x86_64", header)
      refute_predicate status, :success?
      assert_includes error, "Unexpected architecture"
    end
  end

  def test_readelf_failure_is_not_ignored
    _, error, status = check("x86_64", "Machine: Advanced Micro Devices X86-64\n", readelf_status: "1")
    refute_predicate status, :success?
    assert_includes error, "readelf failed"
  end

  def test_requires_elf_contents_and_ignores_symlinks
    outside = @root/"external-elf"
    outside.binwrite("\x7FELF")
    File.symlink(outside, @unpacked/"link")
    (@unpacked/"binary").write("not an ELF file")
    _, error, status = check("x86_64", "Machine: Advanced Micro Devices X86-64\n")
    refute_predicate status, :success?
    assert_includes error, "No ELF binaries"
  end
end
