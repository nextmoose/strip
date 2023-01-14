  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
          nixpkgs.url = "github:nixos/nixpkgs" ;
        } ;
      outputs =
        { self , flake-utils , nixpkgs } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              let
                pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
                in
		  {
		    devShell = pkgs.mkShell { buildInputs = [ ( pkgs.writeShellScriptBin "check" "${ pkgs.coreutils }/bin/echo PASSED" ) pkgs.coreutils ] ; } ;
		  }
          ) ;
    }
