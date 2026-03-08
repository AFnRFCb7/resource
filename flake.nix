# 1ff73b56
{
	inputs = { } ;
	outputs =
		{ self } :
		    {
		        lib =
                    {
                        buildFHSUserEnv ,
                        channel ,
                        coreutils ,
                        failure ,
                        findutils ,
                        flock ,
                        gnutar ,
                        inotify-tools ,
                        jq ,
                        makeWrapper ,
                        mkDerivation ,
                        nix ,
                        ps ,
                        redis ,
                        resources ,
                        resources-directory ,
                        root-directory ,
                        sequential-start ,
                        util-linux ,
                        visitor ,
                        writeShellApplication ,
                        yq-go ,
                        zstd
                    } @primary :
                        let
                            description =
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
                                        seed = path : value : if builtins.typeOf value == "lambda" then null else value ;
                                        in
                                            visitor
                                                {
                                                    bool = seed ;
                                                    float = seed ;
                                                    int = seed ;
                                                    lambda = seed ;
                                                    list = seed ;
                                                    null = seed ;
                                                    path = seed ;
                                                    set = seed ;
                                                    string = seed ;
                                                }
                                                { primary = primary ; secondary = secondary ; } ;
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
                                            applications =
                                                visitor
                                                    {
                                                        lambda =
                                                            path : value :
                                                                buildFHSUserEnv
                                                                    {
                                                                        extraBwrapArgs =
                                                                            [
                                                                                "--bind $MOUNT /mount"
                                                                                "--tmpfs /scratch"
                                                                            ] ;
                                                                        name = if builtins.length path == 2 then builtins.elemAt path 0 else "resolve" ;
                                                                        runScript =
                                                                            ''
                                                                                bash -c '
                                                                                    if [[ -t 0 ]]
                                                                                    then
                                                                                        init "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }"
                                                                                    else
                                                                                        init "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" <&0
                                                                                    fi
                                                                                ' "$0" "$@"
                                                                            '' ;
                                                                        targetPkgs =
                                                                            pkgs :
                                                                                [
                                                                                    (
                                                                                        pkgs.writeShellApplication
                                                                                            {
                                                                                                name = "init" ;
                                                                                                runtimeInputs = [ ] ;
                                                                                                text =
                                                                                                    let
                                                                                                        t = tools pkgs ;
                                                                                                        v =
                                                                                                            let
                                                                                                                arguments =
                                                                                                                    if builtins.length path == 2 && builtins.elemAt path 0 == "init" then { failure = t.failure ; pkgs = t.pkgs ; resources = t.resources ; root = t.root ; seed = t.seed ; sequential = t.sequential ; wrap = t.wrap ; }
                                                                                                                    else { failure = t.failure ; pkgs = t.pkgs ; resources = t.resources ; seed = t.seed ; sequential = t.sequential ; } ;
                                                                                                                in value arguments ;
                                                                                                        in ''${ v } "$@"'' ;
                                                                                            }
                                                                                    )
                                                                                ] ;
                                                                    } ;
                                                        list = path : list : list ;
                                                        null = path : value : true ;
                                                        set = path : set : set ;
                                                    }
                                                    {
                                                        init =
                                                            {
                                                                application = init ;
                                                                resolutions = init-resolutions ;
                                                            } ;
                                                        release =
                                                            {
                                                                application = release ;
                                                                resolutions = release-resolutions ;
                                                            } ;
                                                    } ;
                                            scripts =
                                                visitor
                                                    {
                                                        lambda =
                                                            path : value :
                                                                buildFHSUserEnv
                                                                    {
                                                                        name = if builtins.length path == 2 then builtins.elemAt path 1 else "resolve" ;
                                                                        runScript =
                                                                            ''
                                                                                bash -c '
                                                                                    if [[ -t 0 ]]
                                                                                    then
                                                                                        init "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }"
                                                                                    else
                                                                                        init "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" <&0
                                                                                    fi
                                                                                ' "$0" "$@"
                                                                            '' ;
                                                                        targetPkgs =
                                                                            pkgs :
                                                                                [
                                                                                    (
                                                                                        pkgs.writeShellApplication
                                                                                            {
                                                                                                name = "init" ;
                                                                                                runtimeInputs = [ ] ;
                                                                                                text =
                                                                                                    let
                                                                                                        t = tools pkgs ;
                                                                                                        v =
                                                                                                            let
                                                                                                                arguments =
                                                                                                                    if builtins.length path == 2 && builtins.elemAt path 0 == "init" then { failure = t.failure ; pkgs = t.pkgs ; resources = t.resources ; root = t.root ; seed = t.seed ; sequential = t.sequential ; wrap = t.wrap ; }
                                                                                                                    else { failure = t.failure ; pkgs = t.pkgs ; resources = t.resources ; seed = t.seed ; sequential = t.sequential ; } ;
                                                                                                                in value arguments ;
                                                                                                        in ''echo ${ v } "$@"'' ;
                                                                                            }
                                                                                    )
                                                                                ] ;
                                                                    } ;
                                                        list = path : list : list ;
                                                        null = path : value : null ;
                                                        set = path : set : set ;
                                                    }
                                                    {
                                                        init =
                                                            {
                                                                application = init ;
                                                                resolutions = init-resolutions ;
                                                            } ;
                                                        release =
                                                            {
                                                                application = release ;
                                                                resolutions = release-resolutions ;
                                                            } ;
                                                    } ;
                                            tools =
                                                pkgs :
                                                    let
                                                        wrap =
                                                            pkgs.buildFHSUserEnv
                                                                {
                                                                    extraBwrapArgs = [ "--bind $MOUNT /mount" ] ;
                                                                    name = "wrap" ;
                                                                    runScript =
                                                                        let
                                                                            application =
                                                                                pkgs.writeShellApplication
                                                                                    {
                                                                                        name = "runScript" ;
                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.gnugrep pkgs.gnused failure ] ;
                                                                                        text =
                                                                                            ''
                                                                                                if [[ 3 -gt "$#" ]]
                                                                                                then
                                                                                                    failure 4b5fcf01 "We were expecting input output permissions but we observed $# arguments:  $*"
                                                                                                fi
                                                                                                INPUT="$1"
                                                                                                if [[ ! -f "$INPUT" ]]
                                                                                                then
                                                                                                    failure 2c068d47 "We were expecting the first argument $INPUT to be a file but we observed $*"
                                                                                                fi
                                                                                                UUID=""
                                                                                                shift
                                                                                                OUTPUT="$1"
                                                                                                if [[ -e "/mount/$OUTPUT" ]]
                                                                                                then
                                                                                                    failure 9887df89 "We were expecting the second argument $OUTPUT to not (yet) exist but we observed $*"
                                                                                                fi
                                                                                                OUTPUT_DIRECTORY="$( dirname "/mount/$OUTPUT" )" || failure a3308d94
                                                                                                mkdir --parents "$OUTPUT_DIRECTORY"
                                                                                                shift
                                                                                                PERMISSIONS="$1"
                                                                                                if [[ ! $PERMISSIONS =~ ^-?[0-9]+$ ]]
                                                                                                then
                                                                                                    failure 029e9461 "We were expecting the third argument to be an integer but we observed $*"
                                                                                                fi
                                                                                                ALLOWED_PLACEHOLDERS=()
                                                                                                COMMANDS=()
                                                                                                shift
                                                                                                while [[ "$#" -gt 0 ]]
                                                                                                do
                                                                                                    case "$1" in
                                                                                                        --inherit-brace)
                                                                                                            if [[ "$#" -lt 2 ]]
                                                                                                            then
                                                                                                                failure 20b59d3f "We were expecting --inherit VARIABLE but we observed $*"
                                                                                                            fi
                                                                                                            VARIABLE="$2"
                                                                                                            VALUE="${ builtins.concatStringsSep "" [ "$" "{" "!VARIABLE" "}" ] }"
                                                                                                            BRACED="${ builtins.concatStringsSep "" [ "\\" "$" "{" "$VARIABLE" "}" ] }"
                                                                                                            if [[ -z "${ builtins.concatStringsSep "" [ "$" "{" "VARIABLE+x" "}" ] }" ]]
                                                                                                            then
                                                                                                                failure 159a6642 "We were expecting $VARIABLE to be in the environment but it is not"
                                                                                                            fi
                                                                                                            if ! grep -F --quiet "$BRACED" "$INPUT"
                                                                                                            then
                                                                                                                failure 545c8e1f "We were expecting inherit $BRACED to be in the input file but it was not" "$*"
                                                                                                            fi
                                                                                                            ALLOWED_PLACEHOLDERS+=( "$BRACED" )
                                                                                                            COMMANDS+=( -e "s#$BRACED#$VALUE#g" )
                                                                                                            shift 2
                                                                                                            ;;
                                                                                                        --inherit-plain)
                                                                                                            if [[ "$#" -lt 2 ]]
                                                                                                            then
                                                                                                                failure 20b59d3f "We were expecting --inherit VARIABLE but we observed $*"
                                                                                                            fi
                                                                                                            VARIABLE="$2"
                                                                                                            : "${ builtins.concatStringsSep "" [ "$" "{" "!VARIABLE:?Environment variable $VARIABLE must be exported" "}" ] }"
                                                                                                            VALUE="${ builtins.concatStringsSep "" [ "$" "{" "!VARIABLE" "}" ] }"
                                                                                                            BRACED="\$$VARIABLE"
                                                                                                            if [[ -z "${ builtins.concatStringsSep "" [ "$" "{" "VARIABLE+x" "}" ] }" ]]
                                                                                                            then
                                                                                                                failure 8dd04f7e "We were expecting $VARIABLE to be in the environment but it is not"
                                                                                                            fi
                                                                                                            if ! grep -F --quiet "$VARIABLE" "$INPUT"
                                                                                                            then
                                                                                                                failure 50950711 "We were expecting inherit $VARIABLE to be in the input file but it was not" "$*"
                                                                                                            fi
                                                                                                            ALLOWED_PLACEHOLDERS+=( "\$$VARIABLE" )
                                                                                                            COMMANDS+=( -e "s#$BRACED#$VALUE#g" )
                                                                                                            shift 2
                                                                                                            ;;
                                                                                                        --literal-brace)
                                                                                                            if [[ "$#" -lt 2 ]]
                                                                                                            then
                                                                                                                failure ad1f2615 "We were expecting --literal-brace VARIABLE but we observed $*"
                                                                                                            fi
                                                                                                            VARIABLE="$2"
                                                                                                            BRACED="${ builtins.concatStringsSep "" [ "\\" "$" "{" "$VARIABLE" "}" ] }"
                                                                                                            if ! grep -F --quiet "$BRACED" "$INPUT"
                                                                                                            then
                                                                                                                failure 4074aec1 "We were expecting literal $BRACED to be in the input file but it was not" "$*"
                                                                                                            fi
                                                                                                            ALLOWED_PLACEHOLDERS+=( "$BRACED" )
                                                                                                            # With sed we do not need to do anything for literal-brace
                                                                                                            shift 2
                                                                                                            ;;
                                                                                                        --literal-plain)
                                                                                                            if [[ "$#" -lt 2 ]]
                                                                                                            then
                                                                                                                failure 55186955 "We were expecting --literal-plain VARIABLE but we observed $*"
                                                                                                            fi
                                                                                                            VARIABLE="$2"
                                                                                                            if ! grep -F --quiet "\$$VARIABLE" "$INPUT"
                                                                                                            then
                                                                                                                failure 2a3b187d "We were expecting literal $VARIABLE to be in the input file but it was not" "$*"
                                                                                                            fi
                                                                                                            ALLOWED_PLACEHOLDERS+=( "\$$VARIABLE" )
                                                                                                            # With sed we do not need to do anything for literal-plain
                                                                                                            shift 2
                                                                                                            ;;
                                                                                                        --set-brace)
                                                                                                            if [[ "$#" -lt 3 ]]
                                                                                                            then
                                                                                                                failure ddcc84cc "We were expecting --set VARIABLE VALUE but we observed $*"
                                                                                                            fi
                                                                                                            VARIABLE="$2"
                                                                                                            VALUE="$3"
                                                                                                            BRACED="${ builtins.concatStringsSep "" [ "\\" "$" "{" "$VARIABLE" "}" ] }"
                                                                                                            if ! grep -F --quiet "$BRACED" "$INPUT"
                                                                                                            then
                                                                                                                failure 7e62972e "We were expecting set $BRACED to be in the input file but it was not" "$*"
                                                                                                            fi
                                                                                                            ALLOWED_PLACEHOLDERS+=( "$BRACED" )
                                                                                                            COMMANDS+=( -e "s#$BRACED#$VALUE#g" )
                                                                                                            shift 3
                                                                                                            ;;
                                                                                                        --set-plain)
                                                                                                            if [[ "$#" -lt 3 ]]
                                                                                                            then
                                                                                                                failure ddcc84cc "We were expecting --set VARIABLE VALUE but we observed $*"
                                                                                                            fi
                                                                                                            VARIABLE="$2"
                                                                                                            VALUE="$3"
                                                                                                            BRACED="\$$VARIABLE"
                                                                                                            if ! grep -F --quiet "$VARIABLE" "$INPUT"
                                                                                                            then
                                                                                                                failure 5f62a6be "We were expecting set $VARIABLE to be in the input file but it was not" "INPUT=$INPUT" "OUTPUT=$OUTPUT" "$*"
                                                                                                            fi
                                                                                                            ALLOWED_PLACEHOLDERS+=( "\$$VARIABLE" )
                                                                                                            COMMANDS+=( -e "s#$BRACED#$VALUE#g" )
                                                                                                            shift 3
                                                                                                            ;;
                                                                                                        --uuid)
                                                                                                            UUID="$2"
                                                                                                            shift 2
                                                                                                            ;;
                                                                                                        *)
                                                                                                            failure d40b5fe2 "We were expecting --inherit-brace, --inherit-plain, --literal-brace, --literal-plain, --set-brace, or --set-plain but we observed $*"
                                                                                                    esac
                                                                                                done
                                                                                                mapfile -t FOUND_PLACEHOLDERS < <(
                                                                                                    grep -oE '\$\{[A-Za-z_][A-Za-z0-9_]*\}|\$[A-Za-z_][A-Za-z0-9_]*' "$INPUT" \
                                                                                                    | sort -u
                                                                                                )
                                                                                                UNRESOLVED=()
                                                                                                for PH in "${ builtins.concatStringsSep "" [ "$" "{" "FOUND_PLACEHOLDERS[@]" "}" ] }"
                                                                                                do
                                                                                                    FOUND=false
                                                                                                    for ALLOWED in "${ builtins.concatStringsSep "" [ "$" "{" "ALLOWED_PLACEHOLDERS[@]" "}" ] }"
                                                                                                    do
                                                                                                        if [[ "$PH" == "$ALLOWED" ]]
                                                                                                        then
                                                                                                            FOUND=true
                                                                                                            break
                                                                                                        fi
                                                                                                    done
                                                                                                    if ! $FOUND
                                                                                                    then
                                                                                                        UNRESOLVED+=( "$PH" )
                                                                                                    fi
                                                                                                done
                                                                                                if [[ "${ builtins.concatStringsSep "" [ "$" "{" "#UNRESOLVED[@]" "}" ] }" -ne 0 ]]
                                                                                                then
                                                                                                    failure d6899da6 "Unresolved placeholders in input file: ${ builtins.concatStringsSep "" [ "$" "{" "UNRESOLVED[*]" "}" ] }" "INPUT=$INPUT" "OUTPUT=$OUTPUT" "ALLOWED_PLACEHOLDERS=${ builtins.concatStringsSep "" [ "$" "{" "ALLOWED_PLACEHOLDERS[*]" "}" ] }" "UUID=$UUID"
                                                                                                fi
                                                                                                sed "${ builtins.concatStringsSep "" [ "$" "{" "COMMANDS[@]" "}" ] }" -e "w/mount/$OUTPUT" "$INPUT"
                                                                                                chmod "$PERMISSIONS" "/mount/$OUTPUT"
                                                                                            '' ;
                                                                                    } ;
                                                                                in "${ application }/bin/runScript" ;
                                                                    } ;
                                                        in
                                                            {
                                                                failure = failure ;
                                                                pkgs = pkgs ;
                                                                resources = resources ;
                                                                root =
                                                                    pkgs.writeShellApplication
                                                                        {
                                                                            name = "root" ;
                                                                            runtimeInputs = [ pkgs.coreutils failure ] ;
                                                                            text =
                                                                                ''
                                                                                    TARGET="$1"
                                                                                    DIRECTORY="$( dirname "$TARGET" )" || failure ec2ee582
                                                                                    mkdir --parents "${ root-directory }/$INDEX/$DIRECTORY"
                                                                                    ln --symbolic --force "$TARGET" "${ root-directory }/$INDEX$DIRECTORY"
                                                                                '' ;
                                                                        } ;
                                                                seed = seed ;
                                                                sequential =
                                                                    writeShellApplication
                                                                        {
                                                                            name = "sequential" ;
                                                                            runtimeInputs = [ coreutils failure flock ] ;
                                                                            text =
                                                                                ''
                                                                                    mkdir --parents ${ resources-directory }/sequential
                                                                                    exec 220> ${ resources-directory }/sequential/sequential.lock
                                                                                    flock -x 220
                                                                                    if [[ -s ${ resources-directory }/sequential/sequential.counter ]]
                                                                                    then
                                                                                        CURRENT="$( cat ${ resources-directory }/sequential/sequential.counter )" || failure d3cb7aeb
                                                                                    else
                                                                                        CURRENT=${ sequential-start }
                                                                                    fi
                                                                                    NEXT=$(( ( CURRENT + 1 ) % 10000000000000000 ))
                                                                                    echo "$NEXT" > ${ resources-directory }/sequential/sequential.counter
                                                                                    printf "%016d\n" "$CURRENT"
                                                                                '' ;
                                                                        } ;
                                                                wrap = wrap ;
                                                            } ;
                                            setup_ =
                                                writeShellApplication
                                                    {
                                                        name = "setup" ;
                                                        runtimeInputs =
                                                            [
                                                                coreutils
                                                                findutils
                                                                flock
                                                                jq
                                                                ps
                                                                (
                                                                    writeShellApplication
                                                                        {
                                                                            name = "originator-pid" ;
                                                                            runtimeInputs = [ coreutils ps failure ] ;
                                                                            text =
                                                                                ''
                                                                                    INDEX="$1"
                                                                                    DEPTH="$2"
                                                                                    PID="$3"
                                                                                    mkdir --parents "${ resources-directory }/originator-pids/$INDEX"
                                                                                    touch "${ resources-directory }/originator-pids/$INDEX/$PID"
                                                                                    chmod 0400 "${ resources-directory }/originator-pids/$INDEX/$PID"
                                                                                    if [[ "$DEPTH" -gt 0 ]]
                                                                                    then
                                                                                        NEXT_DEPTH=$(( DEPTH - 1 ))
                                                                                        NEXT_PID="$( ps -o ppid= -p "$PID" | tr -d '[:space:]' )" || failure 0c0e976e
                                                                                        "$0" "$INDEX" "$NEXT_DEPTH" "$NEXT_PID"
                                                                                    fi
                                                                                '' ;
                                                                        }
                                                                )
                                                                (
                                                                    writeShellApplication
                                                                        {
                                                                            name = "publish" ;
                                                                            runtimeInputs = [ coreutils jq redis failure ] ;
                                                                            text =
                                                                                ''
                                                                                    STATUS="$1"
                                                                                    # shellcheck disable=SC2089,SC2016
                                                                                    DESCRIPTION='${ builtins.toJSON ( description secondary ) }'
                                                                                    JSON="$( cat | jq --compact-output --argjson DESCRIPTION "$DESCRIPTION" '. + { "description" : $DESCRIPTION }' )" || failure 64cec474
                                                                                    redis-cli PUBLISH "${channel}" "$JSON" > /dev/null || true
                                                                                    if ! "$STATUS"
                                                                                    then
                                                                                        INDEX="$2"
                                                                                        mkdir --parents "${ resources-directory }/quarantine/$INDEX/init"
                                                                                    fi
                                                                                '' ;
                                                                        }
                                                                )
                                                                failure
                                                                sequential
                                                                trace
                                                            ] ;
                                                        text =
                                                            let
                                                                double-quote = "''" ;
                                                                in
                                                                    ''
                                                                        trace 071b1520
                                                                        export SETUP="$0"
                                                                        export APPLICATIONS='${ builtins.toJSON applications }'
                                                                        export SCRIPTS='${ builtins.toJSON scripts }'
                                                                        if [[ -t 0 ]]
                                                                        then
                                                                            HAS_STANDARD_INPUT=false
                                                                            STANDARD_INPUT=
                                                                            ULTIMATE_PID="$( ps -o ppid= -p "$PPID" | tr -d '[:space:]' )" || failure 2bd52e9b
                                                                        else
                                                                            STANDARD_INPUT_FILE="$( mktemp )" || failure 92bc2ab1
                                                                            export STANDARD_INPUT_FILE
                                                                            HAS_STANDARD_INPUT=true
                                                                            cat <&0 > "$STANDARD_INPUT_FILE"
                                                                            STANDARD_INPUT="$( cat "$STANDARD_INPUT_FILE" )" || failure 101ddecf
                                                                            PENULTIMATE_PID="$( ps -o ppid= -p "$PPID" | tr -d '[:space:]' )" || failure d79214f2
                                                                            ULTIMATE_PID="$( ps -o ppid= -p "$PENULTIMATE_PID" | tr -d '[:space:]' )" || failure e1556ee8
                                                                        fi
                                                                        mkdir --parents ${ resources-directory }
                                                                        ARGUMENTS=( "$@" )
                                                                        ARGUMENTS_JSON="$( printf '%s\n' "${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] }" | jq -R . | jq -s . )"
                                                                        TRANSIENT=${ transient_ }
                                                                        HASH="$( echo "${ pre-hash secondary } ${ builtins.concatStringsSep "" [ "$TRANSIENT" "$" "{" "ARGUMENTS[*]" "}" ] } $STANDARD_INPUT $HAS_STANDARD_INPUT" "$APPLICATIONS" "$SCRIPTS" | sha512sum | cut --characters 1-128 )" || failure 2ea66adc
                                                                        export HASH
                                                                        mkdir --parents "${ resources-directory }/locks"
                                                                        export HAS_STANDARD_INPUT
                                                                        export HASH
                                                                        export STANDARD_INPUT
                                                                        TARGETS_EXPECTED='${ builtins.builtins.toJSON ( builtins.sort builtins.lessThan targets ) }'
                                                                        export TRANSIENT
                                                                        exec 210> "${ resources-directory }/locks/$HASH"
                                                                        flock -s 210
                                                                        trace df5e008d
                                                                        if [[ -L "${ resources-directory }/canonical/$HASH" ]]
                                                                        then
                                                                            trace 23b1c136
                                                                            MOUNT="$( readlink "${ resources-directory }/canonical/$HASH" )" || failure 52f2f8a5
                                                                            export MOUNT
                                                                            INDEX="$( basename "$MOUNT" )" || failure 50a633f1
                                                                            export INDEX
                                                                            originator-pid "$INDEX" ${ builtins.toString depth } "$ULTIMATE_PID"
                                                                            mkdir --parents ${ resources-directory }/marks
                                                                            touch "${ resources-directory }/marks/$INDEX"
                                                                            export PROVENANCE=cached
                                                                            mkdir --parents "${ root-directory }/$INDEX"
                                                                            mkdir --parents "${ resources-directory }/locks/$INDEX"
                                                                            trace d47f18d7
                                                                            # shellcheck disable=SC2016
                                                                            jq \
                                                                                --null-input \
                                                                                --argjson APPLICATIONS "$APPLICATIONS" \
                                                                                --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                                --arg HASH "$HASH" \
                                                                                --arg INDEX "$INDEX" \
                                                                                --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                --arg PROVENANCE "$PROVENANCE" \
                                                                                --argjson SCRIPTS "$SCRIPTS" \
                                                                                --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                                --argjson TARGETS "$TARGETS_EXPECTED" \
                                                                                --arg TRANSIENT "$TRANSIENT" \
                                                                                '{
                                                                                    "applications" : $APPLICATIONS ,
                                                                                    "arguments" : $ARGUMENTS ,
                                                                                    "hash" : $HASH ,
                                                                                    "index" : $INDEX ,
                                                                                    "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                    "provenance" : $PROVENANCE ,
                                                                                    "scripts" : $SCRIPTS ,
                                                                                    "standard-input" : $STANDARD_INPUT ,
                                                                                    "targets" : $TARGETS ,
                                                                                    "transient" : $TRANSIENT ,
                                                                                    "type" : "stale"
                                                                                }' | publish true
                                                                            trace 21a5334c
                                                                            echo -n "$MOUNT"
                                                                        else
                                                                            trace 33b73c4b
                                                                            INDEX="$( sequential )" || failure 65a31c86
                                                                            export INDEX
                                                                            trace e65a9aa4
                                                                            originator-pid "$INDEX" ${ builtins.toString depth } "$ULTIMATE_PID"
                                                                            trace f384f75c
                                                                            export PROVENANCE=new
                                                                            mkdir --parents "${ root-directory }/$INDEX"
                                                                            mkdir --parents "${ resources-directory }/locks/$INDEX"
                                                                            trace ac3d1856
                                                                            exec 211> "${ resources-directory }/locks/$INDEX/setup.lock"
                                                                            flock -s 211
                                                                            trace ae28d443
                                                                            mkdir --parents "${ resources-directory }/applications/$INDEX"
                                                                            mkdir --parents ${ resources-directory }/marks
                                                                            touch "${ resources-directory }/marks/$INDEX"
                                                                            MOUNT="${ resources-directory }/mounts/$INDEX"
                                                                            mkdir --parents "$MOUNT"
                                                                            export MOUNT
                                                                            mkdir --parents "${ resources-directory }/log/$INDEX"
                                                                            export STANDARD_ERROR_FILE="${ resources-directory }/log/$INDEX/init.standard-error.log"
                                                                            export STANDARD_OUTPUT_FILE="${ resources-directory }/log/$INDEX/init.standard-output.log"
                                                                            cd /
                                                                            trace 55abc5e4
                                                                            if [[ "$HAS_STANDARD_INPUT" == "true" ]]
                                                                            then
                                                                                # shellcheck disable=SC2068
                                                                                if ${ applications.init.application }/bin/init ${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] } < "$STANDARD_INPUT_FILE" > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                                then
                                                                                    STATUS="$?"
                                                                                else
                                                                                    STATUS="$?"
                                                                                fi
                                                                            else
                                                                                # shellcheck disable=SC2068
                                                                                if ${ applications.init.application }/bin/init ${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] } > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                                then
                                                                                    STATUS="$?"
                                                                                    trace e31074e4
                                                                                else
                                                                                    STATUS="$?"
                                                                                fi
                                                                            fi
                                                                            chmod 0400 "$STANDARD_ERROR_FILE" "$STANDARD_OUTPUT_FILE"
                                                                            # shellcheck disable=SC2016
                                                                            export STATUS
                                                                            trace f3ac5700
                                                                            TARGETS_OBSERVED="$( find "${ resources-directory }/mounts/$INDEX" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort | jq --compact-output --raw-input --slurp 'split("\n")[:-1]' )" || failure f9da34c2
                                                                            trace f82d9be9 "STATUS=$STATUS" "STANDARD_ERROR_FILE=$STANDARD_ERROR_FILE" "TARGETS_EXPECTED=$TARGETS_EXPECTED" "TARGETS_OBSERVED=$TARGETS_OBSERVED"
                                                                            if [[ -s "$STANDARD_ERROR_FILE" ]]
                                                                            then
                                                                                trace 19eeee7c
                                                                            else
                                                                                trace 177a75cb
                                                                                # shellcheck disable=SC2002
                                                                                cat "$STANDARD_OUTPUT_FILE" | trace
                                                                                trace 461a79d5
                                                                                # shellcheck disable=SC2002
                                                                                cat "$STANDARD_ERROR_FILE" | trace
                                                                                trace d91cd8d6
                                                                            fi
                                                                            # shellcheck disable=SC2129
                                                                            trace de9d4d9d
                                                                            if [[ "$STATUS" == 0 ]] && [[ ! -s "$STANDARD_ERROR_FILE" ]] && [[ "$TARGETS_EXPECTED" == "$TARGETS_OBSERVED" ]]
                                                                            then
                                                                                trace 5525b585
                                                                                # shellcheck disable=SC2016
                                                                                jq \
                                                                                    --null-input \
                                                                                    --argjson APPLICATIONS "$APPLICATIONS" \
                                                                                    --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                                    --arg HASH "$HASH" \
                                                                                    --arg INDEX "$INDEX" \
                                                                                    --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                    --arg PROVENANCE "$PROVENANCE" \
                                                                                    --arg TRANSIENT "$TRANSIENT" \
                                                                                    --argjson SCRIPTS "$SCRIPTS" \
                                                                                    --arg STANDARD_ERROR_FILE "$STANDARD_ERROR_FILE" \
                                                                                    --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                                    --arg STANDARD_OUTPUT_FILE "$STANDARD_OUTPUT_FILE" \
                                                                                    --arg STATUS "$STATUS" \
                                                                                    --argjson TARGETS "$TARGETS_EXPECTED" \
                                                                                    --arg TRANSIENT "$TRANSIENT" \
                                                                                    '{
                                                                                        "applications" : $APPLICATIONS ,
                                                                                        "arguments" : $ARGUMENTS ,
                                                                                        "hash" : $HASH ,
                                                                                        "index" : $INDEX ,
                                                                                        "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                        "provenance" : $PROVENANCE ,
                                                                                        "scripts" : $SCRIPTS ,
                                                                                        "standard-error-file" : $STANDARD_ERROR_FILE ,
                                                                                        "standard-input" : $STANDARD_INPUT ,
                                                                                        "standard-output-file" : $STANDARD_OUTPUT_FILE ,
                                                                                        "status" : $STATUS ,
                                                                                        "targets" : $TARGETS ,
                                                                                        "transient" : $TRANSIENT ,
                                                                                        "type" : "valid-init"
                                                                                    }' | publish true
                                                                                trace 6bca1caa
                                                                                mkdir --parents ${ resources-directory }/canonical
                                                                                ln --symbolic "${ resources-directory }/mounts/$INDEX" "${ resources-directory }/canonical/$HASH"
                                                                                echo -n "$MOUNT"
                                                                            else
                                                                                trace 1642cad5
                                                                                # shellcheck disable=SC2016
                                                                                jq \
                                                                                    --null-input \
                                                                                    --argjson APPLICATIONS "$APPLICATIONS" \
                                                                                    --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                                    --arg HASH "$HASH" \
                                                                                    --arg INDEX "$INDEX" \
                                                                                    --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                    --arg PROVENANCE "$PROVENANCE" \
                                                                                    --argjson SCRIPTS "$SCRIPTS" \
                                                                                    --arg STANDARD_ERROR_FILE "$STANDARD_ERROR_FILE" \
                                                                                    --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                                    --arg STANDARD_OUTPUT_FILE "$STANDARD_OUTPUT_FILE" \
                                                                                    --arg STATUS "$STATUS" \
                                                                                    --argjson TARGETS_EXPECTED "$TARGETS_EXPECTED" \
                                                                                    --argjson TARGETS_OBSERVED "$TARGETS_OBSERVED" \
                                                                                    --arg TRANSIENT "$TRANSIENT" \
                                                                                    '{
                                                                                        "applications" : $APPLICATIONS ,
                                                                                        "arguments" : $ARGUMENTS ,
                                                                                        "hash" : $HASH ,
                                                                                        "index" : $INDEX ,
                                                                                        "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                        "provenance" : $PROVENANCE ,
                                                                                        "scripts" : $SCRIPTS ,
                                                                                        "standard-error-file" : $STANDARD_ERROR_FILE ,
                                                                                        "standard-input" : $STANDARD_INPUT ,
                                                                                        "standard-output-file" : $STANDARD_OUTPUT_FILE ,
                                                                                        "status" : $STATUS ,
                                                                                        "targets" :
                                                                                            {
                                                                                                "expected" : $TARGETS_EXPECTED ,
                                                                                                "observed" : $TARGETS_OBSERVED
                                                                                            } ,
                                                                                        "transient" : $TRANSIENT ,
                                                                                        "type" : "invalid-init"
                                                                                    }' | publish false "$INDEX"
                                                                                failure 4f93f2ef "HASH=$HASH" "INDEX=$INDEX"
                                                                            fi
                                                                        fi
                                                                    '' ;
                                                        } ;
                                                    sequential =
                                                        writeShellApplication
                                                            {
                                                                name = "sequential" ;
                                                                runtimeInputs = [ coreutils failure flock ] ;
                                                                text =
                                                                    ''
                                                                        mkdir --parents ${ resources-directory }/sequential
                                                                        exec 220> ${ resources-directory }/sequential/sequential.lock
                                                                        flock -x 220
                                                                        if [[ -s ${ resources-directory }/sequential/sequential.counter ]]
                                                                        then
                                                                            CURRENT="$( cat ${ resources-directory }/sequential/sequential.counter )" || failure d3cb7aeb
                                                                        else
                                                                            CURRENT=${ sequential-start }
                                                                        fi
                                                                        NEXT=$(( ( CURRENT + 1 ) % 10000000000000000 ))
                                                                        echo "$NEXT" > ${ resources-directory }/sequential/sequential.counter
                                                                        printf "%016d\n" "$CURRENT"
                                                                    '' ;
                                                            } ;
                                                        trace =
                                                            writeShellApplication
                                                                {
                                                                    name = "trace" ;
                                                                    runtimeInputs =
                                                                        [
                                                                            coreutils
                                                                            (
                                                                                buildFHSUserEnv
                                                                                    {
                                                                                        extraBwrapArgs =
                                                                                            [
                                                                                                "--bind ${ resources-directory }/locks /locks"
                                                                                                "--bind ${ resources-directory }/log /log"
                                                                                            ] ;
                                                                                        name = "trace" ;
                                                                                        runScript = ''trace "$@"'' ;
                                                                                        targetPkgs =
                                                                                            pkgs :
                                                                                                [
                                                                                                    (
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "trace" ;
                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.flock ] ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        exec 203> /locks/trace.lock
                                                                                                                        flock -x 203
                                                                                                                        echo "$@" >> /log/trace.log
                                                                                                                    '' ;
                                                                                                            }
                                                                                                    )
                                                                                                ] ;
                                                                                    }
                                                                            )
                                                                        ] ;
                                                                    text =
                                                                        ''
                                                                            mkdir --parents ${ resources-directory }/locks
                                                                            mkdir --parents ${ resources-directory }/log
                                                                            if [[ -t 0 ]]
                                                                            then
                                                                                nohup trace "$@" > /dev/null 2>&1 &
                                                                            else
                                                                                STANDARD_INPUT="$( cat )" || failure 23371
                                                                                nohup trace "$STANDARD_INPUT" > /dev/null 2>&1 &
                                                                            fi
                                                                        '' ;
                                                                } ;
                                                        transient_ =
                                                            visitor
                                                                {
                                                                    bool = path : value : if value then "$( sequential ) || failure 0da02db4" else "-1" ;
                                                                }
                                                                transient ;
                                            in
                                                { setup ? setup : setup , failure ? "${ failure_ }/bin/failure f50c916d" } : ''"$( ${ setup "${ setup_ }/bin/setup" } )" || ${ if builtins.typeOf failure == "string" then failure else if builtins.typeOf failure == "int" then "${ failure_ }/bin/failure ${ builtins.toString failure }" else builtins.throw "d9274609" }'' ;
                            failure_ = failure ;
                            pre-hash =
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
                                    builtins.hashString "sha512" ( builtins.toJSON ( description secondary ) ) ;
                            in
                                {
                                    check =
                                        {
                                            arguments ? [ ] ,
                                            depth ? 0 ,
                                            diffutils ,
                                            expected ? { } ,
                                            expected-resource ? "" ,
                                            expected-status ? 0 ,
                                            init ? null ,
                                            init-resolutions ? [ ] ,
                                            jd-diff-patch ,
                                            release ? null ,
                                            release-resolutions ? [ ] ,
                                            resources ? null ,
                                            resources-directory ? "/build/resources" ,
                                            resources-directory-fixture ? null ,
                                            seed ? null ,
                                            self ? null ,
                                            sequential-start ? 1021 ,
                                            standard-input ? null ,
                                            standard-error ? "" ,
                                            standard-output ? "" ,
                                            status ? 0 ,
                                            targets ,
                                            transient
                                        } :
                                            mkDerivation
                                                {
                                                    installPhase = ''execute-test "$out"'' ;
                                                    name = "check" ;
                                                    nativeBuildInputs =
                                                        [
                                                            (
                                                                writeShellApplication
                                                                    {
                                                                        name = "execute-test" ;
                                                                        runtimeInputs =
                                                                            [
                                                                                coreutils
                                                                                failure
                                                                                jd-diff-patch
                                                                                jq
                                                                                redis
                                                                                (
                                                                                    writeShellApplication
                                                                                        {
                                                                                            name = "fixture" ;
                                                                                            runtimeInputs = [ ] ;
                                                                                            text =
                                                                                                visitor
                                                                                                    {
                                                                                                        lambda = path : value : value resources-directory ;
                                                                                                        null = path : value : "" ;
                                                                                                    }
                                                                                                    resources-directory-fixture ;
                                                                                        }
                                                                                )
                                                                                (
                                                                                    writeShellApplication
                                                                                        {
                                                                                             name = "subscribe" ;
                                                                                             runtimeInputs = [ coreutils redis ] ;
                                                                                             text =
                                                                                                ''
                                                                                                    redis-cli --raw SUBSCRIBE "${ channel }" | {
                                                                                                        read -r _     # skip "subscribe"
                                                                                                        read -r _     # skip channel name
                                                                                                        read -r _     # skip
                                                                                                        read -r _     # skip
                                                                                                        read -r _
                                                                                                        read -r PAYLOAD
                                                                                                        echo "$PAYLOAD" > /build/payload
                                                                                                    }
                                                                                                '' ;
                                                                                        }
                                                                                )
                                                                            ] ;
                                                                        text =
                                                                            let
                                                                                resource =
                                                                                    visitor
                                                                                        {
                                                                                            null = path : value : implementation { depth = depth ; init = init ; init-resolutions = init-resolutions ; release = release ; release-resolutions = release-resolutions ; seed = seed ; targets = targets ; transient = transient ; } { setup = setup : "${ setup } ${ builtins.concatStringsSep " " arguments } 2> /build/standard-error" ; failure = 13024 ; } ;
                                                                                            string = path : value : implementation { depth = depth ; init = init ; init-resolutions = init-resolutions ; release = release ; release-resolutions = release-resolutions ; seed = seed ; targets = targets ; transient = transient ; } { setup = setup : "${ setup } ${ builtins.concatStringsSep " " arguments } < ${ builtins.toFile "standard-input" standard-input } 2> /build/standard-error" ; failure = 28617 ; } ;
                                                                                        }
                                                                                        standard-input ;
                                                                                in
                                                                                    ''
                                                                                        OUT="$1"
                                                                                        mkdir --parents "$OUT"
                                                                                        mkdir --parents /build/redis
                                                                                        redis-server --dir /build/redis --daemonize yes
                                                                                        while ! redis-cli ping
                                                                                        do
                                                                                            sleep 0
                                                                                        done
                                                                                        fixture
                                                                                        subscribe &
                                                                                        if OBSERVED_RESOURCE=${ resource }
                                                                                        then
                                                                                            OBSERVED_STATUS="$?"
                                                                                        else
                                                                                            OBSERVED_STATUS="$?"
                                                                                        fi
                                                                                        if [[ ${ builtins.toString expected-status } != "$OBSERVED_STATUS" ]]
                                                                                        then
                                                                                            if [[ -f ${ resources-directory }/log/trace.log ]]
                                                                                            then
                                                                                                cat ${ resources-directory }/log/trace.log
                                                                                            fi
                                                                                            failure 94defd57 "EXPECTED_STATUS=${ builtins.toString expected-status }" "OBSERVED_STATUS=$OBSERVED_STATUS"
                                                                                        fi
                                                                                        if [[ "${ expected-resource }" != "$OBSERVED_RESOURCE" ]]
                                                                                        then
                                                                                            failure f780406e "EXPECTED_RESOURCE=${ expected-resource }" "OBSERVED_RESOURCE=$OBSERVED_RESOURCE"
                                                                                        fi
                                                                                        if ! jd ${ expected } "/build/payload"
                                                                                        then
                                                                                            jq "." "/build/payload" > "$OUT/candidate.json"
                                                                                            failure 2bc4ce7b "CANDIDATE $OUT/candidate.json"
                                                                                        fi
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
