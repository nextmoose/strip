  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
	  strip.url = "/home/runner/work/strip/strip" ;
	  test-utils.url = "/home/runner/work/strip/strip/base/test-versions" ;
        } ;
      outputs =
        { self , flake-utils , strip , test-utils } :
          flake-utils.lib.eachDefaultSystem
    }
