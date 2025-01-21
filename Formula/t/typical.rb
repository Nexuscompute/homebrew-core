class Typical < Formula
  desc "Data interchange with algebraic data types"
  homepage "https://github.com/stepchowfun/typical"
  url "https://github.com/stepchowfun/typical/archive/refs/tags/v0.12.1.tar.gz"
  sha256 "d7759bc05f011c915b54b359bcd9563d4b371703ccc57ea005142be6cd219e86"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia:  "c01cc1debef78935e3f85f11fd37d36bafe1d01004a2d2e25ea1da1f61389785"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "8ccf68539d6d557517d2e21fc4b9f7d7d7f507bb4092b2513dbd84843648a72a"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "63b48359d88032a38e54a7a8677046bb3af866d844ed640017e30ae19a9bbdbc"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "11ffb6008f6eb95c39678a6aba3d0a7ee483a0859ae9082a8999b2268743fd48"
    sha256 cellar: :any_skip_relocation, sonoma:         "7c9e1f6d5abe29582f533368446ef64a0041254ee3c381ce6618f597717199b7"
    sha256 cellar: :any_skip_relocation, ventura:        "290f31aa718a6c45651d3ff7745584ceaded134888422a4bf250739ac7b56de2"
    sha256 cellar: :any_skip_relocation, monterey:       "412157dc6a44b87200149f28895009843e956ab0b702b119b375db208fdf4005"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "54692b2545fc98b49f5bc3a8da38ef8eae24e0176b7b36695f96da39841be433"
  end

  depends_on "rust" => :build

  # eliminate needless lifetimes, upstream pr ref, https://github.com/stepchowfun/typical/pull/501
  patch :DATA

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    (testpath/"types.t").write <<~EOS
      struct SendEmailRequest {
          to: String = 0
          subject: String = 1
          body: String = 2
      }

      choice SendEmailResponse {
          success = 0
          error: String = 1
      }
    EOS

    assert_empty shell_output("#{bin}/typical generate types.t --rust types.rs --typescript types.ts")

    generated_rust_code = (testpath/"types.rs").read
    generated_typescript_code = (testpath/"types.ts").read

    assert_match "// This file was automatically generated by Typical", generated_rust_code
    assert_match "pub struct SendEmailRequestIn", generated_rust_code
    assert_match "pub struct SendEmailRequestOut", generated_rust_code
    assert_match "pub enum SendEmailResponseIn", generated_rust_code
    assert_match "pub enum SendEmailResponseOut", generated_rust_code
    assert_match "// This file was automatically generated by Typical", generated_typescript_code
    assert_match "export type SendEmailRequestIn", generated_typescript_code
    assert_match "export type SendEmailRequestOut", generated_typescript_code
    assert_match "export type SendEmailResponseIn", generated_typescript_code
    assert_match "export type SendEmailResponseOut", generated_typescript_code
  end
end

__END__
diff --git a/src/error.rs b/src/error.rs
index 4563e1e..213faf9 100644
--- a/src/error.rs
+++ b/src/error.rs
@@ -34,7 +34,7 @@ impl fmt::Display for Error {
 }

 impl error::Error for Error {
-    fn source<'a>(&'a self) -> Option<&(dyn error::Error + 'static)> {
+    fn source(&self) -> Option<&(dyn error::Error + 'static)> {
         self.reason.as_deref()
     }
 }
