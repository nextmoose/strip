  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
	  strip.url = "/home/runner/work/strip/strip" ;
	  update-utils.url = "/home/runner/work/strip/strip/base/update-versions" ;
        } ;
      outputs =
        { self , flake-utils , strip , update-utils } :
          flake-utils.lib.eachDefaultSystem
          (
            system : builtins.getAttr system test-utils.lib strip
          ) ;
    }
