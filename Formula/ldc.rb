class Ldc < Formula
  desc "Portable D programming language compiler"
  homepage "https://wiki.dlang.org/LDC"
  revision 1

  stable do
    url "https://github.com/ldc-developers/ldc/releases/download/v1.11.0/ldc-1.11.0-src.tar.gz"
    sha256 "85464fae47bc605308910afd6cfc6ddeafe95a8ad5b61e2c0c23caff82119f70"
  end

  bottle do
    sha256 "614747501f8c18c48be99a35cad7c8d0cc387d23e34f061d6f372a0e0f9ce581" => :mojave
    sha256 "ab5b1cb9864886ad0f56ce5116c271042912724aa609004e7fbf52616c944a4a" => :high_sierra
    sha256 "fbc84d197eed292519c5dd4f7fd5ed90c116cf5ec8753d5488533149c007f6c7" => :sierra
  end

  head do
    url "https://github.com/ldc-developers/ldc.git", :shallow => false
  end

  depends_on "cmake" => :build
  depends_on "libconfig" => :build
  depends_on "llvm@6"

  needs :cxx11

  resource "ldc-bootstrap" do
    url "https://github.com/ldc-developers/ldc/releases/download/v1.11.0/ldc2-1.11.0-osx-x86_64.tar.xz"
    version "1.11.0"
    sha256 "18f85374854546b28a3dca12d3029aea4dac43a65b1835361c5e6f6c233762c8"
  end

  def install
    ENV.cxx11
    (buildpath/"ldc-bootstrap").install resource("ldc-bootstrap")

    mkdir "build" do
      args = std_cmake_args + %W[
        -DLLVM_ROOT_DIR=#{Formula["llvm@6"].opt_prefix}
        -DINCLUDE_INSTALL_DIR=#{include}/dlang/ldc
        -DD_COMPILER=#{buildpath}/ldc-bootstrap/bin/ldmd2
        -DLDC_WITH_LLD=OFF
        -DRT_ARCHIVE_WITH_LDC=OFF
      ]
      # LDC_WITH_LLD see https://github.com/ldc-developers/ldc/releases/tag/v1.4.0 Known issues
      # RT_ARCHIVE_WITH_LDC see https://github.com/ldc-developers/ldc/issues/2350

      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.d").write <<~EOS
      import std.stdio;
      void main() {
        writeln("Hello, world!");
      }
    EOS
    system bin/"ldc2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldc2", "-flto=thin", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldc2", "-flto=full", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldmd2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
  end
end
