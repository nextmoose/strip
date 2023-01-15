  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
          test-utils.url = "/home/runner/work/strip/strip/base/test-negatives" ;
        } ;
      outputs =
        { self , nixpkgs , flake-utils , test-utils } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              builtins.getAttr
                system
                test-utils.lib
                {
		  sad1 = { observed = test : "${ test } null" ; expected = "668ec04c-a40c-45bc-b66d-de439acf4384" ; } ;
                }
          ) ;
    }
