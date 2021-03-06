require 'formula'

class Valgrind36 < Formula
  homepage 'http://www.valgrind.org/'
  url "http://valgrind.org/downloads/valgrind-3.6.1.tar.bz2"
  sha256 "6116ddca2708f56e0a2851bdfbe88e01906fa300"

  # Valgrind needs vcpreload_core-*-darwin.so to have execute permissions.
  # See #2150 for more information.
  skip_clean 'lib/valgrind'

  # 1: For Xcode-only systems, we have to patch hard-coded paths, use xcrun &
  #    add missing CFLAGS. See: https://bugs.kde.org/show_bug.cgi?id=295084
  # 2: Fix for 10.7.4 w/XCode-4.5, duplicate symbols. Reported upstream in
  #    https://bugs.kde.org/show_bug.cgi?id=307415
  patch do
    url "https://gist.githubusercontent.com/2bits/3784836/raw/f046191e72445a2fc8491cb6aeeabe84517687d9/patch1.diff"
    sha256 "a2252d977302a37873b0f2efe8aa4a4fed2eb2c2"
  end

  patch do
    url "https://gist.githubusercontent.com/2bits/3784930/raw/dc8473c0ac5274f6b7d2eb23ce53d16bd0e2993a/patch2.diff"
    sha256 "6e57aa087fafd178b594e22fd0e00ea7c0eed438"
  end if MacOS.version == :lion

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]
    if MacOS.prefer_64_bit?
      args << "--enable-only64bit" << "--build=amd64-darwin"
    else
      args << "--enable-only32bit"
    end

    system "./configure", *args
    system 'make'
    system "make install"
  end

  test do
    system "#{bin}/valgrind", "ls", "-l"
  end
end
