  {
      inputs =
        {
          nixpkgs.url = "github:nixos/nixpkgs" ;
          flake-utils.url = "github:numtide/flake-utils" ;
	  shell.url = "github:nextmoose/shell" ;
        } ;
      outputs =
        { self , nixpkgs , flake-utils , shell } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              {
                devShell =
		  builtins.getAttr
		    system
		    shell.lib
		    nixpkgs
		    (
		      structure :
		        {
			  welcome = "${ structure.pkgs.coreutils }/bin/echo Welcome!!!" ;
			  program3 = "${ structure.pkgs.coreutils }/bin/echo constant=31bca02094eb78126a517b206a88c73cfa9ec6f704c7030d18212cace820f025f00bf0ea68dbf3f3a5436ca63b53bf7bf80ad8d5de7d8359d0b7fed9dbc3ab99" ;
			  
			}
		    )
		    ( scripts : scripts.program2 ) ;
              }
      ) ;
    }
