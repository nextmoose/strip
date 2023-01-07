  {
      inputs =
        {
          nixpkgs.url = "github:nixos/nixpkgs?rev=57eac89459226f3ec743ffa6bbbc1042f5836843" ;
          flake-utils.url = "github:numtide/flake-utils" ;
          strip.url = "/home/runner/work/strip/strip" ;
        } ;
      outputs =
        { self , nixpkgs , flake-utils , strip } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              {
                devShell =
                  let
                    pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
		    test = builtins.getAttr system strip.lib ;
		    in
 			pkgs.mkShell { buildInputs = [
				( pkgs.writeShellScriptBin "hello"
				  ''
				    ${ pkgs.coreutils }/bin/cat <EOF
				    Hello
				    ${ if test "A" == "A" then "YES" else "NO" }
				    EOF
				  ''
				)
			] ; };
              }
      ) ;
    }
