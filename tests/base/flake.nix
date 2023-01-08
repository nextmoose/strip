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
                  test : positives : negatives :
                    {
                      devShell =
                        let
                          _utils = builtins.getAttr system utils.lib ;
                          pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
                          program =
			    {
                              positives =
                                let
                                  mapper =
                                    name : value :
                                      pkgs.writeShellScript
                                        "name"
                                        ''
                                          OBSERVED="${ value.observed ( builtins.getAttr system test.lib ) }" &&
                                          EXPECTED="${ value.expected }" &&
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
                                  in builtins.attrNames ( builtins.mapAttrs mapper positives ) ;
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
                              buildInputs = [ ( builtins.writeShellScriptBin "hook" ( builtins.concatStringsSep " &&\n" ( builtins.concatLists [ positives ] ) ) ) ] ;
                            } ;
                    } ;
              }
      ) ;
    }
