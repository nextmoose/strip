  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils?rev=5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ;
        } ;
      outputs =
        { self , flake-utils } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              {
                lib =
		  let
		    strip =
		      string :
		        let
			  append = builtins.substring 1 m string ;
			  is-appended = is-whitespace ( builtins.substring m 1 string ) ;
			  is-prepended = is-whitespace ( builtins.substring 0 1 string ) ;
			  is-whitespace = character : builtins.any ( w : w == character ) whitespace ;
			  n = builtins.stringLength string ;
			  m = n - 1 ;
			  prepend = builtins.substring 0 m string ;
		          whitespace = [ " " "\t" "\n" "\r" "\v" ] ;
			  in if builtins.typeOf string == "string" then if is-prepended then strip append else if is-appended then strip prepend else string else builtins.throw "668ec04c-a40c-45bc-b66d-de439acf4384" ;
		    in string : strip string ;
              }
      ) ;
    }
