{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-23.05";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };
  outputs = { self, nixpkgs, pre-commit-hooks }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      unreproduciblePackages.${system} = {
        # [ref:unavailable_page]
        unavailablePage = builtins.fetchurl {
          url = "https://vine.co/MyUserName";
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
      };

      checks.${system}.pre-commit = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixpkgs-fmt.enable = true;
          tagref.enable = true;
        };
      };


      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pre-commit-hooks.packages.${system};
          [
            nixpkgs-fmt
            tagref
          ];

        shellHooks = self.checks.${system}.pre-commit.shellHook;
      };

    };
}
