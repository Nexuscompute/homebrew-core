class Rtags < Formula
  desc "Source code cross-referencer like ctags with a clang frontend"
  homepage "https://github.com/Andersbakken/rtags"
  url "https://github.com/Andersbakken/rtags.git",
      :tag => "v2.20",
      :revision => "baf121831ab5b1a40f6e0b3c2771a6238a94414c"
  head "https://github.com/Andersbakken/rtags.git"

  bottle do
    sha256 "5df322b2ae2f63dc38477dfa105ba8ef8c22efb5b63fea9ec2854fba260008d6" => :mojave
    sha256 "dd57b486974f18f520739dfadbcb3498044f6b5d8cb66ca245e233fae4664fd1" => :high_sierra
    sha256 "2b24a0e6d371991240b1511a9e5286be429936a14d369540b5712457402bc2b8" => :sierra
    sha256 "93f92e94bceedb27ca8a96954d2d528ad75f489d30b933b1587bbcd25937e4e8" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "emacs"
  depends_on "llvm"
  depends_on "openssl"

  def install
    # Homebrew llvm libc++.dylib doesn't correctly reexport libc++abi
    ENV.append("LDFLAGS", "-lc++abi")

    args = std_cmake_args << "-DRTAGS_NO_BUILD_CLANG=ON"

    if MacOS.version == "10.11" && MacOS::Xcode.installed? && MacOS::Xcode.version >= "8.0"
      args << "-DHAVE_CLOCK_MONOTONIC_RAW:INTERNAL=0"
      args << "-DHAVE_CLOCK_MONOTONIC:INTERNAL=0"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/bin/rdm --verbose --inactivity-timeout=300 --log-file=#{HOMEBREW_PREFIX}/var/log/rtags.log"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{bin}/rdm</string>
        <string>--verbose</string>
        <string>--launchd</string>
        <string>--inactivity-timeout=300</string>
        <string>--log-file=#{var}/log/rtags.log</string>
      </array>
      <key>Sockets</key>
      <dict>
        <key>Listener</key>
        <dict>
          <key>SockPathName</key>
          <string>#{ENV["HOME"]}/.rdm</string>
        </dict>
      </dict>
    </dict>
    </plist>
  EOS
  end

  test do
    mkpath testpath/"src"
    (testpath/"src/foo.c").write <<~EOS
      void zaphod() {
      }

      void beeblebrox() {
        zaphod();
      }
    EOS
    (testpath/"src/README").write <<~EOS
      42
    EOS

    rdm = fork do
      $stdout.reopen("/dev/null")
      $stderr.reopen("/dev/null")
      exec "#{bin}/rdm", "--exclude-filter=\"\"", "-L", "log"
    end

    begin
      sleep 1
      pipe_output("#{bin}/rc -c", "clang -c #{testpath}/src/foo.c", 0)
      sleep 1
      assert_match "foo.c:1:6", shell_output("#{bin}/rc -f #{testpath}/src/foo.c:5:3")
      system "#{bin}/rc", "-q"
    ensure
      Process.kill 9, rdm
      Process.wait rdm
    end
  end
end
