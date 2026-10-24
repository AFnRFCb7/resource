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
                                                                { } :
                                                                    _config.lazy-shell-application
                                                                        {
                                                                            mounts = null ;
                                                                            name = "init" ;
                                                                            post = null ;
                                                                            runtime-inputs = pkgs : [ ] ;
                                                                            text =
                                                                                ''
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