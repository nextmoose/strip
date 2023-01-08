  {
      inputs =
        {
          flake-utils.url = "github:numtide/flake-utils" ;
          strip.url = "/home/runner/work/strip/strip" ;
          test-utils.url = "/home/runner/work/strip/strip/tests/base" ;
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
                  happy1 = { observed = test : test "c41f3ec5-a370-4fce-9b87-63203e0cdd2a" ; expected = "c41f3ec5-a370-4fce-9b87-63203e0cdd2a" ; } ;
                  happy2 = { observed = test : test "d87b11cc-ed4f-41e6-92b6-fc48371dd5c8" ; expected = "d87b11cc-ed4f-41e6-92b6-fc48371dd5c8" ; } ;
                }
                (
                  test : [ ]
                )
                (
                  programs :
                    [
		      programs.positives.happy1
                    ]
                )
          ) ;
    }
