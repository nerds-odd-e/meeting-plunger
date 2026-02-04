{
  description = "Meeting Plunger - A monorepo with Python FastAPI backend and Golang CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Python with FastAPI and common dependencies
        pythonEnv = pkgs.python311.withPackages (ps: with ps; [
          fastapi
          uvicorn
          pydantic
          httpx
          pytest
          pytest-asyncio
          python-multipart
          python-dotenv
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Python environment
            pythonEnv
            
            # Golang
            go
            gotools  # Includes goimports
            air  # Go live reload
            
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
            echo "🚀 Meeting Plunger Development Environment"
            echo ""
            echo "Available tools:"
            echo "  Python:   $(python --version)"
            echo "  Go:       $(go version)"
            echo "  Node.js:  $(node --version)"
            echo "  pnpm:     $(pnpm --version)"
            echo ""
            echo "Quick start:"
            echo "  pnpm sut      # Start backend + client (both auto-reload)"
            echo "  pnpm e2e      # Run e2e tests"
            echo "  pnpm lint     # Lint all code"
            echo "  pnpm format   # Format all code"
            echo ""
            echo "First time setup:"
            echo "  pnpm install && pnpm e2e:install"
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
