class Ansible14 < Formula
  homepage "http://www.ansibleworks.com/"
  url "https://github.com/ansible/ansible/archive/v1.4.5.tar.gz"
  sha256 "61c35aad0d4ef668051652b8a5b84b6407016a5b1daa74b982889ff0fafddea0"

  bottle do
    sha256 "c7098fe56be7afc0c789337aeb209a9821ae3035" => :yosemite
    sha256 "f6d35bc75e6642567c2430f6c989fe5c4991ccb7" => :mavericks
    sha256 "e060a56c76c91cc0c7d524bcd2b3fb9774d183c5" => :mountain_lion
  end

  depends_on :python
  depends_on "libyaml"

  option "with-accelerate", "Enable accelerated mode"

  resource "pycrypto" do
    url "https://pypi.python.org/packages/source/p/pycrypto/pycrypto-2.6.tar.gz"
    sha256 "7293c9d7e8af2e44a82f86eb9c3b058880f4bcc884bf3ad6c8a34b64986edde8"
  end

  resource "pyyaml" do
    url "https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.10.tar.gz"
    sha256 "e713da45c96ca53a3a8b48140d4120374db622df16ab71759c9ceb5b8d46fe7c"
  end

  resource "paramiko" do
    url "https://pypi.python.org/packages/source/p/paramiko/paramiko-1.11.0.tar.gz"
    sha256 "d46fb8af4c4ffca3c55c600c17354c7c149d8c5dcd7cd6395f4fa0ce2deaca87"
  end

  resource "markupsafe" do
    url "https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.18.tar.gz"
    sha256 "b7d5d688bdd345bfa897777d297756688cf02e1b3742c56885e2e5c2b996ff82"
  end

  resource "jinja2" do
    url "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.1.tar.gz"
    sha256 "5cc0a087a81dca1c08368482fb7a92fe2bdd8cfbb22bc0fccfe6c85affb04c8b"
  end

  resource "python-keyczar" do
    url "https://pypi.python.org/packages/source/p/python-keyczar/python-keyczar-0.71b.tar.gz"
    sha256 "a23fd6ccb351e1e0d74484e2aadc39b5df793762c828614f09f35400e0cb1180"
  end

  def install
    ENV["PYTHONPATH"] = libexec/"vendor/lib/python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    %w[pycrypto pyyaml paramiko markupsafe jinja2].each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    if build.with? "accelerate"
      resource("python-keyczar").stage { system "python", *Language::Python.setup_install_args(libexec/"vendor") }
    end

    inreplace "lib/ansible/constants.py" do |s|
      s.gsub! "/usr/share/ansible", share+"ansible"
      s.gsub! "/etc/ansible", etc+"ansible"
    end

    # Needs to be in prefix still as ansible14 doesn't yet have:
    # https://github.com/Homebrew/homebrew/pull/22307
    system "python", *Language::Python.setup_install_args(prefix)
    man1.install Dir["docs/man/man1/*.1"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/ansible", "--version"
  end
end
