  {
      inputs =
        {
          nixpkgs.url = "github:nixos/nixpkgs?rev=57eac89459226f3ec743ffa6bbbc1042f5836843" ;
          flake-utils.url = "github:numtide/flake-utils" ;
        } ;
      outputs =
        { self , nixpkgs , flake-utils } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              {
                devShell =
                  let
                    pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
		    in
 			pkgs.mkShell { buildInputs = [
				( pkgs.writeShellScriptBin "hello" "${ pkgs.coreutils }/bin/echo Hello" )
			] ; };
              }
      ) ;
    }
