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
                                    if [ "${ strip.inputs.flake-utils.rev }" == "5aed5285a952e0b949eb3ba02c12fa4fcfef535fX" ]
                                    then
                                      ${ pkgs.coreutils }/bin/echo The flake-utils version is good ${ strip.inputs.flake-utils.rev }.
                                    else
                                      ${ pkgs.coreutils }/bin/echo The flake-utils version is bad.  We observed ${ strip.inputs.flake-utils.rev } but we expect 5aed5285a952e0b949eb3ba02c12fa4fcfef535f.  &&
                                      exit 64
                                    fi &&
                                    ${ pkgs.coreutils }/bin/cat <<EOF
                                    Hello
                                    ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs ( name : value : "${ name }" ) strip.inputs.flake-utils ) ) }
                                    BYE
                                    ${ strip.inputs.flake-utils.rev }
                                    ${ if test "A" == "A" then "YES" else "NO" }
                                    EOF
                                  ''
                                )
                        ] ; };
              }
      ) ;
    }
