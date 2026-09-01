{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "cli-proxy-api";
  version = "7.2.125";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    rev = "v${version}";
    hash = "sha256-Gv21kDHX/28/ujg4QLiWdmJRX/6El8NgeqMWw7WzOG8=";
  };

  vendorHash = "sha256-CrDp7MOr+AwJUhTovklXx3F1yaktQlvD7VYhYSY6VvY=";

  subPackages = [ "cmd/server" ];

  ldflags = [ "-s" "-w" ];

  postInstall = ''
    mv $out/bin/server $out/bin/cli-proxy-api
  '';

  meta = with lib; {
    description = "OpenAI/Gemini/Claude/Codex compatible API proxy over CLI OAuth logins";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = licenses.mit;
    mainProgram = "cli-proxy-api";
  };
}
