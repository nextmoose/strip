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
		  sad1 = { expected = "bad 1" ; observed = test : "${ test } null" ; } ;
                }
          ) ;
    }
