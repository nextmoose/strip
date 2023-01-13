  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
          strip.url = "/home/runner/work/strip/strip" ;
          # test-utils.url = "/home/runner/work/strip/strip/base/test-versions" ;
          nixpkgs.url = "github:nixos/nixpkgs" ;
        } ;
      outputs =
        { self , flake-utils , strip , nixpkgs } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              let
                pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
                in
		  {
		    devShell = pkgs.mkShell { buildInputs = [ ( pkgs.writeShellScriptBin "test" "${ pkgs.coreutils }/bin/echo YES" ) ] ; } ;
		  }
              # builtins.getAttr
              #  system
              #  test-utils.lib
              #  strip
              #  { flake-utils = "5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ; }
          ) ;
    }
