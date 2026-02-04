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
            
            # Node.js and pnpm for e2e tests
            nodejs_22
            nodePackages.pnpm
            
            # Playwright dependencies
            playwright-driver.browsers
            
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
            echo "  pnpm sut      # Start backend + client"
            echo "  pnpm e2e      # Run e2e tests"
            echo ""
            echo "First time setup:"
            echo "  pnpm install && pnpm e2e:install"
            echo ""
            echo "More info: QUICK_START.md"
            
            # Set Playwright browsers path
            export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
            export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
          '';
        };
      }
    );
}
