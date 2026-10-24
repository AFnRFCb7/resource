{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        config-identity ? x : x ,
                        implementation-identity ? x : x ,
                        lib-identity ? x : x ,
                        pkgs-identity ? x : x
                    } :
                        let
                            implementation =
                                { config , lib , ... } :
                                    let
                                        _config = config-identity config ;
                                        _lib = lib-identity lib ;
                                        in
                                            {
                                                options.lazy-shell-resource =
                                                    _lib.mkOption
                                                        {
                                                            default =
                                                                {
                                                                    gc-root-directory ,
                                                                    resources-directory
                                                                } :
                                                                    _config.lazy-shell-application
                                                                        {
                                                                            mounts =
                                                                                {
                                                                                    input = { is-directory = false ; source = "/mounts/input" ; type = "bind" ; } ;
                                                                                    gc-root = { is-directory = true ; source = gc-root-directory ; type = "bind" ; } ;
                                                                                    resources = { is-directory = true ; source = resources-directory ; type = "bind" ; } ;
                                                                                } ;
                                                                            name = "init" ;
                                                                            post = null ;
                                                                            runtime-inputs = pkgs : [ ( _config.failure { } ) pkgs.coreutils ] ;
                                                                            text =
                                                                                ''
                                                                                    HASH=$( cat /mounts/input | sha512sum | cut --bytes 1-128 ) || failure 9501307898608371
                                                                                    if [[ -d "/mounts/resources/canonical/$HASH" ]]
                                                                                    then
                                                                                        :
                                                                                    else
                                                                                        :
                                                                                    fi
                                                                                '' ;
                                                                        } ;
                                                            type = _lib.types.functionTo _lib.types.package ;
                                                        } ;
                                            } ;
                            in
                                {
                                    check = null ;
                                    implementation = implementation-identity implementation ;
                                } ;
            } ;
}