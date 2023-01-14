  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
          nixpkgs.url = "github:nixos/nixpkgs" ;
          utils.url = "github:nextmoose/utils" ;
        } ;
      outputs =
        { self , flake-utils , nixpkgs , utils } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              {
                lib =
                  negatives :
                    {
                      devShell =
                        let
                          _utils = builtins.getAttr system utils.lib ;
                          pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
                          mapper =
                            name : value :
                              pkgs.writeShellScript
                                name
                                ''
                                  cd $( ${ pkgs.coreutils }/bin/mktemp --directory ) &&
                                  ${ pkgs.nix }/bin/nix flake init &&
                                  ( ${ pkgs.coreutils }/bin/cat > flake.nix <<EOF
                                  {
                                    input = { flake-utils.url = "github:numtide/flake-utils" ; nixpkgs.url = "github:nixos/nixpckgs" ; test = "" ; } ;
                                    output =
                                      { self , flake-utils , nixpkgs } :
                                      flake-utils.lib.eachDefaultSystem
                                        (
                                          system :
                                            let
                                              pkgs = builtins.getAttr system nixpkgs.defaultPackages ;
                                              in pkgs.mkShell { buildInputs = [ ( pkgs.writeShellScriptBin "check" ${ value.observed "test" } ) ] ; }
                                        )
                                  }
                                  EOF
                                  ) &&
                                  ! OBSERVED="$( ${ pkgs.nix }/nix develop --command check )" &&
                                  EXPECTED="${ value.expected }" &&
                                  if [ "${ _utils.bash-variable "EXPECTED" }" == "${ _utils.bash-variable "OBSERVED" }" ]
                                  then
                                    ( ${ pkgs.coreutils }/bin/cat <<EOF
                                  #
                                  TEST="GOOD"
                                  TYPE="NEGATIVE"
                                  NAME="${ name }"
                                  HASH="${ _utils.bash-variable "EXPECTED" }"
                                  EOF
                                    )
                                  else
                                    ( ${ pkgs.coreutils }/bin/cat <<EOF
                                  #
                                  TEST="BAD"
                                  TYPE="NEGATIVE"
                                  NAME="${ name }"
                                  OBSERVED="${ _utils.bash-variable "OBSERVED" }"
                                  EXPECTED="${ _utils.bash-variable "EXPECTED" }"
                                  EOF
                                    ) &&
                                    exit 64
                                  fi
                                '' ;
                          in pkgs.mkShell
                            {   
                              buildInputs =
                                [ ( pkgs.writeShellScriptBin "check" ( builtins.concatStringsSep " &&\n" ( builtins.attrValues ( builtins.mapAttrs mapper negatives ) ) ) ) ] ;
                            } ;
                    } ;
              }
      ) ;
    }
