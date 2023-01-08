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
                                  in builtins.attrValues ( builtins.mapAttrs mapper positives ) ;
                              versions =
                                let
                                  mapper =
                                    name : value :
                                      let
                                        input = builtins.getAttr name test.inputs ;
                                        in
                                          pkgs.writeShellScriptBin
                                            name
                                            ''
                                              OBSERVED="${ input.rev }" &&
                                              EXPECTED="${ value }" &&
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
                                              fi
                                            '' ;
                                  in builtins.attrValues ( builtins.mapAttrs mapper versions ) ;
                            } ;
                          in pkgs.mkShell
                            {
                              buildInputs = [ ( pkgs.writeShellScriptBin "hook" ( builtins.concatStringsSep " &&\n" ( builtins.concatLists [ programs.positives programs.versions ] ) ) ) ] ;
                            } ;
                    } ;
              }
      ) ;
    }
