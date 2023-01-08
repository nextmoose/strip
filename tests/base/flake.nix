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
                                        "name"
                                        ''
					  PROJECT_DIRECTORY=$( ${ pkgs.coreutils }/bin/pwd ) &&
                                          cd $( ${ pkgs.mktemp }/bin/mktemp --directory ) &&
                                          ${ pkgs.nix }/bin/nix flake init &&
                                          ( ${ pkgs.coreutils }/bin/cat > flake.nix <<EOF
                                            {
                                              inputs = { flake-utils.url = "github:numtide/flake-utils" ; nixpkgs.url = "github:nixos/nixpkgs" ; testee.url = "${ _utils.bash-variable "PROJECT_DIRECTORY" }" ; } ;
                                              outputs =
                                                { flake-utils , nixpkgs , self , testee } :
						  flake-utils.lib.eachDefaultSystem
						    ( system : { lib = pkgs.makeShell { inputHooks = "${ pkgs.coreutils }/bin/echo ${ value.observed "( builtins.getAttr system testee.lib )" } " ; } ; } )
                                            }
                                          EOF
                                          ) &&
                                          OBSERVED="$( ${ pkgs.nix }/bin/nix develop 2> >( ${ pkgs.coreutils }/bin/tee ) )" &&
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
                                  in builtins.attrValues ( builtins.mapAttrs mapper negatives ) ;
                              positives =
                                let
                                  mapper =
                                    name : value :
                                      pkgs.writeShellScript
                                        "name"
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
