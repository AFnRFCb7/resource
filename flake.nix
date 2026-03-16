# 12772
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
                        invalid-init-channel ,
                        jq ,
                        procps ,
                        redis ,
                        resources ,
                        resources-directory ,
                        stale-init-channel ,
                        valid-init-channel ,
                        visitor ,
                        writeShellApplication
                    } @primary :
                        let
                            implementation =
                                {
                                    depth ,
                                    init ,
                                    init-resolutions ,
                                    release ,
                                    release-resolutions ,
                                    seed ,
                                    targets ,
                                    transient
                                } @secondary :
                                    let
                                        environments =
                                            let
                                                mapper  =
                                                    name : { extraBwrapArgs , pre , post , targetPkgs , text } :
                                                        writeShellApplication
                                                            {
                                                                name = name ;
                                                                runtimeInputs =
                                                                    [
                                                                        coreutils
                                                                        flock
                                                                        (
                                                                            buildFHSUserEnv
                                                                                {
                                                                                    extraBwrapArgs = extraBwrapArgs ;
                                                                                    name = name ;
                                                                                    runScript =
                                                                                        ''
                                                                                            bash -c '
                                                                                                if [[ -t 0 ]]
                                                                                                then
                                                                                                    ${ name } "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }"
                                                                                                else
                                                                                                    ${ name } "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" <&0
                                                                                                fi
                                                                                            ' "$0" "$@"
                                                                                        '' ;
                                                                                    targetPkgs =
                                                                                        pkgs :
                                                                                            [
                                                                                                (
                                                                                                    writeShellApplication
                                                                                                        {
                                                                                                            name = name ;
                                                                                                            runtimeInputs = ( targetPkgs pkgs ) ;
                                                                                                            text = text ;
                                                                                                        }
                                                                                                )
                                                                                            ] ;
                                                                                }
                                                                        )
                                                                    ] ;
                                                                text =
                                                                    ''
                                                                        ${ pre }
                                                                        if [[ -t 0 ]]
                                                                        then
                                                                            ${ name } "$@"
                                                                        else
                                                                            ${ name } "@" <&0
                                                                        fi
                                                                        ${ post }
                                                                    '' ;
                                                            } ;
                                                set =
                                                    {
                                                        create =
                                                            {
                                                                extraBwrapArgs = [ ''--bind ${ resources-directory }/canonical'' ''--bind ${ resources-directory }/log /log'' ] ;
                                                                post = "" ;
                                                                pre =
                                                                    ''
                                                                        mkdir --parents "${ resources-directory }/canonical"
                                                                        mkdir --parents "${ resources-directory }/log"
                                                                    '' ;
                                                                targetPkgs = pkgs : [ environments.failure environments.sequential environments.init environments.sequential pkgs.coreutils ] ;
                                                                text =
                                                                    ''
                                                                        INDEX="$( sequential )" || failure 5607
                                                                        export INDEX
                                                                        ARGUMENTS=( "$@" )
                                                                        ARGUMENTS_JSON="$( printf '%s\n' "${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] }" | jq -R . | jq -s . )" || failure 14587
                                                                        STANDARD_ERROR_SEQUENCE="$( sequential )" || failure 7574
                                                                        STANDARD_OUTPUT_SEQUENCE="$( sequential )" || failure 7574
                                                                        if init "$@" > "/log/$STANDARD_OUTPUT_SEQUENCE" 2> "/log/$STANDARD_ERROR_SEQUENCE"
                                                                        then
                                                                            STATUS="$?"
                                                                        else
                                                                            STATUS="$?"
                                                                        fi
                                                                        chmod 0400 "/log/$STANDARD_OUTPUT_SEQUENCE" "/log/$STANDARD_ERROR_SEQUENCE"
                                                                        JSON_SEQUENCE="$( sequential )" || failure 32761
                                                                        jq \
                                                                            --null-input \
                                                                            --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                            --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                            --arg HASH "$HASH" \
                                                                            --arg STANDARD_ERROR_SEQUENCE "$STANDARD_ERROR_SEQUENCE" \
                                                                            --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                            --arg STANDARD_OUTPUT_SEQUENCE "$STANDARD_OUTPUT_SEQUENCE" \
                                                                            '{
                                                                                "arguments" : $ARGUMENTS ,
                                                                                "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                "hash" : $HASH ,
                                                                                "standard-error-sequence" : $STANDARD_ERROR_SEQUENCE ,
                                                                                "standard-input" : $STANDARD_INPUT ,
                                                                                "standard-output-sequence" : $STANDARD_OUTPUT_SEQUENCE
                                                                            }' > "/log/$JSON_SEQUENCE"
                                                                        if [[ "$STATUS" == 0 ]] && [[ ! -s "$STANDARD_ERROR_FILE" ]] && [[ "$TARGETS_EXPECTED" == "$TARGETS_OBSERVED" ]]
                                                                        then
                                                                            ln --symbolic "${ resources-directory }/mounts/$INDEX" "/canonical/$HASH"
                                                                            redis-cli PUBLISH ${ valid-init-channel } "$JSON_SEQUENCE" > /dev/null 2>&1 || true
                                                                            echo "````${ resources-directory }/mounts/$HASH"
                                                                        else
                                                                            redis-cli PUBLISH ${ invalid-init-channel } "$JSON_SEQUENCE" > /dev/null 2>&1 || true
                                                                            echo "${ resources-directory }/mounts/$HASH"
                                                                            failure 21103
                                                                        fi
                                                                    '' ;
                                                            } ;
                                                        failure =
                                                            {
                                                                extraBwrapArgs = [ ] ;
                                                                post = "" ;
                                                                pre = "" ;
                                                                targetPkgs = pkgs : [ pkgs.coreutils pkgs.yq-go ] ;
                                                                text =
                                                                    ''
                                                                        ARGUMENTS="$( printf '%s\n' "$@" | yq eval --raw-input . | yq eval --slurp . - )" || exit 33
                                                                        if [[ -t 0 ]]
                                                                        then
                                                                            # shellcheck disable=SC2016
                                                                            yq \
                                                                                eval \
                                                                                --null-input \
                                                                                --prettyPrint \
                                                                                --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                '{ "arguments" : $ARGUMENTS }'
                                                                        else
                                                                            STANDARD_INPUT="$( cat )" || failure 65
                                                                            # shellcheck disable=SC2016
                                                                            yq \
                                                                                eval \
                                                                                --null-input \
                                                                                --prettyPrint \
                                                                                --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                                '{ "arguments" : $ARGUMENTS , "standard-input" : $STANDARD_INPUT }'
                                                                        fi
                                                                        exit 66
                                                                    '' ;
                                                            } ;
                                                        gc-root =
                                                            {
                                                                extraBwrapArgs = [ "--bind ${ gc-root-directory } /gc-root" ] ;
                                                                post = "" ;
                                                                pre =
                                                                    ''
                                                                        mkdir --parents ${ gc-root-directory }
                                                                    '' ;
                                                                targetPkgs = pkgs : [ pkgs.coreutils environments.failure ] ;
                                                                text =
                                                                    ''
                                                                        TARGET="$1"
                                                                        DIRECTORY="$( dirname "$TARGET" )" || failure 30095
                                                                        mkdir --parents "/root/$INDEX/$DIRECTORY"
                                                                        ln --symbolic --force "$TARGET" "/gc-root/$INDEX$DIRECTORY"
                                                                    '' ;
                                                            } ;
                                                        init =
                                                            {
                                                                extraBwrapArgs =
                                                                    [
                                                                        ''"${ resources-directory }/mounts/$INDEX" /mount''
                                                                        "--tmpfs /scratch"
                                                                    ] ;
                                                                post = "" ;
                                                                pre =
                                                                    ''
                                                                        mkdir --parents "${ resources-directory }/mounts/$INDEX"
                                                                    '';
                                                                targetPkgs =
                                                                    pkgs :
                                                                        [
                                                                            (
                                                                                pkgs.writeShellApplication
                                                                                    {
                                                                                        name = "init" ;
                                                                                        text =
                                                                                            visitor
                                                                                                {
                                                                                                    lambda =
                                                                                                        path : value :
                                                                                                            let
                                                                                                                arguments =
                                                                                                                    {
                                                                                                                        failure = environments.failure ;
                                                                                                                        gc-root = environments.gc-root ;
                                                                                                                        pkgs = pkgs ;
                                                                                                                        resources = resources ;
                                                                                                                        seed = seed ;
                                                                                                                        trace = environments.trace ;
                                                                                                                        sequential = environments.sequential ;
                                                                                                                        wrap = environments.wrap ;
                                                                                                                    } ;
                                                                                                                in value arguments ;
                                                                                                    null = path : value : "true" ;
                                                                                                }
                                                                                                init ;
                                                                                    }
                                                                            )
                                                                        ] ;
                                                                text =
                                                                    ''
                                                                        if "$HAS_STANDARD_INPUT"
                                                                        then
                                                                            init "$@" <<< "$STANDARD_INPUT"
                                                                        else
                                                                            init "$@"
                                                                        fi
                                                                    '' ;
                                                            } ;
                                                        scripts =
                                                            {
                                                                extraBwrapArgs = [ ] ;
                                                                post = "" ;
                                                                pre = "" ;
                                                                targetPkgs =
                                                                    pkgs :
                                                                        [
                                                                            (
                                                                                pkgs.writeShellApplication
                                                                                    {
                                                                                        name = "scripts" ;
                                                                                        runtimeInputs = [ ] ;
                                                                                        text =
                                                                                            let
                                                                                                scripts =
                                                                                                    visitor
                                                                                                        {
                                                                                                            lambda =
                                                                                                                path : value :
                                                                                                                    let
                                                                                                                        arguments =
                                                                                                                            if typeOf path == "list" && builtins.typeOf ( builtins.elemAt path 0 ) == "string" && builtins.elemAt path 0 == "init" && builtins.typeOf ( builtins.elemAt path 1 ) == "string" && builtins.elemAt path 1 == "task" then
                                                                                                                                builtins.trace "NO" {
                                                                                                                                    failure = environments.failure ;
                                                                                                                                    gc-root = environments.gc-root ;
                                                                                                                                    pkgs = pkgs ;
                                                                                                                                    resources = resources ;
                                                                                                                                    seed = seed ;
                                                                                                                                    trace = environments.trace ;
                                                                                                                                    sequential = environments.sequential ;
                                                                                                                                    wrap = environments.wrap ;
                                                                                                                                }
                                                                                                                            else builtins.trace "YES ${ ( builtins.toJSON path ) }"
                                                                                                                                {
                                                                                                                                    failure = environments.failure ;
                                                                                                                                    pkgs = pkgs ;
                                                                                                                                    resources = resources ;
                                                                                                                                    seed = seed ;
                                                                                                                                    trace = environments.trace ;
                                                                                                                                    sequential = environments.sequential ;
                                                                                                                                } ;
                                                                                                                            in value arguments ;
                                                                                                            null = path : value : null ;
                                                                                                        }
                                                                                                        {
                                                                                                            init =
                                                                                                                {
                                                                                                                    task = init ;
                                                                                                                    resolutions = init-resolutions ;
                                                                                                                } ;
                                                                                                            release =
                                                                                                                {
                                                                                                                    task = release ;
                                                                                                                    resolutions = release-resolutions ;
                                                                                                                } ;
                                                                                                        } ;
                                                                                                in
                                                                                                    ''
                                                                                                        jq --null-input --arg-json SCRIPTS '${ builtins.toJSON scripts }' '$SCRIPTS'
                                                                                                    '' ;
                                                                                    }
                                                                            )
                                                                        ] ;
                                                                text =
                                                                    ''scripts'' ;
                                                            } ;
                                                        sequential =
                                                            {
                                                                extraBwrapArgs = [ "--bind ${ resources-directory }/sequential /sequential" ] ;
                                                                post = "" ;
                                                                pre = "mkdir --parents ${ resources-directory }/sequential" ;
                                                                targetPkgs = pkgs : [ pkgs.coreutils pkgs.flock environments.failure ] ;
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
                                                            {
                                                                extraBwrapArgs = [ "--bind ${ resources-directory }/log /log" ] ;
                                                                post = "rm ${ resources-directory }/lock/trace" ;
                                                                pre =
                                                                    ''
                                                                        mkdir --parents ${ resources-directory }/log
                                                                        mkdir --parents ${ resources-directory }/lock
                                                                        exec 203> ${ resources-directory }/lock/trace
                                                                        flock -x 203
                                                                    '' ;
                                                                targetPkgs = pkgs : [ pkgs.coreutils pkgs.yq-go environments.failure ] ;
                                                                text =
                                                                    ''
                                                                        ARGUMENTS="$( printf '%s\n' "$@" | yq eval --raw-input . | yq eval --slurp . )" || failure 22397
                                                                        if [[ -t 0 ]]
                                                                        then
                                                                            # shellcheck disable=SC2016
                                                                            yq \
                                                                                eval \
                                                                                --null-input \
                                                                                --prettyPrint \
                                                                                --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                '{ "arguments" : $ARGUMENTS }' \
                                                                                >> /log/trace.log.yaml
                                                                        else
                                                                            STANDARD_INPUT="$( cat )" || failure 32061
                                                                            # shellcheck disable=SC2016
                                                                            yq \
                                                                                eval \
                                                                                --null-input \
                                                                                --prettyPrint \
                                                                                --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                                '{ "arguments" : $ARGUMENTS , "standard-input" : $STANDARD_INPUT }' \
                                                                                > /log/trace.log.yaml
                                                                        fi
                                                                    '' ;
                                                            } ;
                                                        wrap =
                                                            {
                                                                extraBwrapArgs = [ ''--bindfs "${ resources-directory }/mounts/$INDEX" /mount'' ] ;
                                                                post = "" ;
                                                                pre =
                                                                    ''
                                                                        mkdir --parents "${ resources-directory }/mounts/$INDEX"
                                                                    '' ;
                                                                targetPkgs = pkgs : [ pkgs.coreutils pkgs.gnugrep pkgs.gnused environments.failure ] ;
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
                                                            } ;
                                                    } ;
                                                in builtins.mapAttrs mapper set ;
                                        in
                                            let
                                                application =
                                                    writeShellApplication
                                                        {
                                                            name = "get-or-create" ;
                                                            runtimeInputs = [ environments.create environments.failure environments.scripts coreutils jq procps redis ] ;
                                                            text =
                                                                let
                                                                    stringed =
                                                                        let
                                                                            stringable =
                                                                                path : value :
                                                                                    {
                                                                                        path = path ;
                                                                                        type = builtins.typeOf value ;
                                                                                        value = value ;
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
                                                                            [ primary secondary ] ;
                                                                    in
                                                                        ''
                                                                            if [[ -t 0 ]]
                                                                            then
                                                                                HAS_STANDARD_INPUT=false
                                                                                STANDARD_INPUT=
                                                                                ULTIMATE_PID="$( ps -o ppid= -p "$PPID" | tr -d '[:space:]' )" || failure 28567
                                                                            else
                                                                                STANDARD_INPUT_FILE="$( mktemp )" || failure 29248
                                                                                export STANDARD_INPUT_FILE
                                                                                HAS_STANDARD_INPUT=true
                                                                                cat > "$STANDARD_INPUT_FILE"
                                                                                STANDARD_INPUT="$( cat "$STANDARD_INPUT_FILE" )" || failure 12348
                                                                                PENULTIMATE_PID="$( ps -o ppid= -p "$PPID" | tr -d '[:space:]' )" || failure 27339
                                                                                ULTIMATE_PID="$( ps -o ppid= -p "$PENULTIMATE_PID" | tr -d '[:space:]' )" || failure 17331
                                                                            fi
                                                                            ARGUMENTS=( "$@" )
                                                                            ARGUMENTS_JSON="$( printf '%s\n' "${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] }" | jq -R . | jq -s . )" || failure 14587
                                                                            TRANSIENT=${ visitor { bool = path : value : if value then "$( sequential ) || failure 5672" else "-1" ; } transient }
                                                                            SCRIPTS="$( scripts )" || failure 31964
                                                                            HASH="$( echo "${ builtins.hashString "sha512" ( builtins.toJSON stringed ) } ${ builtins.concatStringsSep " " [ "$" "{" "ARGUMENTS[*]" "}" ] } $HAS_STANDARD_INPUT" "$SCRIPTS" "$STANDARD_INPUT" "$TRANSIENT" | sha512sum | cut --characters 1-128 )" || failure 21086
                                                                            if [[ -L "${ resources-directory }/mounts/$HASH" ]]
                                                                            then
                                                                                LINK="$( readlink --canonical "${ resources-directory }/mounts/$HASH" )" || failure 3789
                                                                                INDEX="$( basename "$LINK" )" || failure 13919
                                                                                mkdir --parents "${ resources-directory }/originator-pids/$INDEX"
                                                                                touch "${ resources-directory }/originator-pids/$INDEX/$ULTIMATE_PID"
                                                                                echo "${ resources-directory }/mounts/$HASH"
                                                                                JSON_SEQUENCE="$( sequential )" || failure 30634
                                                                                JSON_FILE="${ resources-directory }/log/$JSON_SEQUENCE"
                                                                                jq \
                                                                                    --null-output \
                                                                                    --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                                    --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                    --arg HASH "$HASH" \
                                                                                    --arg INDEX "$INDEX" \
                                                                                    --argjson SCRIPTS "$SCRIPTS" \
                                                                                    --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                                    --arg TRANSIENT "$TRANSIENT" \
                                                                                    '{
                                                                                        "arguments" : $ARGUMENTS ,
                                                                                        "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                        "hash" : $HASH ,
                                                                                        "index" : $INDEX ,
                                                                                        "scripts" : $SCRIPTS ,
                                                                                        "standard-input" : $STANDARD_INPUT ,
                                                                                        "transient" : $TRANSIENT
                                                                                    }' > "$JSON_FILE"
                                                                                redis-cli PUBLISH "${ stale-init-channel }" "$JSON_FILE"
                                                                            else
                                                                                export HAS_STANDARD_INPUT
                                                                                export HASH
                                                                                export STANDARD_INPUT
                                                                                export TRANSIENT
                                                                                create "$@"
                                                                            fi
                                                                        '' ;
                                                        } ;
                                                in builtins.toString ( "${ application }/bin/get-or-create" ) ;
                            in
                                {
                                    check =
                                        {
                                            depth ? 0 ,
                                            expected ? "" ,
                                            init ? null ,
                                            init-resolutions ? null ,
                                            mkDerivation ,
                                            release ? null ,
                                            release-resolutions ? null ,
                                            resources ? null ,
                                            seed ? 17507 ,
                                            setup ? setup : setup ,
                                            targets ? [ ] ,
                                            transient ? false ,
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
                                                                                            release = release ;
                                                                                            release-resolutions = release-resolutions ;
                                                                                            seed = seed ;
                                                                                            targets = targets ;
                                                                                            transient = transient ;
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
