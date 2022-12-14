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
                  test : versions :
                    {
                      devShell =
                        let
                          _test = builtins.getAttr system test.lib ;
                          _utils = builtins.getAttr system utils.lib ;
                          pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
                          mapper =
                            name : value :
                              let
                                input = builtins.getAttr name test.inputs ;
                                in
                                  builtins.toString ( pkgs.writeShellScript
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
                                    '' ) ;
                          in pkgs.mkShell
                            {
			      buildInputs = [ ( builtins.trace ( "YES - ${ builtins.typeOf versions } - ${ builtins.typeOf ( builtins.mapAttrs mapper versions ) } - ${ builtins.typeOf ( builtins.attrValues ( builtins.mapAttrs mapper versions ) ) } - ${ builtins.typeOf ( builtins.concatStringsSep " &&\n" ( builtins.attrValues ( builtins.mapAttrs mapper versions ) ) ) }\n\nBEFORE\n${ builtins.concatStringsSep " &&\n" ( builtins.attrValues ( builtins.mapAttrs mapper versions ) ) }\nAFTER" ) ( pkgs.writeShellScriptBin "test" "" ) ) ] ;
                              buildInputs2 =
                                [ ( pkgs.writeShellScriptBin "test" ( builtins.concatStringsSep " &&\n" ( builtins.attrValues ( builtins.mapAttrs mapper versions ) ) ) ) ] ;
                            } ;
                    } ;
              }
      ) ;
    }
