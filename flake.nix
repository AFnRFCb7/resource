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
                        sequential-start ,
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
                                                                        ARGUMENTS="$( printf '%s\n' "$@" | yq eval --raw-input . | yq eval --slurp . )" || exit 68
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
                                                                                                                            if builtins.typeOf path == "list" && builtins.typeOf ( builtins.elemAt path 0 ) == "string" && builtins.elemAt path 0 == "init" && builtins.typeOf ( builtins.elemAt path 1 ) == "string" && builtins.elemAt 1 == "task" then
                                                                                                                                {
                                                                                                                                    failure = environments.failure ;
                                                                                                                                    gc-root = environments.gc-root ;
                                                                                                                                    pkgs = pkgs ;
                                                                                                                                    resources = resources ;
                                                                                                                                    seed = seed ;
                                                                                                                                    trace = environments.trace ;
                                                                                                                                    sequential = environments.sequential ;
                                                                                                                                    wrap = environments.wrap ;
                                                                                                                                }
                                                                                                                            else
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
                                                                            CURRENT=${ sequential-start }
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
                                        get-or-create =
                                            writeShellApplication
                                                {
                                                    name = "get-or-create" ;
                                                    runtimeInputs = [ environments.create environments.failure coreutils jq procps redis ] ;
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
                                        in
                                            {
                                                lazy ? false ,
                                                failure ? 10996 ,
                                                setup ? setup : "${ setup }"
                                            } :
                                                builtins.concatStringsSep
                                                    ""
                                                    [
                                                        ( visitor { bool = path : value : if value then setup "${ get-or-create }/bin/get-or-create" else setup "${ get-or-create }/bin/get-or-create" ; } lazy )
                                                        " || "
                                                        "${ environments.failure }/bin/failure ${ builtins.toString failure }"
                                                    ] ;
                            in
                                {
                                    check =
                                        {
                                            buildFHSUserEnv ,
                                            depth ? 0 ,
                                            expected-standard-error ? null ,
                                            expected-invalid-init ? null ,
                                            expected-resource ? "18955" ,
                                            expected-stale-init ? null ,
                                            expected-status ? 0 ,
                                            expected-valid-init ,
                                            failure ? 12489 ,
                                            fixture ?
                                                { gc-root-directory , resources-directory } :
                                                    let
                                                        application =
                                                            writeShellApplication
                                                                {
                                                                    name = "fixture" ;
                                                                    runtimeInputs = [ coreutils ] ;
                                                                    text =
                                                                        ''
                                                                            mkdir --parents ${ resources-directory }/sequential
                                                                            echo 9068 > ${ resources-directory }/sequential/sequential.counter ,
                                                                        '' ;
                                                                } ;
                                                        in "${ application }/bin/fixture" ,
                                            gc-root-directory ? "/build/gc-root" ,
                                            init ? null ,
                                            init-resolutions ? null ,
                                            invalid-init-channel ? "23567" ,
                                            lazy ? false ,
                                            mkDerivation ,
                                            release ? null ,
                                            release-resolutions ? null ,
                                            resources ? null ,
                                            resources-directory ? "/build/resources" ,
                                            seed ? 17507 ,
                                            sequential-start ? "16669" ,
                                            setup ? setup : setup ,
                                            stale-init-channel ? "21286" ,
                                            targets ? [ ] ,
                                            transient ? false ,
                                            valid-init-channel ? "21286" ,
                                            writeShellApplication
                                        } :
                                            mkDerivation
                                                {
                                                    installPhase =
                                                        let
                                                            application =
                                                                writeShellApplication
                                                                    {
                                                                        name = "check" ;
                                                                        runtimeInputs = [ coreutils ] ;
                                                                        text =
                                                                            ''
                                                                                : "${ builtins.concatStringsSep "" [ "$" "{" "out:?out must be exported" "}" ] }
                                                                                mkdir --parents "$out"
                                                                                check
                                                                            '' ;
                                                                    } ;
                                                                in "${ application }/bin/check" ;
                                                    name = "check" ;
                                                    nativeBuildInputs =
                                                        [
                                                            (
                                                                buildFHSUserEnv
                                                                    {
                                                                        extraBwrapArgs =
                                                                            [
                                                                                "--bind /build/redis" "/redis"
                                                                                "--bind $out /out"
                                                                            ] ;
                                                                        name = "check" ;
                                                                        runScript =
                                                                            let
                                                                                application =
                                                                                    writeShellApplication
                                                                                        {
                                                                                            name = "check" ;
                                                                                            text = "check" ;
                                                                                        } ;
                                                                                    in "${ application }/bin/check" ;
                                                                        targetPkgs =
                                                                            pkgs :
                                                                                [
                                                                                    (
                                                                                        pkgs.writeShellApplication
                                                                                            {
                                                                                                name = "check" ;
                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.redis ] ;
                                                                                                text =
                                                                                                    let
                                                                                                        resource =
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
                                                                                                            ''
                                                                                                                mkdir --parents /build/redis
                                                                                                                redis-server --dir /build/redis --daemonize yes
                                                                                                                while ! redis-cli ping
                                                                                                                do
                                                                                                                    sleep 0
                                                                                                                done
                                                                                                                fixture
                                                                                                                nohup subscribe stale-init-channel > /dev/null 2>&1 &
                                                                                                                nohup subscribe valid-init-channel > /dev/null 2>&1 &
                                                                                                                nohup subscribe invalid-init-channel > /dev/null 2>&1 &
                                                                                                                if OBSERVED_RESOURCE=${ resource { failure = failure ; lazy = lazy ; setup = setup ; } } 2> /build/standard-error
                                                                                                                then
                                                                                                                    OBSERVED_STATUS="$?"
                                                                                                                else
                                                                                                                    OBSERVED_STATUS="$?"
                                                                                                                fi
                                                                                                                EXPECTED_STANDARD_ERROR='${ visitor { null = path : value : "" ; string = path : value : value ; } expected-standard-error }'
                                                                                                                OBSERVED_STANDARD_ERROR="$( cat /build/standard-error )" || failure 3231
                                                                                                                if [[ -f ${ resources-directory }/log/trace.log ]]
                                                                                                                then
                                                                                                                    cat ${ resources-directory }/log/trace.log
                                                                                                                fi
                                                                                                                if [[ "$EXPECTED_STANDARD_ERROR" != "$OBSERVED_STANDARD_ERROR" ]]
                                                                                                                then
                                                                                                                    failure 30877 "EXPECTED_STANDARD_ERROR=$EXPECTED_STANDARD_ERROR" "OBSERVED_STANDARD_ERROR=$OBSERVED_STANDARD_ERROR"
                                                                                                                elif [[ ${ builtins.toString expected-status } != "$OBSERVED_STATUS" ]]
                                                                                                                then
                                                                                                                    failure 94defd57 "EXPECTED_STATUS=${ builtins.toString expected-status }" "OBSERVED_STATUS=$OBSERVED_STATUS"
                                                                                                                fi
                                                                                                                if [[ "${ expected-resource }" != "$OBSERVED_RESOURCE" ]]
                                                                                                                then
                                                                                                                    failure f780406e "EXPECTED_RESOURCE=${ expected-resource }" "OBSERVED_RESOURCE=$OBSERVED_RESOURCE"
                                                                                                                fi
                                                                                                                mkdir --parents "$OUT/expected"
                                                                                                                cat > "/out/expected/stale-init.json" <<EOF
                                                                                                                ${ builtins.toJSON expected-stale-init }
                                                                                                                EOF
                                                                                                                cat > "/out/expected/valid-init.json" <<EOF
                                                                                                                ${ builtins.toJSON expected-valid-init }
                                                                                                                EOF
                                                                                                                cat > "/out/expected/invalid-init.json" <<EOF
                                                                                                                ${ builtins.toJSON expected-invalid-init }
                                                                                                                EOF
                                                                                                                chmod 0400 "/out/expected/stale-init.json" "/out/expected/valid-init.json" "/out/expected/invalid-init.json"
                                                                                                                if ! jd "/out/expected/stale-init.json" "/out/observed/stale-init.json"
                                                                                                                then
                                                                                                                    failure 979
                                                                                                                elif ! jd "/out/expected/valid-init.json" "/out/observed/valid-init.json"
                                                                                                                then
                                                                                                                    failure 24531
                                                                                                                elif ! jd "/out/expected/invalid-init.json" "/out/observed/invalid-init.json"
                                                                                                                then
                                                                                                                    failure 13198
                                                                                                                fi
                                                                                                            '' ;
                                                                                            }
                                                                                    )
                                                                                    (
                                                                                        pkgs.writeShellApplication
                                                                                            {
                                                                                                name = "fixture" ;
                                                                                                runtimeInputs = [ ] ;
                                                                                                text =
                                                                                                    visitor
                                                                                                        {
                                                                                                            lambda = path : value : value { gc-root-directory = gc-root-directory ; resources-directory = resources-directory ; } ;
                                                                                                            null = path : value : "" ;
                                                                                                        }
                                                                                                        fixture ;
                                                                                            }
                                                                                    )
                                                                                    (
                                                                                        pkgs.writeShellApplication
                                                                                            {
                                                                                                name = "resource" ;
                                                                                                text =
                                                                                                    ''
                                                                                                    '' ;
                                                                                            }
                                                                                    )
                                                                                    (
                                                                                        pkgs.writeShellApplication
                                                                                            {
                                                                                                 name = "subscribe" ;
                                                                                                 runtimeInputs = [ coreutils redis ] ;
                                                                                                 text =
                                                                                                    ''
                                                                                                        CHANNEL="$1"
                                                                                                        redis-cli --raw SUBSCRIBE "$CHANNEL" | {
                                                                                                            read -r _     # skip "subscribe"
                                                                                                            read -r _     # skip channel name
                                                                                                            read -r _     # skip
                                                                                                            read -r _     # skip
                                                                                                            read -r _
                                                                                                            read -r PAYLOAD
                                                                                                            mkdir --parents "/out/observed"
                                                                                                            echo "$PAYLOAD" > "/out/observed/$CHANNEL.json"
                                                                                                            chmod 0400 "/out/observed/$CHANNEL.json"
                                                                                                        }
                                                                                                    '' ;
                                                                                            }
                                                                                    )
                                                                                ] ;
                                                                    }
                                                            )
                                                        ] ;
                                                    src = ./. ;
                                                } ;
                                    implementation = implementation ;
                                } ;
            } ;
}
