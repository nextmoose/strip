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
                  test :
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
                                      ( ${ pkgs.coreutils }/bin/cat <<EOF
                                      _ 
                                      NAME=${ name }
                                      ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs ( n : v : "${ n } = ${ if builtins.typeOf v == "string" then v else "NOT A STRING" }" ) value ) ) }
                                      _ inputs 			   
                                      ${ builtins.concatStringsSep "\n" ( builtins.attrNames value.inputs ) }
                                      _ lib
                                      ${ builtins.concatStringsSep "\n" ( builtins.attrNames value.lib ) }
                                      _ sourceInfo
                                      ${ builtins.concatStringsSep "\n" ( builtins.attrNames value.sourceInfo ) }
                                      _ templates 
                                      ${ builtins.concatStringsSep "\n" ( builtins.attrNames value.templates ) }
				      -- ${ value.sourceInfo.outPath }
                                      EOF
                                      )
                                    '' ) ;
                          in pkgs.mkShell
                            {
                              buildInputs = [ ( pkgs.writeShellScriptBin "check" ( builtins.concatStringsSep " &&\n" ( builtins.attrValues ( builtins.mapAttrs mapper test.inputs ) ) ) ) ] ;
                            } ;
                    } ;
              }
      ) ;
    }
