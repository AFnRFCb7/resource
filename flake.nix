{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    { input ? null , output ? null } :
                        let
                            implementation =
                                { config , lib , pkgs , ... } @module :
                                    let
                                        identified =
                                            if builtins.typeOf input == "lambda" then input module
                                            else if builtins.typeOf input == "null" then module
                                            else if builtins.typeOf input == "set" then module
                                            else builtins.throw "7950598338383442" ;
                                        in
                                            with identified ;
                                                {
                                                    options.lazy-shell-resource =
                                                        lib.mkOption
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
                                                                                        lock = { is-directory = true ; source = "${ resources-directory }/lock" ; type = "bind" ; } ;
                                                                                        "log.lock" = { is-directory = false ; source = "${ resources-directory }/log.lock" ; type = "bind" ; } ;
                                                                                        "log.yaml" = { is-directory = false ; source = "${ resources-directory }/log.yaml" ; type = "bind" ; } ;
                                                                                        mounts = { is-directory = true ; source = "${ resources-directory }/mounts" ; type = "bind" ; } ;
                                                                                        pids = { is-directory = true ; source = "${ resources-directory }/pids" ; type = "bind" ; } ;
                                                                                        release = { source = "${ resources-directory }/release" ; type = "bind" ; } ;
                                                                                    } ;
                                                                                name = name ;
                                                                                post = [ ] ;
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
                                                                                                                post = [ ] ;
                                                                                                                runtime-inputs = { pkgs , ... }: [ ( identified.config.failure { } ) identified.config.wrap pkgs.coreutils ] ;
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
                                                                                                                                                            post = [ ] ;
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
                                                                                                                                                                                    post = [ ] ;
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
                                                                                                                                                    post = [ ] ;
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
                                                                                                                        # input = { is-directory = false ; source = "/input" ; type = "bind" ; } ;
                                                                                                                        "log.lock" = { is-directory = false ; source = "/mounts/log.lock" ; type = "bind" ;} ;
                                                                                                                        "log.yaml" = { is-directory = false ; source = "/mounts/log.yaml" ; type = "bind" ;} ;
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
                                                                                                                                    post = [ ] ;
                                                                                                                                    runtime-inputs = { pkgs , ... } : [ ] ;
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
                                                                                                                                                        post = [ ] ;
                                                                                                                                                        runtime-inputs = { pkgs , ... } : [ ( identified.config.failure { } ) pkgs.coreutils pkgs.flock pkgs.yq-go ] ;
                                                                                                                                                        text =
                                                                                                                                                            ''
                                                                                                                                                                TIMESTAMP="$( date +%s )" || failure 3615837188445696
                                                                                                                                                                exec 103> /mounts/log.lock
                                                                                                                                                                flock -x 103
                                                                                                                                                                jq --argjson TIMESTAMP "$TIMESTAMP" --sort-keys '. + { "timestamp" : $TIMESTAMP , "type" : $TYPE }' | yq eval --prettyPrint "[.]" >> /mounts/log.yaml
                                                                                                                                                            '' ;
                                                                                                                                                        variables = { } ;
                                                                                                                                                    } ;
                                                                                                                                            in "${ application }/bin/post" ;
                                                                                                                                    variables = { } ;
                                                                                                                                } ;
                                                                                                                        in [ "${ application }/bin/post" "${ resources-directory }/release/$INDEX" ] ;
                                                                                                                runtime-inputs = { pkgs , ... } : [ identified.config.wrap pkgs.coreutils pkgs.flock pkgs.jq pkgs.yq-go ] ;
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
                                                                                                                                                    lock = { source = "${ resources-directory }/lock" ; type = "bind" ; } ;
                                                                                                                                                    "log.lock" = { is-directory = false ; source = "${ resources-directory }/log.lock" ; type = "bind" ; } ;
                                                                                                                                                    "log.yaml" = { is-directory = false ; source = "${ resources-directory }/log.yaml" ; type = "bind" ; } ;
                                                                                                                                                    pid = { source = "${ resources-directory }/pid" ; type = "bind" ; } ;
                                                                                                                                                } ;
                                                                                                                                            name = "release" ;
                                                                                                                                            post = [ ] ;
                                                                                                                                            runtime-inputs = { pkgs , ... } : [ pkgs.coreutils pkgs.findutils pkgs.flock pkgs.gnutar pkgs.jq pkgs.xz pkgs.yq-go ] ;
                                                                                                                                            text =
                                                                                                                                                ''
                                                                                                                                                    sleep 3s
                                                                                                                                                    TYPE="valid-release"
                                                                                                                                                    jq --null-input --arg TYPE "$TYPE" '[ { "type" : $TYPE } ]' | yq eval --prettyPrint '.' >> /mounts/log.yaml
                                                                                                                                                    while [[ -f /mounts/flag/$INDEX ]]
                                                                                                                                                    do
                                                                                                                                                        rm "/mounts/flag/$INDEX"
                                                                                                                                                        find "/mounts/pid/$INDEX" -mindepth 1 -maxdepth 1 | while read -r PID_FILE
                                                                                                                                                        do
                                                                                                                                                            while [[ -f "$PID_FILE" ]]
                                                                                                                                                            do
                                                                                                                                                                sleep 1s
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
                                                                                                                                                                    sleep 1s
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
                                                                                                                                            variables = { INDEX = "$INDEX" ; } ;
                                                                                                                                        } ;
                                                                                                                        in
                                                                                                                            ''
                                                                                                                                exec 168> /mounts/log.lock
                                                                                                                                flock -x 168
                                                                                                                                TYPE="valid-init"
                                                                                                                                TIMESTAMP="$( date +%s )" || failure 7010050283879972
                                                                                                                                jq --null-input --argjson TIMESTAMP "$TIMESTAMP" --arg TYPE "$TYPE" --sort-keys '[ { "timestamp" : $TIMESTAMP , "type" : $TYPE } ]' | yq eval --prettyPrint '.' >> /mounts/log.yaml
                                                                                                                                wrap ${ release }/bin/release "/mounts/release/$INDEX" 0500
                                                                                                                                # cat "/mounts/release/$INDEX" >&2
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
                                                                                                                                        input = { is-directory = false ; read-only = true ; source = "/mounts/input" ; type = "bind" ; } ;
                                                                                                                                        mount = { source = "/mounts/mount/$INDEX" ; type = "bind" ; } ;
                                                                                                                                        output = { is-directory = false ; source = "/mounts/output" ; type = "bind" ; } ;
                                                                                                                                        standard-error = { is-directory = false ; type = "temporary" ; } ;
                                                                                                                                        standard-output = { is-directory = false ; type = "temporary" ; } ;
                                                                                                                                    } ;
                                                                                                                                name = "init" ;
                                                                                                                                post = [ ] ;
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
                                                                                                                                                                post = [ ] ;
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
                                                                                                                                post = [ ] ;
                                                                                                                                runtime-inputs = { pkgs , ... } : [ pkgs.jq valid-init ] ;
                                                                                                                                text =
                                                                                                                                    ''
                                                                                                                                        jq --null-input '{ }' |  valid-init
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
                                                                                            echo -n "${ resources-directory }/mounts/$INDEX"
                                                                                            export INDEX
                                                                                            touch "/mounts/flag/$INDEX"
                                                                                            MOUNT="/mounts/mounts/$INDEX"
                                                                                            mkdir --parents "$MOUNT"
                                                                                            if init
                                                                                            then
                                                                                                rm "/mounts/lock/$HASH"
                                                                                            else
                                                                                                rm "/mounts/lock/$HASH"
                                                                                                exit ${ builtins.toString error }
                                                                                            fi
                                                                                        fi
                                                                                    '' ;
                                                                                variables = { } ;
                                                                            } ;
                                                                type = lib.types.functionTo ( lib.types.functionTo lib.types.package ) ;
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
                                            process-lock ,
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
                                                                { config , pkgs , ... } @module :
                                                                    let
                                                                        identified =
                                                                            if builtins.typeOf input == "lambda" then input module
                                                                            else if builtins.typeOf input == "null" then module
                                                                            else if builtins.typeOf input == "set" then module
                                                                            else builtins.throw "7950598338383442" ;
                                                                        in
                                                                            with identified ;
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
                                                                                                                            pkgs.writeShellApplication
                                                                                                                                {
                                                                                                                                    name = "process-${ builtins.toString index }" ;
                                                                                                                                    runtimeInputs =
                                                                                                                                        [
                                                                                                                                            (
                                                                                                                                                pkgs.writeShellApplication
                                                                                                                                                    {
                                                                                                                                                        name = "process" ;
                                                                                                                                                        runtimeInputs = runtime-inputs identified ;
                                                                                                                                                        text = text ;
                                                                                                                                                    }
                                                                                                                                            )
                                                                                                                                            pkgs.coreutils
                                                                                                                                            pkgs.flock
                                                                                                                                            (
                                                                                                                                                pkgs.writeShellApplication
                                                                                                                                                    {
                                                                                                                                                        name = "check-log" ;
                                                                                                                                                        runtimeInputs = [ ( identified.config.failure { } ) pkgs.coreutils pkgs.flock pkgs.jq pkgs.yq-go ] ;
                                                                                                                                                        text =
                                                                                                                                                            ''
                                                                                                                                                                sleep 10s
                                                                                                                                                                exec 132> ${ resources-directory }/log.lock
                                                                                                                                                                flock -x 132
                                                                                                                                                                EXPECTED="$( mktemp )" || failure 4940461114226167
                                                                                                                                                                jq '.' > "$EXPECTED"
                                                                                                                                                                N="$( jq 'length' "$EXPECTED" )" || failure 0163978703024678
                                                                                                                                                                CORRECT=false
                                                                                                                                                                while [[ "$#" -gt 0 ]]
                                                                                                                                                                do
                                                                                                                                                                    case "$1" in
                                                                                                                                                                        --order)
                                                                                                                                                                            shift 1
                                                                                                                                                                            ORDER_JSON="$( printf '%s\n' "${ "$" }{@:1:$N}" | jq --raw-output 'tonumber' | jq --slurp '.' )" || failure 5547985831229891
                                                                                                                                                                            OBSERVED="$( mktemp )" || failure 5660646061926270
                                                                                                                                                                            yq eval -o=json '.' ${ resources-directory }/log.yaml | jq 'map(del(.timestamp))' | jq --argjson order "$ORDER_JSON" '[. as $original | $order[] | $original[.-1]]' > "$OBSERVED"
                                                                                                                                                                            if diff --unified "$EXPECTED" "$OBSERVED" >&2
                                                                                                                                                                            then
                                                                                                                                                                                CORRECT=true
                                                                                                                                                                            fi
                                                                                                                                                                            shift $(( N ))
                                                                                                                                                                            rm "$OBSERVED"
                                                                                                                                                                            ;;
                                                                                                                                                                        *)
                                                                                                                                                                            failure 4918633717283692
                                                                                                                                                                            ;;
                                                                                                                                                                    esac
                                                                                                                                                                done
                                                                                                                                                                if [[ "$CORRECT" != true ]]
                                                                                                                                                                then
                                                                                                                                                                    EXPECTED_JSON="$( cat "$EXPECTED" )" || failure 5801512242812508
                                                                                                                                                                    failure 4612322045996105 ${ builtins.toString index } "$N" "$EXPECTED_JSON"
                                                                                                                                                                fi
                                                                                                                                                                truncate -s 0 ${ resources-directory }/log.yaml
                                                                                                                                                                rm "$EXPECTED"
                                                                                                                                                            '' ;
                                                                                                                                                    }
                                                                                                                                            )
                                                                                                                                        ] ;
                                                                                                                                    text =
                                                                                                                                        ''
                                                                                                                                            mkdir --parents ${ process-lock }
                                                                                                                                            exec 170> ${ process-lock }/process.${ builtins.toString index }.lock
                                                                                                                                            flock -x 170
                                                                                                                                            process 2> ${ process-lock }/process.${ builtins.toString index }.failure
                                                                                                                                        '' ;
                                                                                                                                } ;
                                                                                                                    in transform process ;
                                                                                                    in builtins.genList generator ( builtins.length processes )
                                                                                                )
                                                                                                [
                                                                                                    ( identified.config.failure { } )
                                                                                                    (
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "terminal" ;
                                                                                                                runtimeInputs = [ ( config.failure { } ) pkgs.coreutils pkgs.findutils pkgs.flock ] ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        sleep 10s
                                                                                                                        mkdir --parents ${ process-lock }
                                                                                                                        ${ builtins.concatStringsSep "\n" ( builtins.genList ( index : ''exec 1${ lib.fixedWidthString 2 "0" ( builtins.toString index ) }> ${ process-lock }/process.${ builtins.toString index }.lock'' ) ( builtins.length processes ) ) }
                                                                                                                        ${ builtins.concatStringsSep "\n" ( builtins.genList ( index : ''flock -x 1${ lib.fixedWidthString 2 "0" ( builtins.toString index ) }'' ) ( builtins.length processes ) ) }
                                                                                                                        find ${ process-lock } -type f -mindepth 1 -maxdepth 1 -name "process.*.failure" | sort | while read -r FAILURE
                                                                                                                        do
                                                                                                                            if [[ -s "$FAILURE" ]]
                                                                                                                            then
                                                                                                                                FAILURE_FLAG="$( cat "$FAILURE" )" || failure 4288993981752581
                                                                                                                                failure 6498931208074655 "$FAILURE_FLAG"
                                                                                                                            fi
                                                                                                                        done
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
                                                                                        generator = index : ''client.succeed("nohup process-${ builtins.toString index } > /dev/null 2>&1 &")'' ;
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
                                        else builtins.throw "4176512620845008" ;
                                } ;
            } ;
}
