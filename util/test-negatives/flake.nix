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
		  sad1 = { observed = "bad 1" ; expected = test : "${ test } null" ; } ;
		  sad2 = { observed = "bad 2" ; expected = test : "${ test } null" ; } ;
                }
          ) ;
    }
