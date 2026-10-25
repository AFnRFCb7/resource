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
                                                                    init ,
                                                                    gc-root-directory ,
                                                                    release ,
                                                                    resources-directory
                                                                } :
                                                                    _config.lazy-shell-application
                                                                        {
                                                                            mounts =
                                                                                {
                                                                                    canonical = { is-directory = true ; source = "${ resources-directory }/canonical" ; type = "bind" ; } ;
                                                                                    input = { is-directory = false ; source = "/mounts/input" ; type = "bind" ; } ;
                                                                                    gc-root = { is-directory = true ; source = gc-root-directory ; type = "bind" ; } ;
                                                                                    locks = { is-directory = true ; source = "${ resources-directory }/locks" ; type = "bind" ; } ;
                                                                                    mounts = { is-directory = true ; source = "${ resources-directory }/mounts" ; type = "bind" ; } ;
                                                                                    pids = { is-directory = true ; source = "${ resources-directory }/pids" ; type = "bind" ; } ;
                                                                                } ;
                                                                            name = "init" ;
                                                                            post = ''rm "${ resources-directory }/pids/$PID"'' ;
                                                                            runtime-inputs =
                                                                                pkgs :
                                                                                    [
                                                                                        ( _config.failure { } )
                                                                                        ( _config.sequential { } )
                                                                                        pkgs.coreutils
                                                                                        pkgs.flock
                                                                                        (
                                                                                            pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "init" ;
                                                                                                    runtimeInputs = [ ] ;
                                                                                                    text =
                                                                                                        let
                                                                                                            identity =
                                                                                                                {
                                                                                                                    init ? null ,
                                                                                                                    recovery
                                                                                                                } :
                                                                                                                    {
                                                                                                                        init = init ;
                                                                                                                        recovery = recovery ;
                                                                                                                    } ;
                                                                                                            in
                                                                                                                ''
                                                                                                                '' ;
                                                                                                }
                                                                                        )
                                                                                    ] ;
                                                                            text =
                                                                                ''
                                                                                    PID="$( sequential )" || failure 3708670955636569
                                                                                    HASH=$( cat /mounts/input | sha512sum | cut --bytes 1-128 ) || failure 9501307898608371
                                                                                    exec 169> "/mounts/locks/$HASH"
                                                                                    flock -x 169
                                                                                    if [[ -L "/mounts/canonical/$HASH" ]]
                                                                                    then
                                                                                        MOUNT="$( readlink "/mounts/canonical/$HASH" )" || failure 9157868575302544
                                                                                        INDEX="$( basename "$MOUNT" )" || failure 3489407146167789
                                                                                        mkdir --parents "/mounts/pids/$INDEX"
                                                                                        echo "$PID" > "/mounts/pids/$INDEX/$PID"
                                                                                        chmod 0400 "/mounts/pids/$INDEX/$PID"
                                                                                        echo -n "${ resources-directory }/mounts/$INDEX"
                                                                                    else
                                                                                        INDEX="$( sequential )" || failure 6590902953585183
                                                                                        MOUNT="/mounts/mounts/$INDEX"
                                                                                        mkdir --parents "$MOUNT"
                                                                                        init
                                                                                        ln --symbolic "$MOUNT" /mounts/canonical/$HASH"
                                                                                        echo -n "${ resources-directory }/mounts/$INDEX"
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