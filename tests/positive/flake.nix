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
                                    if [ "${ strip.inputs.flake-utils.rev }" == "5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ]
                                    then
                                      ${ pkgs.coreutils }/bin/echo The flake-utils version is good ${ strip.inputs.flake-utils.rev }.
                                    else
                                      ${ pkgs.coreutils }/bin/echo The flake-utils version is bad.  We observed ${ strip.inputs.flake-utils.rev } but we expect 5aed5285a952e0b949eb3ba02c12fa4fcfef535f.  &&
                                      exit 64
                                    fi &&
				    if [ "${ builtins.getAttr system strip.lib "    ca6fed9d-abcd-4c90-9a24-a79abb9b212f   " }" == "ca6fed9d-abcd-4c90-9a24-a79abb9b212fX" ]
				    then
				      ${ pkgs.coreutils }/bin/echo The test is good ca6fed9d-abcd-4c90-9a24-a79abb9b212f &&
				    else
				      ${ pkgs.coreutils }/bin/echo The test is bad.  We observed ${ builtins.getAttr system strip.lib "   ca6fed9d-abcd-4c90-9a24-a79abb9b212f   " } but we expect ca6fed9d-abcd-4c90-9a24-a79abb9b212f. &&
				      exit 64
				    fi &&
                                  ''
                                )
                        ] ; };
              }
      ) ;
    }
