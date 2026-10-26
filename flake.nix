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
                                                                    gc-roots-directory ,
                                                                    release ,
                                                                    resources-directory
                                                                } @primary :
                                                                {
                                                                    error ,
                                                                    name
                                                                } :
                                                                    _config.lazy-shell-application
                                                                        {
                                                                            mounts =
                                                                                {
                                                                                    canonical = { is-directory = true ; source = "${ resources-directory }/canonical" ; type = "bind" ; } ;
                                                                                    diagnostic = { source = "${ resources-directory }/diagnostic" ; } ;
                                                                                    flag = { is-directory = true ; source = "${ resources-directory }/flag" ; type = "bind" ; } ;
                                                                                    invalid-init = { is-directory = true ; source = "${ resources-directory }/invalid-init" ; type = "bind" ; } ;
                                                                                    invalid-release = { is-directory = true ; source = "${ resources-directory }/invalid-release" ; type = "bind" ; } ;
                                                                                    input = { is-directory = false ; source = "/mounts/input" ; type = "bind" ; } ;
                                                                                    gc-root = { is-directory = true ; source = gc-roots-directory ; type = "bind" ; } ;
                                                                                    locks = { is-directory = true ; source = "${ resources-directory }/locks" ; type = "bind" ; } ;
                                                                                    mounts = { is-directory = true ; source = "${ resources-directory }/mounts" ; type = "bind" ; } ;
                                                                                    pids = { is-directory = true ; source = "${ resources-directory }/pids" ; type = "bind" ; } ;
                                                                                    release = { source = "${ resources-directory }/release" ; type = "bind" ; } ;
                                                                                } ;
                                                                            name = name ;
                                                                            post = null ;
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
                                                                                                invalid-init =
                                                                                                    _config.lazy-shell-application
                                                                                                        {
                                                                                                            mounts =
                                                                                                                {
                                                                                                                    invalid-init = { source = "/mounts/invalid-init" ; type = "bind" ; } ;
                                                                                                                } ;
                                                                                                            name = "invalid-init" ;
                                                                                                            post = null ;
                                                                                                            runtime-inputs = pkgs : [ ( _config.failure { } ) _config.wrap pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                let
                                                                                                                    recovery =
                                                                                                                        _config.visitor
                                                                                                                            { }
                                                                                                                            {
                                                                                                                                lambda =
                                                                                                                                    path : value : ignore :
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
                                                                                                                                                                diagnostic = { source = "${ resources-directory }/diagnostic/$INDEX" ; type = "bind" ; } ;
                                                                                                                                                                input = { is-directory = true ; read-only = true ; source = "/mounts/input" ; type = "bind" ; } ;
                                                                                                                                                                invalid-init = { is-directory = true ; source = "${ resources-directory }/mounts/invalid-init" ; type = "bind" ; } ;
                                                                                                                                                                release = { is-directory = true ; source = "${ resources-directory }/mounts/release" ; type = "bind" ; } ;
                                                                                                                                                                standard-error = { is-directory = false ; type = "temporary" ; } ;
                                                                                                                                                                standard-output = { is-directory = false ; type = "temporary" ; } ;
                                                                                                                                                            } ;
                                                                                                                                                        name = "invalid-init" ;
                                                                                                                                                        runtime-inputs =
                                                                                                                                                            pkgs :
                                                                                                                                                                [
                                                                                                                                                                    invalid-init
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
                                                                                                                                                                    valid-init
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
                                                                                                                                                                    valid-init
                                                                                                                                                                elif [[ "$STATUS" != 0 ]]
                                                                                                                                                                then
                                                                                                                                                                    invalid-init old 1047459860543198 "$STATUS"
                                                                                                                                                                elif [[ ! -n /mounts/standard-error ]]
                                                                                                                                                                then
                                                                                                                                                                    invalid-init old 7398286386269768
                                                                                                                                                                else
                                                                                                                                                                    invalid-init old 7006188970373349
                                                                                                                                                                fi
                                                                                                                                                            '' ;
                                                                                                                                                        variables = { } ;
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
                                                                                                                                                variables = { } ;
                                                                                                                                            } ;
                                                                                                                            }
                                                                                                                            { default = null ; specified = recovery ; } ;
                                                                                                                    in
                                                                                                                        ''
                                                                                                                            PROVENANCE="$1"
                                                                                                                            if [[ "$PROVENANCE" == "new" ]]
                                                                                                                            then
                                                                                                                                ${ builtins.concatStringsSep "\n" ( _config.visitor { } { lambda = path : value : let x = value null ; in ''wrap ${ x } /mounts/invalid-init/${ builtins.toJSON path }/recovery.sh 0500 --replace INDEX "$INDEX"'' ; } recovery ) }
                                                                                                                            else
                                                                                                                                failure 4666519411676571
                                                                                                                            fi
                                                                                                                            failure "$@"
                                                                                                                        '' ;
                                                                                                            variables = { } ;
                                                                                                        } ;
                                                                                                identity =
                                                                                                    {
                                                                                                        action ? null ,
                                                                                                        recovery ? null ,
                                                                                                        targets ? null
                                                                                                    } :
                                                                                                        {
                                                                                                            action = action ;
                                                                                                            targets = targets ;
                                                                                                        } ;
                                                                                                valid-init =
                                                                                                    _config.lazy-shell-application
                                                                                                        {
                                                                                                            mounts =
                                                                                                                {
                                                                                                                    diagnostic = { source = "/mounts/diagnostic" ; type = "bind" ; } ;
                                                                                                                    release = { source = "/mounts/release" ; type = "bind" ; } ;
                                                                                                                } ;
                                                                                                            name = "valid-init" ;
                                                                                                            post =
                                                                                                                let
                                                                                                                    application =
                                                                                                                        _config.lazy-shell-application
                                                                                                                            {
                                                                                                                                mounts = { release = { source = "${ resources-directory }/release" ; type = "bind" ; } ; } ;
                                                                                                                                name = "post" ;
                                                                                                                                post = null ;
                                                                                                                                pkgs =
                                                                                                                                    pkgs :
                                                                                                                                        [

                                                                                                                                        ] ;
                                                                                                                                text =
                                                                                                                                    ''
                                                                                                                                        "/release/$INDEX" ;
                                                                                                                                    '' ;
                                                                                                                                variables = { } ;
                                                                                                                            } ;
                                                                                                                    in "${ application }/bin/post" ;
                                                                                                            runtime-inputs = pkgs : [ _config.wrap pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                let
                                                                                                                    release =
                                                                                                                        let
                                                                                                                            identity =
                                                                                                                                {
                                                                                                                                    action ? null ,
                                                                                                                                    recovery ? null
                                                                                                                                } :
                                                                                                                                    {
                                                                                                                                        action = action ;
                                                                                                                                        recovery = recovery ;
                                                                                                                                    } ;
                                                                                                                            in
                                                                                                                                _config.lazy-shell-application
                                                                                                                                    {
                                                                                                                                        mounts =
                                                                                                                                            {
                                                                                                                                                flag = { source = "${ resources-directory }/flag" ; type = "bind" ; } ;
                                                                                                                                                pid = { source = "${ resources-directory }/pid" ; type = "bind" ; } ;
                                                                                                                                            } ;
                                                                                                                                        name = "release" ;
                                                                                                                                        post = null ;
                                                                                                                                        runtime-inputs = pkgs : [ pkgs.coreutils pkgs.findutils pkgs.flock pkgs.gnutar pkgs.xz ] ;
                                                                                                                                        text =
                                                                                                                                            ''
                                                                                                                                                while [[ -f /mounts/flag/$INDEX ]]
                                                                                                                                                do
                                                                                                                                                    rm "/mounts/flag/$INDEX"
                                                                                                                                                    find /mounts/pid/$INDEX -mindepth 1 -maxdepth 1 | while read -r PID_FILE
                                                                                                                                                    do
                                                                                                                                                        while [[ -f "$PID_FILE" ]]
                                                                                                                                                        do
                                                                                                                                                            sleep 1
                                                                                                                                                        done
                                                                                                                                                    done
                                                                                                                                                    EXPECTED="${ resources-directory }/mounts/$INDEX"
                                                                                                                                                    find /mounts/gc-roots -type L | while read -r CANDIDATE
                                                                                                                                                    do
                                                                                                                                                        OBSERVED="$( readlink "$CANDIDATE" )" || failure 6653347034509208
                                                                                                                                                        if [[ "$EXPECTED" == "$OBSERVED" ]]
                                                                                                                                                        then
                                                                                                                                                            while [[ -L "$CANDIDATE" ]]
                                                                                                                                                            do
                                                                                                                                                                sleep 1
                                                                                                                                                            done
                                                                                                                                                        fi
                                                                                                                                                    done
                                                                                                                                                    exec 196> "/mounts/lock/$INDEX"
                                                                                                                                                    flock -x 196
                                                                                                                                                    if [[ -f "/mounts/flag/$INDEX" ]]
                                                                                                                                                    then
                                                                                                                                                        flock -u 196
                                                                                                                                                    else
                                                                                                                                                        FILES=(
                                                                                                                                                            "/mounts/gc-roots/$INDEX"
                                                                                                                                                            "/mounts/diagnostic/$INDEX"
                                                                                                                                                            "/mounts/flag/$INDEX"
                                                                                                                                                            "/mounts/lock/$INDEX"
                                                                                                                                                            "/mounts/mounts/$INDEX"
                                                                                                                                                            "/mounts/pid/$INDEX"
                                                                                                                                                            "/mounts/release/$INDEX"
                                                                                                                                                        )
                                                                                                                                                        ARCHIVE_FILE="$( mktemp --suffix ".tar.xz" --dry-run /mounts/temporary/XXXXXXXX )" || failure 9874147964151582
                                                                                                                                                        tar --create --xz --file "$ARCHIVE_FILE" "${ "$" }{FILES[@]}"
                                                                                                                                                        rm --recursive --force "${ "$" }{FILES[@]}"
                                                                                                                                                    fi
                                                                                                                                                done
                                                                                                                                            '' ;
                                                                                                                                        variables = { } ;
                                                                                                                                    } ;
                                                                                                                    in
                                                                                                                        ''
                                                                                                                            wrap ${ release }/bin/release /mounts/release/$INDEX --replace INDEX "$INDEX"
                                                                                                                        '' ;
                                                                                                            variables = { } ;
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
                                                                                                                            post = null ;
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
                                                                                                                                                            variables = { } ;
                                                                                                                                                        }
                                                                                                                                        )
                                                                                                                                        invalid-init
                                                                                                                                        valid-init
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
                                                                                                                                        valid-init
                                                                                                                                    elif [[ "$STATUS" != 0 ]]
                                                                                                                                    then
                                                                                                                                        invalid-init new 9853943334807469 "$STATUS"
                                                                                                                                    elif [[ ! -s /mounts/standard-error ]]
                                                                                                                                    then
                                                                                                                                        invalid-init new 7230516165710518
                                                                                                                                    elif [[ '${ expected-targets }' != "$OBSERVED_TARGETS" ]]
                                                                                                                                    then
                                                                                                                                        invalid-init new 3004874158363809
                                                                                                                                    else
                                                                                                                                        invalid-init new 1309415748011104
                                                                                                                                    fi
                                                                                                                                '' ;
                                                                                                                            variables = { } ;
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
                                                                                                                            variables = { } ;
                                                                                                                        } ;
                                                                                                        }
                                                                                        )
                                                                                    ] ;
                                                                            text =
                                                                                ''
                                                                                    PID="$( sequential )" || failure 3708670955636569
                                                                                    HASH=$( cat /mounts/input | sha512sum | cut --bytes 1-128 ) || failure 9501307898608371
                                                                                    exec 169> "/mounts/lock/$HASH"
                                                                                    flock -x 169
                                                                                    if [[ -L "/mounts/canonical/$HASH" ]]
                                                                                    then
                                                                                        MOUNT="$( readlink "/mounts/canonical/$HASH" )" || failure 9157868575302544
                                                                                        INDEX="$( basename "$MOUNT" )" || failure 3489407146167789
                                                                                        touch "/mounts/flag/$INDEX"
                                                                                        mkdir --parents "/mounts/pid/$INDEX"
                                                                                        echo "$PID" > "/mounts/pid/$INDEX/$PID"
                                                                                        chmod 0400 "/mounts/pid/$INDEX/$PID"
                                                                                        echo -n "${ resources-directory }/mounts/$INDEX"
                                                                                        rm "/mounts/lock/$HASH"
                                                                                    else
                                                                                        INDEX="$( sequential )" || failure 6590902953585183
                                                                                        export INDEX
                                                                                        touch "/mounts/flag/$INDEX"
                                                                                        MOUNT="/mounts/mounts/$INDEX"
                                                                                        mkdir --parents "$MOUNT"
                                                                                        if init
                                                                                        then
                                                                                            echo -n "${ resources-directory }/mounts/$INDEX"
                                                                                            rm "/mounts/lock/$HASH"
                                                                                        else
                                                                                            echo -n "${ resources-directory }/mounts/$INDEX"
                                                                                            rm "/mounts/lock/$HASH"
                                                                                            exit ${ builtins.toString error }
                                                                                        fi
                                                                                    fi
                                                                                '' ;
                                                                            variables = { } ;
                                                                        } ;
                                                            type = _lib.types.functionTo _lib.types.package ;
                                                        } ;
                                            } ;
                            in
                                {
                                    check =
                                        {
                                            failure ,
                                            lazy-shell-application ,
                                            nixosTest ,
                                            obviated-by ,
                                            trip ,
                                            visitor
                                        } :
                                        {
                                            init ,
                                            gc-roots-directory ,
                                            release ,
                                            resources-directory
                                        } :
                                        {
                                            error ,
                                            name
                                        } :
                                        commands :
                                            {
                                                obviated-by = obviated-by ;
                                                test =
                                                    nixosTest
                                                        {
                                                            name = "nixos-test" ;
                                                            nodes.client =
                                                                { config , pkgs , ... } :
                                                                    let
                                                                        _config = config-identity config ;
                                                                        _pkgs = pkgs-identity pkgs ;
                                                                        in
                                                                            {
                                                                                config.environment.systemPackages =
                                                                                    let
                                                                                        generator =
                                                                                            index :
                                                                                                let
                                                                                                    command = builtins.elemAt commands index ;
                                                                                                    transform =
                                                                                                        {
                                                                                                            command ,
                                                                                                            standard-error ,
                                                                                                            standard-output ,
                                                                                                            status
                                                                                                        } :
                                                                                                            _pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "command-${ builtins.toString index }" ;
                                                                                                                    runtimeInputs =
                                                                                                                        [
                                                                                                                            ( _config.failure { } )
                                                                                                                            (
                                                                                                                                _config.lazy-shell-resource
                                                                                                                                    {
                                                                                                                                        init = init ;
                                                                                                                                        gc-roots-directory = gc-roots-directory ;
                                                                                                                                        release = release ;
                                                                                                                                        resources-directory = resources-directory ;
                                                                                                                                    }
                                                                                                                                    {
                                                                                                                                        error = error ;
                                                                                                                                        name = name ;
                                                                                                                                    }
                                                                                                                            )
                                                                                                                        ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            EXPECTED="$( mktemp --directory )" || failure 0528168347966815
                                                                                                                            echo -e "${ standard-error }" > "$EXPECTED/standard-error"
                                                                                                                            echo -e "${ standard-output }" > "$EXPECTED/standard-output"
                                                                                                                            echo -e "${ builtins.toString status }" > "$EXPECTED/status"
                                                                                                                            OBSERVED="$( mktemp --directory )" || failure 9132197145496489
                                                                                                                            if ${ command } > "$OBSERVED/standard-output" 2> "$OBSERVED/standard-error"
                                                                                                                            then
                                                                                                                                echo -e "$OBSERVED/status"
                                                                                                                            else
                                                                                                                                echo -e "$OBSERVED/status"
                                                                                                                            fi
                                                                                                                            diff --unified "$EXPECTED" "$OBSERVED"
                                                                                                                        '' ;
                                                                                                                } ;
                                                                                                    in transform command ;
                                                                                        in
                                                                                            builtins.concatLists
                                                                                                [
                                                                                                    ( builtins.genList generator ( builtins.length commands ) )
                                                                                                    [
                                                                                                        (
                                                                                                            _pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "terminal" ;
                                                                                                                    runtimeInputs = [ pkgs.findutils ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            find ${ gc-roots-directory } -mindepth 1 -exec failure 5361527405190707 {} \;
                                                                                                                            find ${ resources-directory } -mindepth 1 -exec failure 9768190112280464 {} \;
                                                                                                                        '' ;
                                                                                                                }
                                                                                                        )
                                                                                                    ]
                                                                                                ] ;
                                                                                imports = [ failure implementation lazy-shell-application trip visitor ] ;
                                                                            } ;
                                                            testScript =
                                                                builtins.concatStringsSep
                                                                    "\n"
                                                                    (
                                                                        builtins.concatLists
                                                                            [
                                                                                [
                                                                                    ''
                                                                                        client.wait_for_unit("multi-user.target")
                                                                                    ''
                                                                                ]
                                                                                (
                                                                                    let
                                                                                        generator = index : ''client.succeed("command-${ builtins.toString index }")'' ;
                                                                                        in builtins.genList generator ( builtins.length commands )
                                                                                )
                                                                                [
                                                                                    ''
                                                                                        client.succeed("terminal")
                                                                                    ''
                                                                                ]
                                                                            ]
                                                                    ) ;
                                                        } ;
                                                type = "lazy-shell-resource" ;
                                            } ;
                                    implementation = implementation-identity implementation ;
                                } ;
            } ;
}