# 19450
{
	inputs = { } ;
	outputs =
		{ self } :
		    {
		        lib =
                    {
                        buildFHSUserEnv ,
                        coreutils ,
                        flock ,
                        gc-root-directory ,
                        jq ,
                        procps ,
                        redis ,
                        resources ,
                        resources-directory ,
                        visitor ,
                        writeShellApplication
                    } @primary :
                        let
                            implementation =
                                {
                                    depth ,
                                    init ,
                                    init-resolutions ,
                                    invalid-init-channel ,
                                    invalid-release-channel ,
                                    release ,
                                    release-resolutions ,
                                    seed ,
                                    stale-init-channel ,
                                    targets ,
                                    transient ,
                                    valid-init-channel ,
                                    valid-release-channel
                                } @secondary :
                                    let
                                        arguments =
                                            {
                                                init =
                                                    pkgs :
                                                        {
                                                            failure = failure ;
                                                            gc-root = gc-root ;
                                                            pkgs = pkgs ;
                                                            resources = resources ;
                                                            seed = seed ;
                                                            sequential = sequential ;
                                                            trace = trace ;
                                                            wrap = null ;
                                                        } ;
                                                release =
                                                    pkgs :
                                                        {
                                                            failure = failure ;
                                                            pkgs = pkgs ;
                                                            resources = resources ;
                                                            seed = seed ;
                                                            sequential = sequential ;
                                                            trace = trace ;
                                                        } ;
                                            } ;
                                        create =
                                            buildFHSUserEnv
                                                {
                                                    name = "create" ;
                                                    runScript =
                                                        ''
                                                            bash -c '
                                                                trace 2256 "$*"
                                                                if "$HAS_STANDARD_INPUT"
                                                                then
                                                                    create "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }"
                                                                else
                                                                    create "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" < "$STANDARD_INPUT_FILE"
                                                                fi
                                                                trace 5487 "$*"
                                                            ' "$0" "$@"
                                                        '' ;
                                                    targetPkgs =
                                                        pkgs :
                                                            [
                                                                trace
                                                                (
                                                                    let
                                                                        applications =
                                                                            {
                                                                                init =
                                                                                    visitor
                                                                                        {
                                                                                            lambda =
                                                                                                path : value :
                                                                                                    buildFHSUserEnv
                                                                                                        {
                                                                                                            extraBwrapArgs =
                                                                                                                [
                                                                                                                    "--bind ${ resources-directory }/mounts/$INDEX /mount"
                                                                                                                    "--tmpfs /scratch"
                                                                                                                ] ;
                                                                                                            name = "init" ;
                                                                                                            runScript =
                                                                                                                ''
                                                                                                                    bash -c '
                                                                                                                        trace 9407 "$*" "$( cat $( ${ pkgs.which }/bin/which init ) )"
                                                                                                                        if "$HAS_STANDARD_INPUT"
                                                                                                                        then
                                                                                                                            init "$@"
                                                                                                                        else
                                                                                                                            init "$@" < "$STANDARD_INPUT_FILE"
                                                                                                                        fi
                                                                                                                        trace 8094 "$*"
                                                                                                                    ' "$0" "$@"
                                                                                                                '' ;
                                                                                                            targetPkgs =
                                                                                                                pkgs :
                                                                                                                    [
                                                                                                                        (
                                                                                                                            pkgs.writeShellApplication
                                                                                                                                {
                                                                                                                                    name = "init" ;
                                                                                                                                    text =
                                                                                                                                        let
                                                                                                                                            a = arguments.init pkgs ;
                                                                                                                                            in value a ;
                                                                                                                                }
                                                                                                                        )
                                                                                                                    ] ;
                                                                                                        } ;
                                                                                            null = path : value : null ;
                                                                                        }
                                                                                        init ;
                                                                                release =
                                                                                    visitor
                                                                                        {
                                                                                            lambda =
                                                                                                path : value :
                                                                                                    buildFHSUserEnv
                                                                                                        {
                                                                                                            extraBwrapArgs =
                                                                                                                [
                                                                                                                    ''--bind "${ resources-directory }/mounts/$INDEX" /mount''
                                                                                                                    ''--tmpfs /scratch''
                                                                                                                ] ;
                                                                                                            name = "release" ;
                                                                                                            runScript = "release" ;
                                                                                                            targetPkgs =
                                                                                                                 pkgs :
                                                                                                                    [
                                                                                                                        (
                                                                                                                            pkgs.writeShellApplication
                                                                                                                                {
                                                                                                                                    name = "release" ;
                                                                                                                                    text =
                                                                                                                                        let
                                                                                                                                            a = arguments.release pkgs ;
                                                                                                                                            in value a ;
                                                                                                                                }
                                                                                                                        )
                                                                                                                    ] ;
                                                                                                        } ;
                                                                                            null = path : value : null ;
                                                                                        }
                                                                                        release ;
                                                                            } ;
                                                                        destroy =
                                                                            writeShellApplication
                                                                                {
                                                                                    name = "destroy" ;
                                                                                    runtimeInputs =
                                                                                        [
                                                                                            trace
                                                                                            (
                                                                                                buildFHSUserEnv
                                                                                                    {
                                                                                                        extraBwrapArgs =
                                                                                                            [
                                                                                                                ''--bind "${ gc-root-directory }/$INDEX" ${ gc-root-directory }''
                                                                                                                "--bind ${ resources-directory} ${ resources-directory }"
                                                                                                            ] ;
                                                                                                        name = "destroy" ;
                                                                                                        runScript = "destroy" ;
                                                                                                        targetPkgs =
                                                                                                            pkgs :
                                                                                                                [
                                                                                                                    (
                                                                                                                        pkgs.writeShellApplication
                                                                                                                            {
                                                                                                                                name = "destroy" ;
                                                                                                                                runtimeInputs = [ applications.release failure pkgs.coreutils pkgs.findutils pkgs.flock pkgs.inotify-tools pkgs.zstd sequential trace ] ;
                                                                                                                                text =
                                                                                                                                    visitor
                                                                                                                                        {
                                                                                                                                            lambda =
                                                                                                                                                path : value :
                                                                                                                                                    let
                                                                                                                                                        a = arguments.release pkgs ;
                                                                                                                                                        in
                                                                                                                                                            ''
                                                                                                                                                                trace 15841
                                                                                                                                                                rm "${ resources-directory }/marks/$INDEX"
                                                                                                                                                                trace 29874
                                                                                                                                                                find "${ resources-directory }/pids/$INDEX" -mindepth 1 -maxdepth 1 -type f -exec basename {} \; | while read -r PID
                                                                                                                                                                do
                                                                                                                                                                    trace 15412 "PID=$PID"
                                                                                                                                                                    tail --follow /dev/null --pid "$PID"
                                                                                                                                                                done
                                                                                                                                                                trace 19784
                                                                                                                                                                mkdir --parents "${ gc-root-directory }/$INDEX"
                                                                                                                                                                trace 24208
                                                                                                                                                                find "${ gc-root-directory }/$INDEX" -mindepth 1 -type l | while read -r LINK
                                                                                                                                                                do
                                                                                                                                                                    trace 2060 "LINK=$LINK"
                                                                                                                                                                    FILE="$( readlink --canonicalize "$LINK" )" || failure 15150
                                                                                                                                                                    if [[ "${ resources-directory }/mounts/$INDEX" == "$FILE" ]]
                                                                                                                                                                    then
                                                                                                                                                                        inotify-wait --event delete-self "$LINK"
                                                                                                                                                                    fi
                                                                                                                                                                done
                                                                                                                                                                trace 23482
                                                                                                                                                                exec 203> "${ resources-directory }/locks/$HASH"
                                                                                                                                                                flock -x 203
                                                                                                                                                                trace 24754
                                                                                                                                                                exec 204> "${ resources-directory }/locks/$INDEX"
                                                                                                                                                                flock -x 204
                                                                                                                                                                trace 30327
                                                                                                                                                                if [[ -e "${ resources-directory }/marks/$INDEX" ]]
                                                                                                                                                                then
                                                                                                                                                                    trace 12340
                                                                                                                                                                    flock -u 203
                                                                                                                                                                    flock -u 204
                                                                                                                                                                    nohup "$0" &
                                                                                                                                                                else
                                                                                                                                                                    trace 15683
                                                                                                                                                                    rm "${ resources-directory }/canonical/$HASH"
                                                                                                                                                                    flock -u 203
                                                                                                                                                                    mkdir --parents ${ resources-directory }/logs
                                                                                                                                                                    SCRIPT_FILE="$( ${ script-file release a } )" || failure 17419
                                                                                                                                                                    SEED='${ builtins.toJSON seed }'
                                                                                                                                                                    STANDARD_ERROR_SEQUENCE="$( sequential )" || failure 16457
                                                                                                                                                                    STANDARD_ERROR_FILE="${ resources-directory }/logs/$STANDARD_ERROR_SEQUENCE"
                                                                                                                                                                    STANDARD_OUTPUT_SEQUENCE="$( sequential )" || failure 27852
                                                                                                                                                                    STANDARD_OUTPUT_FILE="${ resources-directory }/logs/$STANDARD_OUTPUT_SEQUENCE"
                                                                                                                                                                    if release > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                                                                                                                    then
                                                                                                                                                                        STATUS="$?"
                                                                                                                                                                    else
                                                                                                                                                                        STATUS="$?"
                                                                                                                                                                    fi
                                                                                                                                                                    ARCHIVE="$( mktemp --dry-run --suffix ".tar.xz" )" || failure 7546
                                                                                                                                                                    tar --create --xz --file "$ARCHIVE" "${ gc-root-directory }/$INDEX" "${ resources-directory }/mounts/$INDEX" "${ resources-directory }/pids/$INDEX" "${ resources-directory }/release/$INDEX"
                                                                                                                                                                    rm --recursive --force "${ gc-root-directory }/$INDEX" "${ resources-directory }/mounts/$INDEX" "${ resources-directory }/pids/$INDEX" "${ resources-directory }/release/$INDEX"
                                                                                                                                                                    JSON_SEQUENCE="$( sequential )" || failure 4228
                                                                                                                                                                    JSON_FILE="${ resources-directory }/logs/$JSON_SEQUENCE"
                                                                                                                                                                    trace 12595 "$0"
                                                                                                                                                                    jq \
                                                                                                                                                                        --compact-output \
                                                                                                                                                                        --null-input \
                                                                                                                                                                        --arg HASH "$HASH" \
                                                                                                                                                                        --arg INDEX "$INDEX" \
                                                                                                                                                                        --arg SCRIPT_FILE "$SCRIPT_FILE" \
                                                                                                                                                                        --argjson SEED "$SEED" \
                                                                                                                                                                        --arg STANDARD_ERROR_FILE "$STANDARD_ERROR_FILE" \
                                                                                                                                                                        --arg STANDARD_OUTPUT_FILE "$STANDARD_OUTPUT_FILE" \
                                                                                                                                                                        --arg STATUS "$STATUS" \
                                                                                                                                                                        '{
                                                                                                                                                                            "hash" : $HASH ,
                                                                                                                                                                            "index" : $INDEX ,
                                                                                                                                                                            "script-file" : $SCRIPT_FILE ,
                                                                                                                                                                            "seed" : $SEED ,
                                                                                                                                                                            "standard-error-file": $STANDARD_ERROR_FILE ,
                                                                                                                                                                            "standard-output-file" : $STANDARD_OUTPUT_FILE ,
                                                                                                                                                                            "status" : $STATUS ,
                                                                                                                                                                        }' > "$JSON_FILE"
                                                                                                                                                                    trace 4083 "$0" "JSON_FILE=$JSON_FILE" "STATUS=$STATUS"
                                                                                                                                                                    if [[ "$STATUS" == 0 ]]
                                                                                                                                                                    then
                                                                                                                                                                        trace 15336 "STATUS=$STATUS"
                                                                                                                                                                    fi
                                                                                                                                                                    if [[ ! -s "$STANDARD_ERROR_FILE" ]]
                                                                                                                                                                    then
                                                                                                                                                                        trace 2865
                                                                                                                                                                        sha512sum "$STANDARD_ERROR_FILE"
                                                                                                                                                                    fi
                                                                                                                                                                    chmod 0400 "$JSON_FILE" "$STANDARD_ERROR_FILE" "$STANDARD_OUTPUT_FILE"
                                                                                                                                                                    if [[ "$STATUS" == 0 ]] && [[ ! -s "$STANDARD_ERROR_FILE" ]]
                                                                                                                                                                    then
                                                                                                                                                                        redis-cli PUBLISH ${ valid-release-channel } "$JSON_FILE"
                                                                                                                                                                    else
                                                                                                                                                                        redis-cli PUBLISH ${ invalid-release-channel } "$JSON_FILE"
                                                                                                                                                                    fi
                                                                                                                                                                fi
                                                                                                                                                            '' ;
                                                                                                                                            null =
                                                                                                                                                path : value :
                                                                                                                                                    ''
                                                                                                                                                        rm "${ resources-directory }/marks/$INDEX"
                                                                                                                                                        find "${ resources-directory }/pids/$INDEX" -mindepth 1 -maxdepth 1 -type f -exec basename {} \; | while read -r PID
                                                                                                                                                        do
                                                                                                                                                            tail --follow /dev/null --pid "$PID"
                                                                                                                                                        done
                                                                                                                                                        find "${ gc-root-directory }/$INDEX" -mindepth 1 -type l | while read -r LINK
                                                                                                                                                        do
                                                                                                                                                            FILE="$( readlink --canonicalize "$LINK" )" || failure 15150
                                                                                                                                                            if [[ "${ resources-directory }/mounts/$INDEX" == "$FILE" ]]
                                                                                                                                                            then
                                                                                                                                                                inotify-wait --event delete-self "$LINK"
                                                                                                                                                            fi
                                                                                                                                                        done
                                                                                                                                                        exec 203> "${ resources-directory }/locks/$HASH"
                                                                                                                                                        flock -x 203
                                                                                                                                                        exec 204> "${ resources-directory }/locks/$INDEX"
                                                                                                                                                        flock -x 204
                                                                                                                                                        if [[ -e "${ resources-directory }/marks/$INDEX" ]]
                                                                                                                                                        then
                                                                                                                                                            rm "${ resources-directory }/canonical/$HASH"
                                                                                                                                                            flock -u 203
                                                                                                                                                            ARCHIVE="$( mktemp --dry-run --suffix ".tar.xz" )" || failure 7546
                                                                                                                                                            tar --create --xz --file "$ARCHIVE" "${ gc-root-directory }/$INDEX" "${ resources-directory }/mounts/$INDEX" "${ resources-directory }/pids/$INDEX" "${ resources-directory }/release/$INDEX"
                                                                                                                                                            rm --recursive --force "${ gc-root-directory }/$INDEX" "${ resources-directory }/mounts/$INDEX" "${ resources-directory }/pids/$INDEX" "${ resources-directory }/release/$INDEX"
                                                                                                                                                        else
                                                                                                                                                            flock -u 203
                                                                                                                                                            flock -u 204
                                                                                                                                                            nohup "$0" &
                                                                                                                                                        fi
                                                                                                                                                    '' ;
                                                                                                                                        }
                                                                                                                                        release ;
                                                                                                                            }
                                                                                                                    )
                                                                                                                ] ;
                                                                                                    }
                                                                                            )
                                                                                        ] ;
                                                                                    text =
                                                                                        ''
                                                                                            mkdir --parents "${ gc-root-directory }/$INDEX"
                                                                                            export HASH=$HASH
                                                                                            export INDEX=$INDEX
                                                                                            destroy
                                                                                        '' ;
                                                                                } ;
                                                                        in
                                                                            pkgs.writeShellApplication
                                                                                {
                                                                                    name = "create" ;
                                                                                    runtimeInputs = [ applications.init failure pid pkgs.coreutils pkgs.flock pkgs.gnused pkgs.jq sequential trace ] ;
                                                                                    text =
                                                                                        visitor
                                                                                            {
                                                                                                lambda =
                                                                                                    path : value :
                                                                                                        let
                                                                                                            a = arguments.init pkgs ;
                                                                                                            in
                                                                                                                ''
                                                                                                                    trace 5542 "$*"
                                                                                                                    mkdir --parents ${ resources-directory }/logs
                                                                                                                    INDEX="$( sequential )" || failure 5607
                                                                                                                    export INDEX
                                                                                                                    exec 204> "${ resources-directory }/locks/$INDEX"
                                                                                                                    flock -x 204
                                                                                                                    pid "$ULTIMATE_PID" ${ builtins.toString depth } "$INDEX"
                                                                                                                    mkdir --parents ${ resources-directory }/marks
                                                                                                                    touch "${ resources-directory }/marks/$INDEX"
                                                                                                                    mkdir --parents "${ resources-directory }/mounts/$INDEX"
                                                                                                                    mkdir --parents "${ resources-directory }/release"
                                                                                                                    RELEASE="${ resources-directory }/release/$INDEX"
                                                                                                                    sed -e "s#\$HASH#$HASH#" -e "s#\$INDEX#$INDEX#" -e "w$RELEASE" ${ destroy }/bin/destroy > /dev/null 2>&1
                                                                                                                    chmod 0500 "$RELEASE"
                                                                                                                    ARGUMENTS="$( printf '%s\n' "$@" | jq --raw-input . | jq --slurp . )" || failure 14587
                                                                                                                    # shellcheck disable=SC2016
                                                                                                                    SCRIPT_FILE="$( ${ script-file init a } )"
                                                                                                                    SEED='${ builtins.toJSON seed }'
                                                                                                                    STANDARD_ERROR_SEQUENCE="$( sequential )" || failure 7574
                                                                                                                    STANDARD_ERROR_FILE="${ resources-directory }/logs/$STANDARD_ERROR_SEQUENCE"
                                                                                                                    STANDARD_OUTPUT_SEQUENCE="$( sequential )" || failure 21462
                                                                                                                    STANDARD_OUTPUT_FILE="${ resources-directory }/logs/$STANDARD_OUTPUT_SEQUENCE"
                                                                                                                    trace 21750 "$@"
                                                                                                                    if init "$@" > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                                                                    then
                                                                                                                        STATUS="$?"
                                                                                                                    else
                                                                                                                        STATUS="$?"
                                                                                                                    fi
                                                                                                                    TARGETS_OBSERVED="$( find "${resources-directory}/mounts/$INDEX" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort | jq --raw-input . | jq --compact-output --slurp . )" || failure 28445
                                                                                                                    JSON_SEQUENCE="$( sequential )" || failure 32761
                                                                                                                    JSON_FILE="${ resources-directory }/logs/$JSON_SEQUENCE"
                                                                                                                    jq \
                                                                                                                        --compact-output \
                                                                                                                        --null-input \
                                                                                                                        --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                                                        --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                                                        --arg HASH "$HASH" \
                                                                                                                        --arg INDEX "$INDEX" \
                                                                                                                        --arg RELEASE "$RELEASE" \
                                                                                                                        --arg SCRIPT_FILE "$SCRIPT_FILE" \
                                                                                                                        --arg SCRIPTS_HASH "$SCRIPTS_HASH" \
                                                                                                                        --argjson SEED "$SEED" \
                                                                                                                        --arg STANDARD_ERROR_FILE "$STANDARD_ERROR_FILE" \
                                                                                                                        --arg STANDARD_INPUT_FILE "$STANDARD_INPUT_FILE" \
                                                                                                                        --arg STANDARD_OUTPUT_FILE "$STANDARD_OUTPUT_FILE" \
                                                                                                                        --arg STATUS "$STATUS" \
                                                                                                                        --argjson TARGETS_EXPECTED "$TARGETS_EXPECTED" \
                                                                                                                        --argjson TARGETS_OBSERVED "$TARGETS_OBSERVED" \
                                                                                                                        '{
                                                                                                                            "arguments" : $ARGUMENTS ,
                                                                                                                            "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                                                            "hash" : $HASH ,
                                                                                                                            "index" : $INDEX ,
                                                                                                                            "release" : $RELEASE ,
                                                                                                                            "script-file" : $SCRIPT_FILE ,
                                                                                                                            "scripts-hash" : $SCRIPTS_HASH ,
                                                                                                                            "seed" : $SEED ,
                                                                                                                            "standard-error-file" : $STANDARD_ERROR_FILE ,
                                                                                                                            "standard-input-file" : $STANDARD_INPUT_FILE ,
                                                                                                                            "standard-output-file" : $STANDARD_OUTPUT_FILE ,
                                                                                                                            "status" : $STATUS ,
                                                                                                                            "targets-expected" : $TARGETS_EXPECTED ,
                                                                                                                            "targets-observed" : $TARGETS_OBSERVED
                                                                                                                        }' > "$JSON_FILE"
                                                                                                                    chmod 0400 "$STANDARD_OUTPUT_FILE" "$STANDARD_ERROR_FILE" "$JSON_FILE"
                                                                                                                    if [[ "$STATUS" == 0 ]] && [[ ! -s "$STANDARD_ERROR_FILE" ]] && [[ "$TARGETS_EXPECTED" == "$TARGETS_OBSERVED" ]]
                                                                                                                    then
                                                                                                                        mkdir --parents ${ resources-directory }/canonical
                                                                                                                        ln --symbolic "${ resources-directory }/mounts/$INDEX" "${ resources-directory }/canonical/$HASH"
                                                                                                                        redis-cli PUBLISH ${ valid-init-channel } "$JSON_FILE" > /dev/null 2>&1 || true
                                                                                                                        echo "${ resources-directory }/mounts/$INDEX"
                                                                                                                    else
                                                                                                                        redis-cli PUBLISH ${ invalid-init-channel } "$JSON_FILE" > /dev/null 2>&1 || true
                                                                                                                        echo "${ resources-directory }/mounts/$INDEX"
                                                                                                                        failure 30398 "$JSON_FILE" "STATUS=$STATUS" "A=$A" "B=$B" "TARGETS_EXPECTED=$TARGETS_EXPECTED" "TARGETS_OBSERVED=$TARGETS_OBSERVED"
                                                                                                                    fi
                                                                                                                '' ;
                                                                                                null =
                                                                                                    path : value :
                                                                                                        ''
                                                                                                            INDEX="$( sequential )" || failure 5607
                                                                                                            export INDEX
                                                                                                            mkdir --parents ${ resources-directory }/marks
                                                                                                            touch "${ resources-directory }/marks/$INDEX"
                                                                                                            mkdir --parents "${ resources-directory }/mounts/$INDEX"
                                                                                                            ARGUMENTS="$( printf '%s\n' "$@" | jq --raw-input . | jq --slurp . )" || failure 14587
                                                                                                            mkdir --parents ${ resources-directory }/release
                                                                                                            RELEASE="${ resources-directory }/release/$INDEX"
                                                                                                            sed -e "s#\$HASH#$HASH#" -e "s#\$INDEX#$INDEX#" -e "w$RELEASE" ${ destroy }/bin/destroy > /dev/null 2>&1
                                                                                                            chmod 0500 "$RELEASE"
                                                                                                            SEED='${ builtins.toJSON seed }'
                                                                                                            JSON_SEQUENCE="$( sequential )" || failure 32761
                                                                                                            JSON_FILE="${ resources-directory }/logs/$JSON_SEQUENCE"
                                                                                                            jq \
                                                                                                                --compact-output \
                                                                                                                --null-input \
                                                                                                                --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                                                --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                                                --arg HASH "$HASH" \
                                                                                                                --arg INDEX "$INDEX" \
                                                                                                                --arg RELEASE "$RELEASE" \
                                                                                                                --arg SEED "$SEED" \
                                                                                                                --arg STATUS "$STATUS" \
                                                                                                                '{
                                                                                                                    "arguments" : $ARGUMENTS ,
                                                                                                                    "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                                                    "hash" : $HASH ,
                                                                                                                    "release" : $RELEASE ,
                                                                                                                    "seed" : $SEED ,
                                                                                                                    "index" : $INDEX ,
                                                                                                                }' > "$JSON_FILE"
                                                                                                            chmod 0400 "$JSON_FILE"
                                                                                                            ln --symbolic "${ resources-directory }/mounts/$INDEX" "/canonical/$HASH"
                                                                                                            redis-cli PUBLISH ${ valid-init-channel } "$JSON_FILE" > /dev/null 2>&1 || true
                                                                                                            echo "${ resources-directory }/mounts/$HASH"
                                                                                                        '' ;
                                                                                            }
                                                                                            init ;
                                                                                }
                                                                )
                                                            ] ;
                                            } ;
                                        failure =
                                            buildFHSUserEnv
                                                {
                                                    name = "failure" ;
                                                    runScript =
                                                        ''
                                                            bash -c '
                                                                if [[ -t 0 ]]
                                                                then
                                                                    failure "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }"
                                                                else
                                                                    failure "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" <&0
                                                                fi
                                                            ' "$0" "$@"
                                                        '' ;
                                                    targetPkgs =
                                                        pkgs :
                                                            [
                                                                (
                                                                    pkgs.writeShellApplication
                                                                        {
                                                                            name = "failure" ;
                                                                            runtimeInputs = [ pkgs.coreutils pkgs.jq pkgs.yq-go ] ;
                                                                            text =
                                                                                ''
                                                                                    ARGUMENTS="$( printf '%s\n' "$@" | jq --raw-input . | jq --slurp . )" || exit 74
                                                                                    if [[ -t 0 ]]
                                                                                    then
                                                                                        # shellcheck disable=SC2016
                                                                                        jq \
                                                                                            --null-input \
                                                                                            --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                            '{ "arguments" : $ARGUMENTS }'
                                                                                    else
                                                                                        STANDARD_INPUT="$( cat )" || exit 65
                                                                                        # shellcheck disable=SC2016
                                                                                        jq \
                                                                                            --null-input \
                                                                                            --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                            --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                                            '{ "arguments" : $ARGUMENTS , "standard-input" : $STANDARD_INPUT }'
                                                                                    fi
                                                                                    exit 66
                                                                                '' ;
                                                                        }
                                                                )
                                                            ] ;
                                                } ;
                                        gc-root =
                                            buildFHSUserEnv
                                                {
                                                    name = "gc-root" ;
                                                    runScript =
                                                        ''
                                                            bash -c '
                                                                if [[ -t 0 ]]
                                                                then
                                                                    gc-root "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }"
                                                                else
                                                                    gc-root "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" <&0
                                                                fi
                                                            ' "$0" "$@"
                                                        '' ;
                                                    targetPkgs =
                                                        pkgs :
                                                            [
                                                                (
                                                                    pkgs.writeShellApplication
                                                                        {
                                                                            name = "gc-root" ;
                                                                            runtimeInputs = [ pkgs.coreutils trace ] ;
                                                                            text =
                                                                                ''
                                                                                    TARGET="$1"
                                                                                    DIRECTORY="$( dirname "$TARGET" )" || failure 30095
                                                                                    SEQUENCE="$( sequence )" || failure 18737
                                                                                    mkdir --parents "${ gc-root-directory }/$INDEX/$SEQUENCE/$DIRECTORY"
                                                                                    ln --symbolic "$TARGET" "${ gc-root-directory }/$INDEX/SEQUENCE/$DIRECTORY"
                                                                                    trace Rooted "TARGET=$TARGET" at "DESTINATION=${ gc-root-directory }/$INDEX/SEQUENCE/$DIRECTORY"
                                                                                '' ;
                                                                        }
                                                                )
                                                            ] ;
                                                } ;
                                        pid =
                                            buildFHSUserEnv
                                                {
                                                    name = "pid" ;
                                                    runScript =
                                                        ''
                                                            bash -c '
                                                                if [[ -t 0 ]]
                                                                then
                                                                    pid "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }"
                                                                else
                                                                    pid "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" <&0
                                                                fi
                                                            ' "$0" "$@"
                                                        '' ;
                                                    targetPkgs =
                                                        pkgs :
                                                            [
                                                                (
                                                                    pkgs.writeShellApplication
                                                                        {
                                                                            name = "pid" ;
                                                                            runtimeInputs = [ coreutils failure procps ] ;
                                                                            text =
                                                                                ''
                                                                                    CHILD="$1"
                                                                                    DEPTH="$2"
                                                                                    INDEX="$3"
                                                                                    mkdir --parents "${ resources-directory }/pids/$INDEX"
                                                                                    touch "${ resources-directory }/pids/$INDEX/$CHILD"
                                                                                    chmod 0400 "${ resources-directory }/pids/$INDEX/$CHILD"
                                                                                    if [[ "$DEPTH" -gt "0" ]] && [[ "$CHILD" -gt "1" ]]
                                                                                    then
                                                                                        PARENT="$( ps -o ppid= -p "$CHILD" | tr -d '[:space:]' )" || failure 7862
                                                                                        NEXT=$(( DEPTH - 1 ))
                                                                                        "$0" "$PARENT" "$NEXT" "$INDEX"
                                                                                    fi
                                                                                '' ;
                                                                        }
                                                                    )
                                                                ] ;
                                                } ;
                                        script-file =
                                            script : arguments :
                                                let
                                                    application =
                                                        buildFHSUserEnv
                                                            {
                                                                name = "script" ;
                                                                runScript = "script" ;
                                                                targetPkgs =
                                                                    pkgs :
                                                                        [
                                                                            (
                                                                                pkgs.writeShellApplication
                                                                                    {
                                                                                        name = "script" ;
                                                                                        runtimeInputs = [ failure pkgs.coreutils sequential ] ;
                                                                                        text =
                                                                                            let
                                                                                                application =
                                                                                                    let
                                                                                                        application =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "application" ;
                                                                                                                    text = script arguments ;
                                                                                                                } ;
                                                                                                            in "${ application }/bin/application" ;
                                                                                                in
                                                                                                    ''
                                                                                                        SEQUENCE="$( sequential )" || failure 18903
                                                                                                        FILE="${ resources-directory }/logs/$SEQUENCE"
                                                                                                        ln --symbolic ${ application } "$FILE"
                                                                                                        echo "$FILE"
                                                                                                    '' ;
                                                                                    }
                                                                            )
                                                                        ] ;
                                                            } ;
                                                    in "${ application }/bin/script" ;
                                        scripts-hash =
                                            buildFHSUserEnv
                                                {
                                                    name = "scripts-hash" ;
                                                    runScript = "scripts-hash" ;
                                                    targetPkgs =
                                                        pkgs :
                                                            [
                                                                (
                                                                    pkgs.writeShellApplication
                                                                        {
                                                                            name = "scripts-hash" ;
                                                                            text =
                                                                                let
                                                                                    scripts-hash =
                                                                                        visitor
                                                                                            {
                                                                                                lambda =
                                                                                                    path : value :
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "script" ;
                                                                                                                runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                                text =
                                                                                                                    let
                                                                                                                        a =
                                                                                                                            if builtins.typeOf path == "list" && builtins.length path == 1 && builtins.typeOf ( builtins.elemAt path 0 ) == "string" && builtins.elemAt path 0 == "init" then arguments.init pkgs
                                                                                                                            else arguments.release pkgs ;
                                                                                                                        in builtins.hashString "sha512" ( builtins.concatStringsSep "" ( builtins.concatLists [ path [ ( builtins.toString ( value a ) ) ] ] ) ) ;
                                                                                                            } ;
                                                                                                list = path : list : builtins.hashString "sha512" ( builtins.toJSON [ path list ] ) ;
                                                                                                null = path : value : builtins.hashString "sha512" ( builtins.concatStringsSep "" path ) ;
                                                                                                set = path : set : builtins.hashString "sha512" ( builtins.toJSON [ path set ] ) ;
                                                                                            }
                                                                                            {
                                                                                                init = init ;
                                                                                                init-resolutions = init-resolutions ;
                                                                                                invalid-init-channel = invalid-init-channel ;
                                                                                                invalid-release-channel = invalid-release-channel ;
                                                                                                release = release ;
                                                                                                release-resolutions = release-resolutions ;
                                                                                                stale-init-channel = stale-init-channel ;
                                                                                                valid-init-channel = valid-init-channel ;
                                                                                                valid-release-channel = valid-release-channel ;
                                                                                            } ;
                                                                                    in
                                                                                        ''
                                                                                            echo ${ scripts-hash }
                                                                                        '' ;
                                                                        }
                                                                )
                                                            ] ;
                                                } ;
                                        sequential =
                                            buildFHSUserEnv
                                                {
                                                    name = "sequential" ;
                                                    runScript = "sequential" ;
                                                    targetPkgs =
                                                        pkgs :
                                                            [
                                                                (
                                                                    pkgs.writeShellApplication
                                                                        {
                                                                            name = "sequential" ;
                                                                            runtimeInputs = [ failure pkgs.coreutils pkgs.flock ] ;
                                                                            text =
                                                                                ''
                                                                                    mkdir --parents ${ resources-directory }/sequential
                                                                                    mkdir --parents ${ resources-directory }/locks
                                                                                    exec 203> ${ resources-directory }/locks/sequential
                                                                                    flock -x 203
                                                                                    if [[ -s ${ resources-directory }/sequential/sequential.counter ]]
                                                                                    then
                                                                                        CURRENT="$( cat ${ resources-directory }/sequential/sequential.counter )" || failure 5766
                                                                                    else
                                                                                        CURRENT=0
                                                                                    fi
                                                                                    NEXT=$(( ( CURRENT + 1 ) % 10000000000000000 ))
                                                                                    echo "$NEXT" > ${ resources-directory }/sequential/sequential.counter
                                                                                    printf "%016d\n" "$CURRENT"
                                                                                    rm ${ resources-directory }/locks/sequential
                                                                                '' ;
                                                                        }
                                                                )
                                                            ] ;
                                                text =
                                                    ''
                                                        if [[ -s /sequential/sequential.counter ]]
                                                        then
                                                            CURRENT="$( cat /sequential/sequential.counter )" || failure 5766
                                                        else
                                                            CURRENT=0
                                                        fi
                                                        NEXT=$(( ( CURRENT + 1 ) % 10000000000000000 ))
                                                        echo "$NEXT" > /sequential/sequential.counter
                                                        printf "%016d\n" "$CURRENT"
                                                    '' ;
                                            } ;
                                        trace =
                                            buildFHSUserEnv
                                                {
                                                    name = "trace" ;
                                                    runScript =
                                                        ''
                                                            bash -c '
                                                                trace "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" <&0
                                                            ' "$0" "$@"
                                                        '' ;
                                                    targetPkgs =
                                                        pkgs :
                                                            [
                                                                (
                                                                    pkgs.writeShellApplication
                                                                        {
                                                                            name = "trace" ;
                                                                            runtimeInputs = [ pkgs.jq pkgs.yq-go ] ;
                                                                            text =
                                                                                ''
                                                                                    ARGUMENTS="$( printf '%s\n' "$@" | jq --raw-input . | jq --slurp . )" || failure 22397
                                                                                    # shellcheck disable=SC2016
                                                                                    jq \
                                                                                        --compact-output \
                                                                                        --null-input \
                                                                                        --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                        '$ARGUMENTS' | yq eval --prettyPrint "[.]" \
                                                                                        >> ${ resources-directory }/logs/trace.log.yaml
                                                                                '' ;
                                                                        }
                                                                )
                                                            ] ;
                                                } ;
                                        wrap =
                                            buildFHSUserEnv
                                                {
                                                    name = "wrap" ;
                                                    runScript =
                                                        ''
                                                            bash -c '
                                                                if [[ -t 0 ]]
                                                                then
                                                                    wrap "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }"
                                                                else
                                                                    wrap "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" <&0
                                                                fi
                                                            ' "$0" "$@"
                                                        '' ;
                                                    targetPkgs =
                                                        pkgs :
                                                            [
                                                                (
                                                                    pkgs.writeShellApplication
                                                                        {
                                                                            name = "wrap" ;
                                                                            runtimeInputs = [ failure pkgs.coreutils pkgs.gnugrep pkgs.gnused ] ;
                                                                            text =
                                                                                ''
                                                                                    if [[ 3 -gt "$#" ]]
                                                                                    then
                                                                                        failure 4721 "We were expecting input output permissions but we observed $# arguments:  $*"
                                                                                    fi
                                                                                    INPUT="$1"
                                                                                    if [[ ! -f "$INPUT" ]]
                                                                                    then
                                                                                        failure 14159 "We were expecting the first argument $INPUT to be a file but we observed $*"
                                                                                    fi
                                                                                    UUID=""
                                                                                    shift
                                                                                    OUTPUT="$1"
                                                                                    if [[ -e "/mount/$OUTPUT" ]]
                                                                                    then
                                                                                        failure 3790 "We were expecting the second argument $OUTPUT to not (yet) exist but we observed $*"
                                                                                    fi
                                                                                    OUTPUT_DIRECTORY="$( dirname "/mount/$OUTPUT" )" || failure 20962
                                                                                    mkdir --parents "$OUTPUT_DIRECTORY"
                                                                                    shift
                                                                                    PERMISSIONS="$1"
                                                                                    if [[ ! $PERMISSIONS =~ ^-?[0-9]+$ ]]
                                                                                    then
                                                                                        failure 18129 "We were expecting the third argument to be an integer but we observed $*"
                                                                                    fi
                                                                                    ALLOWED_PLACEHOLDERS=()
                                                                                    COMMANDS=()
                                                                                    shift
                                                                                    while [[ "$#" -gt 0 ]]
                                                                                    do
                                                                                        case "$1" in
                                                                                            --inherit)
                                                                                                if [[ "$#" -lt 3 ]]
                                                                                                then
                                                                                                    failure 22854 "We were expecting --inherit STYLE VARIABLE but we observed $*"
                                                                                                fi
                                                                                                STYLE="$2"
                                                                                                VARIABLE="$3"
                                                                                                VALUE="${ builtins.concatStringsSep "" [ "$" "{" "!VARIABLE" "}" ] }"
                                                                                                if [[ "$STYLE" == "brace" ]]
                                                                                                then
                                                                                                    BRACED="${ builtins.concatStringsSep "" [ "\\" "$" "{" "$VARIABLE" "}" ] }"
                                                                                                elif [[ "$STYLE" == "plain" ]]
                                                                                                then
                                                                                                    BRACED="\$$VARIABLE"
                                                                                                else
                                                                                                    failure 32719 "We were expecting brace or plain but we got $STYLE" "$*"
                                                                                                fi
                                                                                                if [[ -z "${ builtins.concatStringsSep "" [ "$" "{" "VARIABLE+x" "}" ] }" ]]
                                                                                                then
                                                                                                    failure 11096 "We were expecting $VARIABLE to be in the environment but it is not" "$*"
                                                                                                fi
                                                                                                if ! grep --fixed-string "$BRACED" "$INPUT"
                                                                                                then
                                                                                                    failure 28342 "We were expecting inherit $BRACED to be in the input file but it was not" "$*"
                                                                                                fi
                                                                                                ALLOWED_PLACEHOLDERS+=( "$BRACED" )
                                                                                                COMMANDS+=( -e "s#$BRACED#$VALUE#g" )
                                                                                                shift 3
                                                                                                ;;
                                                                                            --literal)
                                                                                                if [[ "$#" -lt 3 ]]
                                                                                                then
                                                                                                    failure 11868 "We were expecting --literal STYLE VARIABLE but we observed $*"
                                                                                                fi
                                                                                                STYLE="$2"
                                                                                                VARIABLE="$3"
                                                                                                if [[ "$STYLE" == "brace" ]]
                                                                                                then
                                                                                                    BRACED="${ builtins.concatStringsSep "" [ "\\" "$" "{" "$VARIABLE" "}" ] }"
                                                                                                elif [[ "$STYLE" == "plain" ]]
                                                                                                then
                                                                                                    BRACED="\$$VARIABLE"
                                                                                                fi
                                                                                                if ! grep --fixed-string "$BRACED" "$INPUT"
                                                                                                then
                                                                                                    failure 9160 "We were expecting literal $BRACED to be in the input file but it was not" "$*"
                                                                                                fi
                                                                                                ALLOWED_PLACEHOLDERS+=( "$BRACED" )
                                                                                                # With sed we do not need to do anything for literal-brace
                                                                                                shift 3
                                                                                                ;;
                                                                                            --set)
                                                                                                if [[ "$#" -lt 4 ]]
                                                                                                then
                                                                                                    failure 25685 "We were expecting --set STYLE VARIABLE VALUE but we observed $*"
                                                                                                fi
                                                                                                STYLE="$2"
                                                                                                VARIABLE="$3"
                                                                                                VALUE="$4"
                                                                                                if [[ "$STYLE" == "brace" ]]
                                                                                                then
                                                                                                    BRACED="${ builtins.concatStringsSep "" [ "\\" "$" "{" "$VARIABLE" "}" ] }"
                                                                                                elif [[ "$STYLE" == "plain" ]]
                                                                                                then
                                                                                                    BRACED="\$$VARIABLE"
                                                                                                else
                                                                                                    failure 5029 "We were expecting brace or plain but we got $STYLE" "$*"
                                                                                                fi
                                                                                                if ! grep -F --quiet "$BRACED" "$INPUT"
                                                                                                then
                                                                                                    failure 19050 "We were expecting set $BRACED to be in the input file but it was not" "$*"
                                                                                                fi
                                                                                                ALLOWED_PLACEHOLDERS+=( "$BRACED" )
                                                                                                COMMANDS+=( -e "s#$BRACED#$VALUE#g" )
                                                                                                shift 4
                                                                                                ;;
                                                                                            --uuid)
                                                                                                UUID="$2"
                                                                                                shift 2
                                                                                                ;;
                                                                                            *)
                                                                                                failure 15883 "We were expecting --inherit, --literal, --set, or --uuid but we observed $*"
                                                                                        esac
                                                                                    done
                                                                                    mapfile --trim-newline FOUND_PLACEHOLDERS < <(
                                                                                        grep --only-matching --extended-regexp '\$\{[A-Za-z_][A-Za-z0-9_]*\}|\$[A-Za-z_][A-Za-z0-9_]*' "$INPUT" | sort --unique
                                                                                    )
                                                                                    UNRESOLVED=()
                                                                                    for PLACE_HOLDER in "${ builtins.concatStringsSep "" [ "$" "{" "FOUND_PLACEHOLDERS[@]" "}" ] }"
                                                                                    do
                                                                                        FOUND=false
                                                                                        for ALLOWED in "${ builtins.concatStringsSep "" [ "$" "{" "ALLOWED_PLACEHOLDERS[@]" "}" ] }"
                                                                                        do
                                                                                            if [[ "$PLACE_HOLDER" == "$ALLOWED" ]]
                                                                                            then
                                                                                                FOUND=true
                                                                                                break
                                                                                            fi
                                                                                        done
                                                                                        if ! $FOUND
                                                                                        then
                                                                                            UNRESOLVED+=( "$PLACE_HOLDER" )
                                                                                        fi
                                                                                    done
                                                                                    if [[ "${ builtins.concatStringsSep "" [ "$" "{" "#UNRESOLVED[@]" "}" ] }" -ne 0 ]]
                                                                                    then
                                                                                        failure 31558 "Unresolved placeholders in input file: ${ builtins.concatStringsSep "" [ "$" "{" "UNRESOLVED[*]" "}" ] }" "INPUT=$INPUT" "OUTPUT=$OUTPUT" "ALLOWED_PLACEHOLDERS=${ builtins.concatStringsSep "" [ "$" "{" "ALLOWED_PLACEHOLDERS[*]" "}" ] }" "UUID=$UUID"
                                                                                    fi
                                                                                    sed "${ builtins.concatStringsSep "" [ "$" "{" "COMMANDS[@]" "}" ] }" -e "w/mount/$OUTPUT" "$INPUT"
                                                                                    chmod "$PERMISSIONS" "/mount/$OUTPUT"
                                                                                '' ;
                                                                        }
                                                                )
                                                            ] ;
                                                } ;
                                        in
                                            let
                                                application =
                                                    writeShellApplication
                                                        {
                                                            name = "setup" ;
                                                            runtimeInputs = [ coreutils create failure flock jq pid scripts-hash sequential trace ] ;
                                                            text =
                                                                let
                                                                    stringable =
                                                                        let
                                                                            breaker =
                                                                                let
                                                                                    mapper =
                                                                                        name : value :
                                                                                            if name == "resources" then
                                                                                                {
                                                                                                    resources = true ;
                                                                                                    value = null ;
                                                                                                }
                                                                                            else
                                                                                                {
                                                                                                    resources = false ;
                                                                                                    value = value ;
                                                                                                } ;
                                                                                    in builtins.mapAttrs mapper primary ;
                                                                            stringable =
                                                                                path : value :
                                                                                    let
                                                                                        resources = if value == resources then true else false ;
                                                                                        type = builtins.typeOf value ;
                                                                                        in
                                                                                            {
                                                                                                path = path ;
                                                                                                type = type ;
                                                                                                value = if type == "lambda" then null else value ;
                                                                                            } ;
                                                                        in
                                                                            visitor
                                                                                {
                                                                                    bool = stringable ;
                                                                                    int = stringable ;
                                                                                    float = stringable ;
                                                                                    lambda = path : value : { path = path ; type = "lambda" ; value = null ; } ;
                                                                                    null = stringable ;
                                                                                    path = stringable ;
                                                                                    string = stringable ;
                                                                                }
                                                                                [ breaker secondary ] ;
                                                                    transient_ =
                                                                        visitor
                                                                            {
                                                                                bool =
                                                                                    path : value :
                                                                                        if value then "$( sequential ) || failure 13613"
                                                                                        else "-1" ;
                                                                            }
                                                                            transient ;
                                                                    in
                                                                        ''
                                                                            STANDARD_INPUT_SEQUENCE="$( sequential )" || failure 27125
                                                                            mkdir --parents "${ resources-directory }/logs"
                                                                            STANDARD_INPUT_FILE="${ resources-directory }/logs/$STANDARD_INPUT_SEQUENCE"
                                                                            if [[ -t 0 ]]
                                                                            then
                                                                                HAS_STANDARD_INPUT=false
                                                                                touch "$STANDARD_INPUT_FILE"
                                                                                chmod 0400 "$STANDARD_INPUT_FILE"
                                                                                ULTIMATE_PID="$( ps -o ppid= -p "$PPID" | tr -d '[:space:]' )" || failure 28567
                                                                            else
                                                                                STANDARD_INPUT_FILE="$( mktemp )" || failure 29248
                                                                                export STANDARD_INPUT_FILE
                                                                                HAS_STANDARD_INPUT=true
                                                                                cat > "$STANDARD_INPUT_FILE"
                                                                                chmod 0400 "$STANDARD_INPUT_FILE"
                                                                                PENULTIMATE_PID="$( ps -o ppid= -p "$PPID" | tr -d '[:space:]' )" || failure 27339
                                                                                ULTIMATE_PID="$( ps -o ppid= -p "$PENULTIMATE_PID" | tr -d '[:space:]' )" || failure 17331
                                                                            fi
                                                                            ARGUMENTS="$( printf '%s\n' "$@" | jq --raw-input . | jq --slurp . )" || failure 14587
                                                                            PRE_HASH='${ builtins.hashString "sha512" ( builtins.toJSON stringable ) }'
                                                                            SCRIPTS_HASH="$( scripts-hash )" || failure 15672
                                                                            STANDARD_INPUT_HASH="$( sha512sum "$STANDARD_INPUT_FILE" | cut --characters -128 )" || failure 12800
                                                                            # shellcheck disable=SC2089
                                                                            TARGETS_EXPECTED='${ builtins.toJSON ( builtins.sort ( a : b : a < b ) targets ) }'
                                                                            TRANSIENT=${ transient_ }
                                                                            HASH="$( echo "$ARGUMENTS" "$HAS_STANDARD_INPUT" "$PRE_HASH" "$SCRIPTS_HASH" "$STANDARD_INPUT_HASH" "$TRANSIENT" | sha512sum | cut --characters 1-128 )" || failure 21086
                                                                            mkdir --parents "${ resources-directory }/locks"
                                                                            exec 203> "${ resources-directory }/locks/$HASH"
                                                                            flock -x 203
                                                                            if [[ -L "${ resources-directory }/canonical/$HASH" ]]
                                                                            then
                                                                                LINK="$( readlink --canonicalize "${ resources-directory }/canonical/$HASH" )" || failure 3789
                                                                                INDEX="$( basename "$LINK" )" || failure 13919
                                                                                exec 204> "${ resources-directory }/locks/$INDEX"
                                                                                flock -s 204
                                                                                mkdir --parents ${ resources-directory }/marks
                                                                                touch "${ resources-directory }/marks/$INDEX"
                                                                                mkdir --parents "${ resources-directory }/pids/$INDEX"
                                                                                pid "$ULTIMATE_PID" ${ builtins.toString depth } "$INDEX"
                                                                                SEED='${ builtins.toJSON seed }'
                                                                                echo "${ resources-directory }/mounts/$INDEX"
                                                                                JSON_SEQUENCE="$( sequential )" || failure 30634
                                                                                JSON_FILE="${ resources-directory }/logs/$JSON_SEQUENCE"
                                                                                jq \
                                                                                    --null-input \
                                                                                    --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                    --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                    --arg HASH "$HASH" \
                                                                                    --arg INDEX "$INDEX" \
                                                                                    --arg SCRIPTS_HASH "$SCRIPTS_HASH" \
                                                                                    --argjson SEED "$SEED" \
                                                                                    --arg STANDARD_INPUT_FILE "$STANDARD_INPUT_FILE" \
                                                                                    --argjson TARGETS_EXPECTED "$TARGETS_EXPECTED" \
                                                                                    --arg TRANSIENT "$TRANSIENT" \
                                                                                    '{
                                                                                        "arguments" : $ARGUMENTS ,
                                                                                        "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                        "hash" : $HASH ,
                                                                                        "index" : $INDEX ,
                                                                                        "scripts-hash" : $SCRIPTS_HASH ,
                                                                                        "seed" : $SEED ,
                                                                                        "standard-input-file" : $STANDARD_INPUT_FILE ,
                                                                                        "targets-expected" : $TARGETS_EXPECTED ,
                                                                                        "transient" : $TRANSIENT
                                                                                    }' > "$JSON_FILE"
                                                                                redis-cli PUBLISH "${ stale-init-channel }" "$JSON_FILE" > /dev/null 2>&1 || true
                                                                            else
                                                                                export HAS_STANDARD_INPUT
                                                                                export HASH
                                                                                export SCRIPTS_HASH
                                                                                export STANDARD_INPUT_FILE
                                                                                # shellcheck disable=SC2090
                                                                                export TARGETS_EXPECTED
                                                                                export ULTIMATE_PID
                                                                                trace 17539 "$*"
                                                                                create "$@"
                                                                                trace "$*"
                                                                            fi
                                                                        '' ;
                                                        } ;
                                                in "${ application }/bin/setup" ;
                            in
                                {
                                    check =
                                        {
                                            depth ? 0 ,
                                            expected ? "" ,
                                            init ? null ,
                                            init-resolutions ? null ,
                                            invalid-init-channel ? "25169" ,
                                            invalid-release-channel ? "30428" ,
                                            mkDerivation ,
                                            release ? null ,
                                            release-resolutions ? null ,
                                            resources ? null ,
                                            seed ? 17507 ,
                                            setup ? setup : setup ,
                                            stale-init-channel ? "8476" ,
                                            targets ? [ ] ,
                                            transient ? false ,
                                            valid-init-channel ? "5475" ,
                                            valid-release-channel ? "31093"
                                        } :
                                            mkDerivation
                                                {
                                                    installPhase = "check" ;
                                                    name = "check" ;
                                                    nativeBuildInputs =
                                                        [
                                                            (
                                                                writeShellApplication
                                                                    {
                                                                        name = "check" ;
                                                                        runtimeInputs = [ coreutils ] ;
                                                                        text =
                                                                            let
                                                                                observed =
                                                                                    implementation
                                                                                        {
                                                                                            depth = depth ;
                                                                                            init = init ;
                                                                                            init-resolutions = init-resolutions ;
                                                                                            invalid-init-channel = invalid-init-channel ;
                                                                                            invalid-release-channel = invalid-release-channel ;
                                                                                            release = release ;
                                                                                            release-resolutions = release-resolutions ;
                                                                                            seed = seed ;
                                                                                            stale-init-channel = stale-init-channel ;
                                                                                            targets = targets ;
                                                                                            transient = transient ;
                                                                                            valid-init-channel = valid-init-channel ;
                                                                                            valid-release-channel = valid-release-channel ;
                                                                                        } ;
                                                                                in
                                                                                    if expected == observed then
                                                                                        ''
                                                                                            : "${ builtins.concatStringsSep "" [ "$" "{" "out:?must be exported" "}" ] }"
                                                                                            touch "$out"
                                                                                        ''
                                                                                    else
                                                                                        ''
                                                                                            : "${ builtins.concatStringsSep "" [ "$" "{" "out:?must be exported" "}" ] }"
                                                                                            echo "We were expecting" >&2
                                                                                            echo >&2
                                                                                            echo '${ expected }' >&2
                                                                                            echo "but we observed " >&2
                                                                                            echo >&2
                                                                                            echo '${ observed }' > "$out"
                                                                                            cat "$out" >&2
                                                                                            exit 64
                                                                                        '' ;
                                                                    }
                                                            )
                                                        ] ;
                                                    src = ./. ;
                                                } ;
                                    implementation = implementation ;
                                } ;
            } ;
}
