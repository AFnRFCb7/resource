{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    output :
                    input :
                        let
                            implementation =
                                { ... } @module :
                                    let
                                        identified =
                                            if builtins.typeOf input == "lambda" then input module
                                            else if builtins.typeOf input == "null" then module
                                            else builtins.throw "7950598338383442" ;
                                        in
                                            {
                                                options.lazy-shell-resource =
                                                    identified.lib.mkOption
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
                                                                    identified.config.lazy-shell-application
                                                                        {
                                                                            mounts =
                                                                                {
                                                                                    canonical = { is-directory = true ; source = "${ resources-directory }/canonical" ; type = "bind" ; } ;
                                                                                    diagnostic = { source = "${ resources-directory }/diagnostic" ; type = "bind" ; } ;
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
                                                                                { pkgs , ... } :
                                                                                    [
                                                                                        ( identified.config.failure { } )
                                                                                        ( identified.config.sequential { sequential-file = "${ resources-directory }/sequential.asc" ; sequential-lock = "${ resources-directory }/sequential.lock" ; } )
                                                                                        pkgs.coreutils
                                                                                        pkgs.flock
                                                                                        (
                                                                                            let
                                                                                                action =
                                                                                                    identified.config.visitor
                                                                                                        { }
                                                                                                        {
                                                                                                            lambda = path : value : builtins.getAttr "action" ( identity value ) ;
                                                                                                            null = path : value : value ;
                                                                                                        }
                                                                                                        init ;
                                                                                                expected-targets = builtins.sort ( a : b : a < b ) ( identified.config.visitor { } { string = path : value : value ; } ( builtins.getAttr "targets" ( identity init ) ) ) ;
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
                                                                                                invalid-init =
                                                                                                    identified.config.lazy-shell-application
                                                                                                        {
                                                                                                            mounts =
                                                                                                                {
                                                                                                                    invalid-init = { source = "/mounts/invalid-init" ; type = "bind" ; } ;
                                                                                                                } ;
                                                                                                            name = "invalid-init" ;
                                                                                                            post = null ;
                                                                                                            runtime-inputs = { pkgs , ... } : [ ( identified.config.failure { } ) identified.config.wrap pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                let
                                                                                                                    recovery =
                                                                                                                        identified.config.visitor
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
                                                                                                                                                identified.config.lazy-shell-application
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
                                                                                                                                                            { pkgs , ... } :
                                                                                                                                                                [
                                                                                                                                                                    invalid-init
                                                                                                                                                                    pkgs.coreutils
                                                                                                                                                                    pkgs.jq
                                                                                                                                                                    (
                                                                                                                                                                        identified.config.lazy-shell-application
                                                                                                                                                                            {
                                                                                                                                                                                mounts = { } ;
                                                                                                                                                                                name = "recovery" ;
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
                                                                                                                                        identified.config.lazy-shell-application
                                                                                                                                            {
                                                                                                                                                mounts =
                                                                                                                                                    {
                                                                                                                                                        invalid-init = { is-directory = true ; source = "/mounts/invalid-init" ; type = "bind" ; } ;
                                                                                                                                                        release = { is-directory = true ; source = "/mounts/release" ; type = "bind" ; } ;
                                                                                                                                                    } ;
                                                                                                                                                name = "invalid-init" ;
                                                                                                                                                post = null ;
                                                                                                                                                runtime-inputs = { pkgs , ... } : [ valid-init ] ;
                                                                                                                                                text = "valid-init" ;
                                                                                                                                                variables = { } ;
                                                                                                                                            } ;
                                                                                                                            }
                                                                                                                            { default = null ; specified = recovery ; } ;
                                                                                                                    in
                                                                                                                        ''
                                                                                                                            PROVENANCE="$1"
                                                                                                                            if [[ "$PROVENANCE" == "new" ]]
                                                                                                                            then
                                                                                                                                ${ builtins.concatStringsSep "\n" ( identified.config.visitor { } { lambda = path : value : let x = value null ; in ''wrap ${ x } /mounts/invalid-init/${ builtins.toJSON path }/recovery.sh 0500 --replace INDEX "$INDEX"'' ; } recovery ) }
                                                                                                                            else
                                                                                                                                failure 4666519411676571
                                                                                                                            fi
                                                                                                                            failure "$@"
                                                                                                                        '' ;
                                                                                                            variables = { } ;
                                                                                                        } ;
                                                                                                valid-init =
                                                                                                    identified.config.lazy-shell-application
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
                                                                                                                        identified.config.lazy-shell-application
                                                                                                                            {
                                                                                                                                mounts = { release = { source = "${ resources-directory }/release" ; type = "bind" ; } ; } ;
                                                                                                                                name = "post" ;
                                                                                                                                post = null ;
                                                                                                                                runtime-inputs = pkgs : [ ] ;
                                                                                                                                text =
                                                                                                                                    let
                                                                                                                                        application =
                                                                                                                                            identified.config.lazy-shell-application
                                                                                                                                                {
                                                                                                                                                    mounts =
                                                                                                                                                        {
                                                                                                                                                            "log.lock" = { is-directory = false ; source = "${ resources-directory }/log.lock" ; type = "bind" ; } ;
                                                                                                                                                            "log.yaml" = { is-directory = false ; source = "${ resources-directory }/log.yaml" ; type = "bind" ; } ;
                                                                                                                                                            release = { source = "${ resources-directory }/release" ; type = "bind"; } ;
                                                                                                                                                        } ;
                                                                                                                                                    name = "post" ;
                                                                                                                                                    post = null ;
                                                                                                                                                    runtime-inputs = pkgs : [ ( identified.config.failure { } ) pkgs.coreutils pkgs.flock pkgs.yq-go ] ;
                                                                                                                                                    text =
                                                                                                                                                        ''
                                                                                                                                                            "/mounts/release/$INDEX"
                                                                                                                                                            TIMESTAMP="$( date +%s )" || failure 3615837188445696
                                                                                                                                                            exec 103> /mounts/log.lock
                                                                                                                                                            flock -x 103
                                                                                                                                                            jq --arg TYPE "valid-init" --argjson TIMESTAMP "$TIMESTAMP" --sort-keys '. + { "timestamp" : $TIMESTAMP , "type" : $TYPE }' | yq eval --prettyPrint "[.]" >> /mounts/log.yaml
                                                                                                                                                        '' ;
                                                                                                                                                    variables = { } ;
                                                                                                                                                } ;
                                                                                                                                        in "${ application }/bin/post" ;
                                                                                                                                variables = { } ;
                                                                                                                            } ;
                                                                                                                    in "${ application }/bin/post" ;
                                                                                                            runtime-inputs = { pkgs , ... } : [ identified.config.wrap pkgs.coreutils ] ;
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
                                                                                                                                identified.config.lazy-shell-application
                                                                                                                                    {
                                                                                                                                        mounts =
                                                                                                                                            {
                                                                                                                                                flag = { source = "${ resources-directory }/flag" ; type = "bind" ; } ;
                                                                                                                                                pid = { source = "${ resources-directory }/pid" ; type = "bind" ; } ;
                                                                                                                                            } ;
                                                                                                                                        name = "release" ;
                                                                                                                                        post = null ;
                                                                                                                                        runtime-inputs = { pkgs , ... } : [ pkgs.coreutils pkgs.findutils pkgs.flock pkgs.gnutar pkgs.xz ] ;
                                                                                                                                        text =
                                                                                                                                            ''
                                                                                                                                                while [[ -f /mounts/flag/$INDEX ]]
                                                                                                                                                do
                                                                                                                                                    rm "/mounts/flag/$INDEX"
                                                                                                                                                    find "/mounts/pid/$INDEX" -mindepth 1 -maxdepth 1 | while read -r PID_FILE
                                                                                                                                                    do
                                                                                                                                                        while [[ -f "$PID_FILE" ]]
                                                                                                                                                        do
                                                                                                                                                            sleep 1
                                                                                                                                                        done
                                                                                                                                                    done
                                                                                                                                                    EXPECTED="${ resources-directory }/mounts/$INDEX"
                                                                                                                                                    find "/mounts/gc-roots" -type L | while read -r CANDIDATE
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
                                                                                                                            wrap ${ release }/bin/release "/mounts/release/$INDEX" --replace INDEX "$INDEX"
                                                                                                                        '' ;
                                                                                                            variables = { } ;
                                                                                                        } ;
                                                                                                in
                                                                                                    identified.config.visitor
                                                                                                        { }
                                                                                                        {
                                                                                                            lambda =
                                                                                                                path : value :
                                                                                                                    identified.config.lazy-shell-application
                                                                                                                        {
                                                                                                                            mounts =
                                                                                                                                {
                                                                                                                                    input = { is-directory = false ; source = "/mounts/input" ; type = "bind" ; } ;
                                                                                                                                    mount = { source = "/mounts/mount/$INDEX" ; type = "bind" ; } ;
                                                                                                                                    output = { is-directory = false ; source = "/mounts/output" ; type = "bind" ; } ;
                                                                                                                                    standard-error = { is-directory = false ; type = "temporary" ; } ;
                                                                                                                                    standard-output = { is-directory = false ; type = "temporary" ; } ;
                                                                                                                                } ;
                                                                                                                            name = "init" ;
                                                                                                                            post = null ;
                                                                                                                            runtime-inputs =
                                                                                                                                { pkgs , ... } :
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
                                                                                                                                                    identified.config.lazy-shell-application
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
                                                                                                                                        INPUT="$( jq '.' /mounts/input || failure 9213699588429497
                                                                                                                                        OUTPUT="$( jq '.' /mounts/output )" || failure 9223149214133109
                                                                                                                                        jq \
                                                                                                                                            --null-input \
                                                                                                                                            --argjson INPUT "$INPUT" \
                                                                                                                                            --argjson OUTPUT "$OUTPUT" \
                                                                                                                                            '{
                                                                                                                                                "input" : $INPUT ,
                                                                                                                                                "output" : $OUTPUT
                                                                                                                                             }' | valid-init
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
                                                                                                                    identified.config.lazy-shell-application
                                                                                                                        {
                                                                                                                            mounts = { release = { source = "/mounts/release" ; type = "bind" ; } ; } ;
                                                                                                                            name = "init" ;
                                                                                                                            post = null ;
                                                                                                                            runtime-inputs = { pkgs , ... } : [ pkgs.jq valid-init ] ;
                                                                                                                            text =
                                                                                                                                ''
                                                                                                                                    jq --null-input '{ }' | valid-init
                                                                                                                                '' ;
                                                                                                                            variables = { } ;
                                                                                                                        } ;
                                                                                                        }
                                                                                                        action
                                                                                        )
                                                                                    ] ;
                                                                            text =
                                                                                ''
                                                                                    PID="$( sequential )" || failure 3708670955636569
                                                                                    HASH=$( sha512sum < /mounts/input | cut --bytes 1-128 ) || failure 9501307898608371
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
                                                            type = identified.lib.types.functionTo ( identified.lib.types.functionTo identified.lib.types.package ) ;
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
                                            sequential ,
                                            visitor ,
                                            wrap
                                        } :
                                        {
                                            gc-roots-directory ,
                                            resources-directory
                                        } :
                                        resources :
                                        processes :
                                            {
                                                obviated-by = obviated-by ;
                                                test =
                                                    nixosTest
                                                        {
                                                            name = "nixos-test" ;
                                                            nodes.client =
                                                                { ... } @module :
                                                                    let
                                                                        identified =
                                                                            if builtins.typeOf input == "lambda" then input module
                                                                            else if builtins.typeOf input == "null" then module
                                                                            else builtins.throw "7950598338383442" ;
                                                                        in
                                                                            {
                                                                                config.environment.systemPackages =
                                                                                    builtins.concatLists
                                                                                        [
                                                                                            (
                                                                                                let
                                                                                                    mapper =
                                                                                                        name : { error , init , release } :
                                                                                                            identified.config.lazy-shell-resource
                                                                                                                {
                                                                                                                    gc-roots-directory = gc-roots-directory ;
                                                                                                                    init = init ;
                                                                                                                    resources-directory = resources-directory ;
                                                                                                                    release = release ;
                                                                                                                }
                                                                                                                {
                                                                                                                    error = error ;
                                                                                                                    name = name ;
                                                                                                                } ;
                                                                                                    in builtins.attrValues ( builtins.mapAttrs mapper resources )
                                                                                            )
                                                                                            (
                                                                                                let
                                                                                                    generator =
                                                                                                        index :
                                                                                                            let
                                                                                                                process = builtins.elemAt processes index ;
                                                                                                                transform =
                                                                                                                    {
                                                                                                                        runtime-inputs ,
                                                                                                                        text
                                                                                                                    } :
                                                                                                                        identified.pkgs.writeShellApplication
                                                                                                                            {
                                                                                                                                name = "process-${ builtins.toString index }" ;
                                                                                                                                runtimeInputs = runtime-inputs { config = identified.config ; pkgs = identified.pkgs ; } ;
                                                                                                                                text = text ;
                                                                                                                            } ;
                                                                                                                in transform process ;
                                                                                                in builtins.genList generator ( builtins.length processes )
                                                                                            )
                                                                                            [
                                                                                                ( identified.config.failure { } )
                                                                                                (
                                                                                                    identified.pkgs.writeShellApplication
                                                                                                        {
                                                                                                            name = "check-log" ;
                                                                                                            runtimeInputs = [ ( identified.config.failure { } ) identified.pkgs.coreutils identified.pkgs.flock identified.pkgs.jq identified.pkgs.yq-go ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    exec 132> ${ resources-directory }/log.lock
                                                                                                                    flock -x 132
                                                                                                                    ORIGINAL="$( mktemp )" || failure 4940461114226167
                                                                                                                    jq "del(.timestamp)" > "$ORIGINAL"
                                                                                                                    N="$( jq 'length' "$ORIGINAL" )" || failure 0163978703024678
                                                                                                                    CORRECT=false
                                                                                                                    while [[ "$#" -gt 0 ]]
                                                                                                                    do
                                                                                                                        case "$1" in
                                                                                                                            --order)
                                                                                                                                COPY="$( mktemp )" || failure 1772410810339790
                                                                                                                                ORDER_JSON="$( printf '%s\n' "${ "$" }{ORDER[@]}" | jq -R 'tonumber' | jq -s '.') " || failure 0312903319846095
                                                                                                                                jq --argjson order "$ORDER_JSON" '. as $original | [$order[] | $original[.-1]]' | yq eval --prettyPrint > "$COPY"
                                                                                                                                if diff "$COPY" ${ resources-directory }/log.yaml
                                                                                                                                then
                                                                                                                                    CORRECT=true
                                                                                                                                fi
                                                                                                                                shift $(( N + 1 ))
                                                                                                                                ;;
                                                                                                                            *)
                                                                                                                                failure 4918633717283692
                                                                                                                                ;;
                                                                                                                        esac
                                                                                                                    done
                                                                                                                    if [[ "$CORRECT" != true ]]
                                                                                                                    then
                                                                                                                        failure 4612322045996105
                                                                                                                    fi
                                                                                                                    rm ${ resources-directory }/log.lock ${ resources-directory }/log.yaml
                                                                                                                '' ;
                                                                                                        }
                                                                                                )
                                                                                                (
                                                                                                    identified.pkgs.writeShellApplication
                                                                                                        {
                                                                                                            name = "terminal" ;
                                                                                                            runtimeInputs = [ identified.pkgs.coreutils identified.pkgs.findutils ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    if [[ -f ${ resources-directory }/log.yaml ]]
                                                                                                                    then
                                                                                                                        rm ${ resources-directory }/log.yaml
                                                                                                                    fi
                                                                                                                    if [[ -f ${ resources-directory }/sequential.asc ]]
                                                                                                                    then
                                                                                                                        rm ${ resources-directory }/sequential.asc
                                                                                                                    fi
                                                                                                                    if [[ -d ${ resources-directory }/temporary ]]
                                                                                                                    then
                                                                                                                        rm --recursive --force ${ resources-directory }/temporary
                                                                                                                    fi
                                                                                                                    if [[ -d ${ gc-roots-directory } ]]
                                                                                                                    then
                                                                                                                        find ${ gc-roots-directory } -mindepth 1 -exec failure 5361527405190707 {} \;
                                                                                                                    fi
                                                                                                                    if [[ -d ${ resources-directory } ]]
                                                                                                                    then
                                                                                                                        find ${ resources-directory } -mindepth 1 -exec failure 9768190112280464 {} \;
                                                                                                                    fi
                                                                                                                '' ;
                                                                                                        }
                                                                                                )
                                                                                            ]
                                                                                        ] ;
                                                                                imports = [ failure implementation lazy-shell-application sequential trip visitor wrap ] ;
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
                                                                                        generator = index : ''client.succeed("process-${ builtins.toString index } &")'' ;
                                                                                        in builtins.genList generator ( builtins.length processes )
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
                                    implementation =
                                        if builtins.typeOf output == "lambda" then output implementation
                                        else if builtins.typeOf output == "null" then implementation
                                        else builtins.throw "0732026579538214" ;
                                } ;
            } ;
}
