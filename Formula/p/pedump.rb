class Pedump < Formula
  desc "Dump Windows PE files using Ruby"
  homepage "https://pedump.me"
  url "https://github.com/zed-0xff/pedump/archive/refs/tags/v0.6.10.tar.gz"
  sha256 "fd31800d4e1e6d3cf0116b9b1a5565cde4bfc684bea3bab5a39b58745b44c3f6"
  license "MIT"

  depends_on "ruby"

  def install
    ENV["GEM_HOME"] = libexec
    system "bundle", "config", "set", "without", "development"
    system "bundle", "install"
    system "gem", "build", "#{name}.gemspec"
    system "gem", "install", "--ignore-dependencies", "#{name}-#{version}.gem"
    bin.install libexec/"bin/#{name}"
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pedump --version")

    resource "notepad.exe" do
      url "https://github.com/zed-0xff/pedump/raw/master/samples/notepad.exe"
      sha256 "e4dce694ba74eaa2a781f7696c44dcb54fed5aad337dac473ac8a6b77291d977"
    end

    resource("notepad.exe").stage testpath
    assert_match "2008-04-13 18:35:51", shell_output("#{bin}/pedump --pe notepad.exe")
  end
end
