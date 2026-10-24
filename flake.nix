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
                                                                            runtime-inputs =
                                                                                pkgs :
                                                                                    [
                                                                                        ( _config.failure { } )
                                                                                        ( _config.sequential { } )
                                                                                        pkgs.coreutils
                                                                                        pkgs.flock
                                                                                    ] ;
                                                                            text =
                                                                                ''
                                                                                    PID="$( sequential )" || failure 3708670955636569
                                                                                    HASH=$( cat /mounts/input | sha512sum | cut --bytes 1-128 ) || failure 9501307898608371
                                                                                    exec 169> "/mounts/resources/$HASH.lock"
                                                                                    flock -x 169
                                                                                    if [[ -L "/mounts/resources/canonical/$HASH" ]]
                                                                                    then
                                                                                        MOUNT="$( readlink "/mounts/resources/canonical/$HASH" )" || failure 9157868575302544
                                                                                        INDEX="$( basename "$MOUNT" )" || failure 3489407146167789
                                                                                        mkdir --parents "/mounts/resources/pids/$INDEX"
                                                                                        echo "$PID" > "/mounts/resources/pids/$INDEX/$PID"
                                                                                        chmod 0400 "/mounts/resources/pids/$INDEX/$PID"
                                                                                        echo "$INDEX"
                                                                                    else
                                                                                        INDEX="$( sequential )" || failure 6590902953585183
                                                                                        MOUNT="/mounts/resources/mounts/$INDEX"
                                                                                        mkdir --parents "$MOUNT"
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