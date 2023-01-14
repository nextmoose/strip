  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
          strip.url = "/home/runner/work/strip/strip" ;
          test-utils.url = "/home/runner/work/strip/strip/base/test-positives" ;
        } ;
      outputs =
        { self , nixpkgs , flake-utils , strip , test-utils } :
          flake-utils.lib.eachDefaultSystem
          (
            system :
              builtins.getAttr
                system
                test-utils.lib
                strip
                {
		  sad1 = { observed = "bad 1" ; expected = test : "${ test } null" ; } ;
		  sad2 = { observed = "bad 2" ; expected = test : "${ test } null" ; } ;
                }
          ) ;
    }
