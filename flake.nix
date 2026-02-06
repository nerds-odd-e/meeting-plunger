{
  description = "Meeting Plunger - A monorepo with Python FastAPI backend and Golang local-service";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Python (dependencies managed via pip + venv)
            python311
            
            # Golang
            go
            gotools  # Includes goimports
            gopls    # Go language server (for IDE support)
            air  # Go live reload
            oapi-codegen  # OpenAPI code generator for Go
            
            # Node.js and pnpm for e2e tests
            nodejs_22
            nodePackages.pnpm
            
            # Linting and formatting tools
            golangci-lint    # Go linter
            ruff             # Python formatter and linter
            
            # Development tools
            git
            
            # Optional but useful
            curl
            jq
          ];

          shellHook = ''
            # Add (nix) prefix to prompt
            if [[ "$PS1" != *"(nix)"* ]]; then
              export PS1="(nix) $PS1"
            fi

            # Activate Python venv if it exists
            if [ -d .venv ]; then
              source .venv/bin/activate
            fi

            echo "🚀 Meeting Plunger Development Environment"
            echo ""
            echo "Available tools:"
            echo "  Python:   $(python --version)"
            echo "  Go:       $(go version)"
            echo "  Node.js:  $(node --version)"
            echo "  pnpm:     $(pnpm --version)"
            echo ""
            echo "Quick start:"
            echo "  pnpm sut      # Start backend + local-service (both auto-reload)"
            echo "  pnpm e2e      # Run e2e tests"
            echo "  pnpm lint     # Lint all code"
            echo "  pnpm format   # Format all code"
            echo ""
            echo "First time setup:"
            echo "  pnpm install && pnpm e2e:install"
            echo "  python -m venv .venv && source .venv/bin/activate && pip install -r backend/requirements.txt"
            echo ""
            echo "More info: docs/QUICK_START.md"
            
            # Note: Playwright will manage its own browsers via 'pnpm exec playwright install'
            # We don't use Nix's playwright-driver.browsers to avoid version mismatches
            export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
          '';
        };
      }
    );
}
