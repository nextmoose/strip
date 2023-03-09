  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
	  shell.url = "github:nextmoose/shell" ;
        } ;
      outputs =
        { self , flake-utils , shell } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              {
                devShell =
		  {
		    lib =
		      hook : inputs :
		        let
			  scripts =
			    {
			      boot =
			        {
				} ;
			    } ;
			  in pkgs.mkShell { buildInputs = inputs ( scripts ) ; inputHook = hook ( scripts ) ; }
		  } ;
              }
      ) ;
    }
