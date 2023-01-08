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
                (
                  test :
                    {
                      happy = test "c41f3ec5-a370-4fce-9b87-63203e0cdd2a" ;
                    }
                )
                (
                  test : [ ]
                )
                (
                  programs :
                    [
                      ( programs.positives.happy "c41f3ec5-a370-4fce-9b87-63203e0cdd2a" )
		      ( programs.versions.flake-utils "5aed5285a952e0b949eb3ba02c12fa4fcfef535f" )
                    ]
                )
          ) ;
    }
