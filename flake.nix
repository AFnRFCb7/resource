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
                                                                                    invalid-init = { is-directory = true ; source = "${ resources-directory }/invalid-init" ; type = "bind" ; } ;
                                                                                    invalid-release = { is-directory = true ; source = "${ resources-directory }/invalid-release" ; type = "bind" ; } ;
                                                                                    input = { is-directory = false ; source = "/mounts/input" ; type = "bind" ; } ;
                                                                                    gc-root = { is-directory = true ; source = gc-root-directory ; type = "bind" ; } ;
                                                                                    locks = { is-directory = true ; source = "${ resources-directory }/locks" ; type = "bind" ; } ;
                                                                                    mounts = { is-directory = true ; source = "${ resources-directory }/mounts" ; type = "bind" ; } ;
                                                                                    pids = { is-directory = true ; source = "${ resources-directory }/pids" ; type = "bind" ; } ;
                                                                                    release = { source = "${ resources-directory }/release" ; type = "bind" ; } ;
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
                                                                                            let
                                                                                                action = builtins.attrValue "action" ( identity init ) ;
                                                                                                expected-targets = builtins.sort ( a : b : a < b ) ( _config.visitor { string = path : value : value ; } ( identity init ) ) ;
                                                                                                identity =
                                                                                                    {
                                                                                                        action ? null ,
                                                                                                        recovery ? null ,
                                                                                                        targets ? null
                                                                                                    } :
                                                                                                        {
                                                                                                            action = action ;
                                                                                                            recovery = recovery ;
                                                                                                            targets = targets ;
                                                                                                        } ;
                                                                                                release =
                                                                                                    _config.lazy-shell-application
                                                                                                        {
                                                                                                            mounts = { input = { is-directory = false ; source = "/mount/input" ; type = "bind" ; } } ;
                                                                                                            name = "release" ;
                                                                                                            post = null ;
                                                                                                            runtime-inputs = pkgs : [ ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                in
                                                                                                    _config.visitor
                                                                                                        { }
                                                                                                        {
                                                                                                            lambda =
                                                                                                                path : value :
                                                                                                                    _config.lazy-shell-application
                                                                                                                        {
                                                                                                                            mounts =
                                                                                                                                {
                                                                                                                                    mount = { source = "/mounts/mount/$INDEX" ; type = "bind" ; } ;
                                                                                                                                    standard-error = { is-directory = false ; type = "temporary" ; } ;
                                                                                                                                    standard-output = { is-directory = false ; type = "temporary" ; } ;
                                                                                                                                } ;
                                                                                                                            name = "init" ;
                                                                                                                            runtime-inputs =
                                                                                                                                pkgs :
                                                                                                                                    [
                                                                                                                                        pkgs.coreutils
                                                                                                                                        pkgs.jq
                                                                                                                                        (
                                                                                                                                            let
                                                                                                                                                identity =
                                                                                                                                                    {
                                                                                                                                                        runtime-inputs ? pkgs : [ ] ,
                                                                                                                                                        text ? ""
                                                                                                                                                    } :
                                                                                                                                                        {
                                                                                                                                                            runtime-inputs = runtime-inputs ;
                                                                                                                                                            text = text ;
                                                                                                                                                        } ;
                                                                                                                                                in
                                                                                                                                                    _config.lazy-shell-application
                                                                                                                                                        {
                                                                                                                                                            mounts = { release = { source = "/mounts/release" ; type = "bind" ; } ; } ;
                                                                                                                                                            name = "init" ;
                                                                                                                                                            post = null ;
                                                                                                                                                            runtime-inputs = builtins.getAttr "text" ( identity ( value null ) ) ;
                                                                                                                                                            text = builtins.getAttr "text" ( identity ( value null ) ) ;
                                                                                                                                                        }
                                                                                                                                        )
                                                                                                                                    ] ;
                                                                                                                            text =
                                                                                                                                ''
                                                                                                                                    mapfile -t ARGUMENTS < <( jq -r '.arguments[]' /mounts/input )
                                                                                                                                    if jq --exit-status 'has("inputs") and (.inputs | has("standard"))' /mounts/input
                                                                                                                                    then
                                                                                                                                        if jq ".inputs.standard" | init "${ "$" }{ARGUMENTS[@]}" /mounts/input > /mounts/standard-input 2> /mounts/standard-error
                                                                                                                                        then
                                                                                                                                            STATUS="$?"
                                                                                                                                        else
                                                                                                                                            STATUS="$?"
                                                                                                                                        fi
                                                                                                                                    else
                                                                                                                                        if init "${ "$" }{ARGUMENTS[@]}" > /mounts/standard-input 2> /mounts/standard-error
                                                                                                                                        then
                                                                                                                                            STATUS="$?"
                                                                                                                                        else
                                                                                                                                            STATUS="$?"
                                                                                                                                        fi
                                                                                                                                    fi
                                                                                                                                    cat /mounts/standard-output
                                                                                                                                    cat /mounts/standard-error >&2
                                                                                                                                    OBSERVED_TARGETS="$( find /mounts/mount -mindepth 1 -maxdepth 1 | LC_ALL=C sort )" || failure 5101453011608943
                                                                                                                                    if [[ "$STATUS" == 0 ]] && [[ -s /mounts/standard-error ]] && [[ '${ expected-targets }' == "$OBSERVED_TARGETS" ]]
                                                                                                                                    then
                                                                                                                                        ln --symbolic ${ release }/bin/release /mounts/release/$INDEX
                                                                                                                                    elif [[ "$STATUS" != 0 ]]
                                                                                                                                    then
                                                                                                                                        failure 9853943334807469
                                                                                                                                    elif [[ ! -s /mounts/standard-error ]]
                                                                                                                                    then
                                                                                                                                        failure 7230516165710518
                                                                                                                                    elif [[ '${ expected-targets }' != "$OBSERVED_TARGETS" ]]
                                                                                                                                    then
                                                                                                                                        failure 3004874158363809
                                                                                                                                    else
                                                                                                                                        failure 1309415748011104
                                                                                                                                    fi
                                                                                                                                '' ;
                                                                                                                        } ;
                                                                                                            null =
                                                                                                                path : value :
                                                                                                                    _config.lazy-shell-application
                                                                                                                        {
                                                                                                                            mounts = { release = { source = "/mounts/release" ; type = "bind" ; } ; } ;
                                                                                                                            name = "init" ;
                                                                                                                            runtimeInputs = [ ] ;
                                                                                                                            text =
                                                                                                                                ''
                                                                                                                                    ln --symbolic ${ release }/bin/release /mounts/release/$INDEX
                                                                                                                                '' ;
                                                                                                                        } ;
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
                                                                                        export INDEX
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