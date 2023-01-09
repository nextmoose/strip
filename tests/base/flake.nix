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
                  test : versions : positives : negatives :
                    {
                      devShell =
                        let
                          _test = builtins.getAttr system test.lib ;
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
					  ${ pkgs.coreutils }/bin/echo 4141181e-ff52-443b-921a-3564d212348c &&
                                          PROJECT_DIRECTORY=$( ${ pkgs.coreutils }/bin/pwd ) &&
					  ${ pkgs.coreutils }/bin/echo 42e3f28d-328d-4f5e-8919-6ffdbe89aaa8 &&
                                          cd $( ${ pkgs.mktemp }/bin/mktemp --directory ) &&
					  ${ pkgs.coreutils }/bin/echo 1ebabaa8-1c7d-4918-9a28-c2e4131f1f5a &&
                                          ${ pkgs.nix }/bin/nix flake init &&
					  ${ pkgs.coreutils }/bin/echo b2a86e6d-a4a0-4a69-b4d9-9a3f8b9294ee &&
					  ${ pkgs.coreutils }/bin/true
                                        '' ;
                                  in builtins.attrValues ( builtins.mapAttrs mapper negatives ) ;
                              negatives2 =
                                let
                                  mapper =
                                    name : value :
                                      pkgs.writeShellScript
                                        name
                                        ''
					  ${ pkgs.coreutils }/bin/echo 4141181e-ff52-443b-921a-3564d212348c &&
                                          PROJECT_DIRECTORY=$( ${ pkgs.coreutils }/bin/pwd ) &&
					  ${ pkgs.coreutils }/bin/echo 42e3f28d-328d-4f5e-8919-6ffdbe89aaa8 &&
                                          cd $( ${ pkgs.mktemp }/bin/mktemp --directory ) &&
					  ${ pkgs.coreutils }/bin/echo 1ebabaa8-1c7d-4918-9a28-c2e4131f1f5a &&
                                          ${ pkgs.nix }/bin/nix flake init &&
					  ${ pkgs.coreutils }/bin/echo b2a86e6d-a4a0-4a69-b4d9-9a3f8b9294ee &&
                                          ( ${ pkgs.coreutils }/bin/cat > flake.nix <<EOF
                                            {
                                              inputs = { flake-utils.url = "github:numtide/flake-utils" ; nixpkgs.url = "github:nixos/nixpkgs" ; testee.url = "${ _utils.bash-variable "PROJECT_DIRECTORY" }" ; } ;
                                              outputs =
                                                { flake-utils , nixpkgs , self , testee } :
                                                  flake-utils.lib.eachDefaultSystem
                                                    ( system : { lib = pkgs.makeShell { buildInputs = [ ( pkgs.writeShellScriptBin "negative" ${ value.observed "( builtins.getAttr system testee.lib )" } ) ] ; } ; } )
                                            }
                                          EOF
                                          ) &&
					  ${ pkgs.coreutils }/bin/echo 27813b3c-c068-4b34-ad23-7139d5d0fc5f &&
					  ${ pkgs.coreutils }/bin/echo BEGIN &&
					  ${ pkgs.coreutils }/bin/pwd &&
					  ${ pkgs.coreutils }/bin/cat flake.nix &&
					  ${ pkgs.coreutils }/bin/echo END &&
					  exit 64 &&
                                          OBSERVED="$( ${ pkgs.nix }/bin/nix develop --command negative 2> >( ${ pkgs.coreutils }/bin/tee ) )" &&
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
                                  in builtins.attrValues ( builtins.mapAttrs mapper negatives ) ;
                              positives =
                                let
                                  mapper =
                                    name : value :
                                      pkgs.writeShellScript
                                        name
                                        ''
                                          OBSERVED="${ value.observed _test }" &&
                                          EXPECTED="${ value.expected }" &&
                                          if [ "${ _utils.bash-variable "EXPECTED" }" == "${ _utils.bash-variable "OBSERVED" }" ]
                                          then
                                            ( ${ pkgs.coreutils }/bin/cat <<EOF
                                          #
                                          TEST="GOOD"
                                          TYPE="POSITIVE"
                                          NAME="${ name }"
                                          HASH="${ _utils.bash-variable "EXPECTED" }"
                                          EOF
                                            )
                                          else
                                            ( ${ pkgs.coreutils }/bin/cat <<EOF
                                          #
                                          TEST="BAD"
                                          TYPE="POSITIVE"
                                          NAME="${ name }"
                                          OBSERVED="${ _utils.bash-variable "OBSERVED" }"
                                          EXPECTED="${ _utils.bash-variable "EXPECTED" }"
                                          EOF
                                            ) &&
                                            exit 64
                                          fi
                                        '' ;
                                  in builtins.attrValues ( builtins.mapAttrs mapper positives ) ;
                              versions =
                                let
                                  mapper =
                                    name : value :
                                      let
                                        input = builtins.getAttr name test.inputs ;
                                        in
                                          pkgs.writeShellScript
                                            name
                                            ''
                                              OBSERVED="${ input.rev }" &&
                                              EXPECTED="${ value }" &&
                                              if [ "${ _utils.bash-variable "OBSERVED" }" == "${ _utils.bash-variable "EXPECTED" }" ]
                                              then
                                                ( ${ pkgs.coreutils }/bin/cat <<EOF
                                              #
                                              TEST="GOOD"
                                              TYPE="VERSION"
                                              NAME="${ name }"
                                              HASH="${ _utils.bash-variable "EXPECTED" }"
                                              EOF
                                                )
                                              else
                                                ( ${ pkgs.coreutils }/bin/cat <<EOF
                                              #
                                              TEST="GOOD"
                                              TYPE="VERSION"
                                              NAME="${ name }"
                                              OBSERVED="${ _utils.bash-variable "OBSERVED" }"
                                              EXPECTED="${ _utils.bash-variable "EXPECTED" }"
                                              EOF
                                                ) &&
                                                exit 64
                                              fi
                                            '' ;
                                  in builtins.attrValues ( builtins.mapAttrs mapper versions ) ;
                            } ;
                          in pkgs.mkShell
                            {
                              buildInputs = [ ( pkgs.writeShellScriptBin "hook" ( builtins.concatStringsSep " &&\n" ( builtins.concatLists [ programs.negatives programs.positives programs.versions ] ) ) ) ] ;
                            } ;
                    } ;
              }
      ) ;
    }
