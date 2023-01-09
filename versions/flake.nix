  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
          strip.url = "/home/runner/work/strip/strip" ;
        } ;
      outputs =
        { self , nixpkgs , flake-utils , strip , test-utils } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              let
	        pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
		in pkgs.makeShell { buildInputs = [ ( pkgs.writeShellScriptBin "hook" "${ pkgs.coreutils }/bin/echo HI" ) ] ; } ;
          ) ;
    }
