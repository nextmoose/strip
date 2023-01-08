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
                  test : positives : negatives : hook :
                    {
                      devShell =
                        let
                          _utils = builtins.getAttr system utils.lib ;
                          pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
                          programs =
                            {
                              negatives =
                                let
                                  mapper =
                                    name : value :
                                      pkgs.writeShellScript
                                        name
                                        ''
                                          PROJECT_DIRECTORY=$( ${ pkgs.coreutils }/bin/pwd ) &&
                                          cd $( ${ pkgs.mktemp }/bin/mktemp --directory ) &&
                                          ${ pkgs.nix }/bin/nix flake init &&
                                          ( ${ pkgs.coreutils }/bin/cat > flake.nix <<EOF
                                            {
                                              inputs =
                                                {
                                                  flake-utils.url = "github:numtide/flake-utils" ;
                                                  nixpkgs.url = "github:nixos/nixpkgs" ;
                                                  testee.url = "${ _utils.bash-variable "PROJECT_DIRECTORY" }" ;
                                                } ;
                                              outputs =
                                                { flake-utils,  nixpkgs , self , testee } : { devShell = pkgs.mkShell { buildInputs = [ ( pkgs.writeShellScriptBin "negative" value ) ] ; } ; }
                                            }
                                          EOF
                                          ) &&
                                          OBSERVED="$( ${ pkgs.nix }/bin/nix develop 2> >( ${ pkgs.coreutils }/bin/tee ) ) &&
                                          EXPECTED="${ _utils.bash-variable "1" }" &&
                                          if [ "${ _utils.bash-variable "EXPECTED" }" == "${ _utils.bash-variable "OBSERVED" }" ]
                                          then
                                            ( ${ pkgs.coreutils }/bin/cat <<EOF
                                           POSITIVE="GOOD"
                                           NAME="${ name }"
                                          HASH="${ _utils.bash-variable "EXPECTED" }"
                                          EOF
                                            )
                                          else
                                            ( ${ pkgs.coreutils }/bin/cat <<EOF
                                          POSITIVE="BAD"
                                          NAME="${ name }"
                                          OBSERVED="${ _utils.bash-variable "OBSERVED" }"
                                          EXPECTED="${ _utils.bash-variable "EXPECTED" }"
                                          EOF
                                            ) &&
                                            exit 64
                                          fi
                                        '' ;
                                  in builtins.mapAttrs mapper ( negatives ( builtins.getAttr system test.lib ) ) ;
                              positives =
                                let
                                  mapper =
                                    name : value :
                                      pkgs.writeShellScript
                                        "name"
                                        ''
                                          OBSERVED="${ value test }" &&
                                          EXPECTED="${ _utils.bash-variable "1" }" &&
                                          if [ "${ _utils.bash-variable "EXPECTED" }" == "${ _utils.bash-variable "OBSERVED" }" ]
                                          then
                                            ( ${ pkgs.coreutils }/bin/cat <<EOF
                                           POSITIVE="GOOD"
                                           NAME="${ name }"
                                          HASH="${ _utils.bash-variable "EXPECTED" }"
                                          EOF
                                            )
                                          else
                                            ( ${ pkgs.coreutils }/bin/cat <<EOF
                                          POSITIVE="BAD"
                                          NAME="${ name }"
                                          OBSERVED="${ _utils.bash-variable "OBSERVED" }"
                                          EXPECTED="${ _utils.bash-variable "EXPECTED" }"
                                          EOF
                                            ) &&
                                            exit 64
                                          fi
                                        '' ;
                                  in builtins.mapAttrs mapper ( positives ( builtins.getAttr system test.lib ) ) ;
                              versions =
                                let
                                  mapper =
                                    name : value :
                                      pkgs.writeShellScriptBin
                                        name
                                        ''
                                          OBSERVED="${ value.rev }" &&
                                          EXPECTED="${ _utils.bash-variable "1" }" &&
                                          if [ "${ _utils.bash-variable "OBSERVED" }" == "${ _utils.bash-variable "EXPECTED" }" ]
                                          then
                                            ( ${ pkgs.coreutils }/bin/cat <<EOF
                                          VERSION="GOOD"
                                          NAME="${ name }"
                                          HASH="${ _utils.bash-variable "EXPECTED" }"
                                          EOF
                                            )
                                          else
                                            ( ${ pkgs.coreutils }/bin/cat <<EOF
                                          VERSION="BAD"
                                          NAME="${ name }"
                                          OBSERVED="${ _utils.bash-variable "OBSERVED" }"
                                          EXPECTED="${ _utils.bash-variable "EXPECTED" }"
                                          EOF
                                            ) &&
                                            exit 64
                                        '' ;
                                  in builtins.mapAttrs mapper test ;
		            } ;
                          in pkgs.mkShell
                            {
                              buildInputs = [ ( pkgs.writeShellScriptBin "hook" ( builtins.concatStringsSep " &&\n" ( hook programs ) ) ) ] ;
                            } ;
                    } ;
              }
      ) ;
    }
