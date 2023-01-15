  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
	  strip.url = "/home/runner/work/strip/strip" ;
	  update-utils.url = "/home/runner/work/strip/strip/base/update-versions" ;
        } ;
      outputs =
        { self , flake-utils , strip , test-utils } :
          flake-utils.lib.eachDefaultSystem
          (
            system : builtins.getAttr system update-utils.lib strip {  flake-utils = "5aed5285a952e0b949eb3ba02c12fa4fcfef535f" ; }
          ) ;
    }
