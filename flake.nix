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
                                                                    error ,
                                                                    init ,
                                                                    gc-root-directory ,
                                                                    release ,
                                                                    resources-directory
                                                                } @primary :
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
                                                                                            _config.lazy-shell-application
                                                                                                {
                                                                                                    name = "valid-init" ;
                                                                                                    post = null ;
                                                                                                    runtime-inputs = pkgs : [ ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                        '' ;
                                                                                                }
                                                                                        )
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
                                                                                                            recovery =
                                                                                                                _config.visitor
                                                                                                                    { }
                                                                                                                    {
                                                                                                                        lambda =
                                                                                                                            path : value :
                                                                                                                                let
                                                                                                                                    identity =
                                                                                                                                        {
                                                                                                                                            runtime-inputs ? null ,
                                                                                                                                            text ? null
                                                                                                                                        } :
                                                                                                                                            {
                                                                                                                                                runtime-inputs = runtime-inputs ;
                                                                                                                                                text = text ;
                                                                                                                                            } ;
                                                                                                                                    in
                                                                                                                                        _config.lazy-shell-application
                                                                                                                                            {
                                                                                                                                                mounts =
                                                                                                                                                    {
                                                                                                                                                        input = { is-directory = true ; read-only = true ; source = "/mounts/input" ; type = "bind" ; } ;
                                                                                                                                                        invalid-init = { is-directory = true ; source = "/mounts/invalid-init" ; type = "bind" ; } ;
                                                                                                                                                        release = { is-directory = true ; source = "/mounts/release" ; type = "bind" ; } ;
                                                                                                                                                        standard-error = { is-directory = false ; type = "temporary" ; } ;
                                                                                                                                                        standard-output = { is-directory = false ; type = "temporary" ; } ;
                                                                                                                                                    } ;
                                                                                                                                                name = "invalid-init" ;
                                                                                                                                                runtime-inputs =
                                                                                                                                                    pkgs :
                                                                                                                                                        [
                                                                                                                                                            pkgs.coreutils
                                                                                                                                                            pkgs.jq
                                                                                                                                                            (
                                                                                                                                                                _config.lazy-shell-application
                                                                                                                                                                    {
                                                                                                                                                                        mounts = { } ;
                                                                                                                                                                        name = "recover" ;
                                                                                                                                                                        post = null ;
                                                                                                                                                                        runtime-inputs = builtins.getAttrs "runtime-inputs" ( identity ( value null ) ) ;
                                                                                                                                                                        text = builtins.getAttrs "text" ( identity ( value null ) ) ;
                                                                                                                                                                    }
                                                                                                                                                            )
                                                                                                                                                        ] ;
                                                                                                                                                text =
                                                                                                                                                    ''
                                                                                                                                                        mapfile -t ARGUMENTS < <( jq -r '.arguments[]' /mounts/input )
                                                                                                                                                        if jq --exit-status 'has("inputs") and (.inputs | has("standard"))' /mounts/input
                                                                                                                                                        then
                                                                                                                                                            if jq ".inputs.standard" | recovery "${ "$" }{ARGUMENTS[@]}" /mounts/input > /mounts/standard-input 2> /mounts/standard-error
                                                                                                                                                            then
                                                                                                                                                                STATUS="$?"
                                                                                                                                                            else
                                                                                                                                                                STATUS="$?"
                                                                                                                                                            fi
                                                                                                                                                        else
                                                                                                                                                            if recovery "${ "$" }{ARGUMENTS[@]}" > /mounts/standard-input 2> /mounts/standard-error
                                                                                                                                                            then
                                                                                                                                                                STATUS="$?"
                                                                                                                                                            else
                                                                                                                                                                STATUS="$?"
                                                                                                                                                            fi
                                                                                                                                                        fi
                                                                                                                                                        if [[ "$STATUS" == 0 ]] && [[ -n /mounts/standard-error ]]
                                                                                                                                                        then
                                                                                                                                                            rm --recursive --force /mounts/invalid-init/$INDEX
                                                                                                                                                            ln --symbolic ${ release }/bin/release /mounts/release
                                                                                                                                                        elif [[ "$STATUS" != 0 ]]
                                                                                                                                                        then
                                                                                                                                                            failure 1047459860543198 "$STATUS"
                                                                                                                                                        elif [[ ! -n /mounts/standard-error ]]
                                                                                                                                                        then
                                                                                                                                                            failure 7398286386269768
                                                                                                                                                        else
                                                                                                                                                            failure 7006188970373349
                                                                                                                                                        fi
                                                                                                                                                    '' ;
                                                                                                                                            } ;
                                                                                                                        null =
                                                                                                                            path : value :
                                                                                                                                _config.lazy-shell-application
                                                                                                                                    {
                                                                                                                                        mounts =
                                                                                                                                            {
                                                                                                                                                invalid-init = { is-directory = true ; source = "/mounts/invalid-init" ; type = "bind" ; } ;
                                                                                                                                                release = { is-directory = true ; source = "/mounts/release" ; type = "bind" ; } ;
                                                                                                                                            } ;
                                                                                                                                        name = "invalid-init" ;
                                                                                                                                        post = null ;
                                                                                                                                        runtime-inputs = pkgs : [ pkgs.coreutils ] ;
                                                                                                                                        text =
                                                                                                                                            ''
                                                                                                                                                rm --recursive --force /mounts/invalid-init/$INDEX
                                                                                                                                                ln --symbolic ${ release }/bin/release /mounts/release
                                                                                                                                            '' ;
                                                                                                                                    } ;
                                                                                                                    }
                                                                                                                    { default = null ; specified = recovery ; } ;
                                                                                                            targets = targets ;
                                                                                                        } ;
                                                                                                release =
                                                                                                    _config.lazy-shell-application
                                                                                                        {
                                                                                                            mounts = { input = { is-directory = false ; source = "/mount/input" ; type = "bind" ; } ; } ;
                                                                                                            name = "release" ;
                                                                                                            post = null ;
                                                                                                            runtime-inputs = pkgs : [ ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                valid-init =
                                                                                                    _config.lazy-shell-application
                                                                                                        {
                                                                                                            mounts = { } ;
                                                                                                            name = "valid-init" ;
                                                                                                            post = null ;
                                                                                                            runtime-inputs = pkgs : [ pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                '' ;
                                                                                                        }
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
                                                                                                                                        (
                                                                                                                                            _config.lazy-shell-application
                                                                                                                                                {
                                                                                                                                                    mounts = { invalid-init = { source = "/mounts/invalid-init" ; type = "bind" ; } ; } ;
                                                                                                                                                    name = "invalid-init" ;
                                                                                                                                                    post = null ;
                                                                                                                                                    runtime-inputs = pkgs : [ ( _config.failure { } ) ] ;
                                                                                                                                                    text =
                                                                                                                                                        ''
                                                                                                                                                            failure "$@"
                                                                                                                                                        '' ;
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
                                                                                                                                        invalid-init 7230516165710518
                                                                                                                                    elif [[ '${ expected-targets }' != "$OBSERVED_TARGETS" ]]
                                                                                                                                    then
                                                                                                                                        invalid-init 3004874158363809
                                                                                                                                    else
                                                                                                                                        invalid-init 1309415748011104
                                                                                                                                    fi
                                                                                                                                '' ;
                                                                                                                        } ;
                                                                                                            null =
                                                                                                                path : value :
                                                                                                                    _config.lazy-shell-application
                                                                                                                        {
                                                                                                                            mounts = { release = { source = "/mounts/release" ; type = "bind" ; } ; } ;
                                                                                                                            name = "init" ;
                                                                                                                            runtimeInputs = [ valid-init ] ;
                                                                                                                            text =
                                                                                                                                ''
                                                                                                                                    valid-init
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
                                                                                        rm "/mounts/locks/$HASH"
                                                                                    else
                                                                                        INDEX="$( sequential )" || failure 6590902953585183
                                                                                        export INDEX
                                                                                        MOUNT="/mounts/mounts/$INDEX"
                                                                                        mkdir --parents "$MOUNT"
                                                                                        if init
                                                                                        then
                                                                                            valid-init
                                                                                            echo -n "${ resources-directory }/mounts/$INDEX"
                                                                                            rm "/mounts/locks/$HASH"
                                                                                        else
                                                                                            invalid-init
                                                                                            echo -n "${ resources-directory }/mounts/$INDEX"
                                                                                            rm "/mounts/locks/$HASH"
                                                                                            exit ${ builtins.toString error }
                                                                                        fi
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