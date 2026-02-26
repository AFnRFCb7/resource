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
                                                {
                                                    init =
                                                        visitor
                                                            {
                                                                lambda =
                                                                    path : value :
                                                                        let
                                                                            user-environment =
                                                                                buildFHSUserEnv
                                                                                    {
                                                                                        extraBwrapArgs =
                                                                                            [
                                                                                                "--bind $MOUNT /mount"
                                                                                                "--tmpfs /scratch"
                                                                                            ] ;
                                                                                        name = "init" ;
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
                                                                                                                        v = value { failure = t.failure ; pkgs = t.pkgs ; resources = t.resources ; root = t.root ; seed = t.seed ; sequential = t.sequential ; wrap = t.wrap ; } ;
                                                                                                                        in ''${ v } "$@"'' ;
                                                                                                            }
                                                                                                    )
                                                                                                ] ;
                                                                                    } ;
                                                                            in "${ user-environment }/bin/init" ;
                                                            }
                                                            init ;
                                                    release =
                                                        visitor
                                                            {
                                                                lambda =
                                                                    path : value :
                                                                        let
                                                                            user-environment =
                                                                                buildFHSUserEnv
                                                                                    {
                                                                                        extraBwrapArgs =
                                                                                            [
                                                                                                "--bind $MOUNT /mount"
                                                                                                "--tmpfs /scratch"
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
                                                                                                                runtimeInputs = [ ] ;
                                                                                                                text =
                                                                                                                    let
                                                                                                                        t = tools pkgs ;
                                                                                                                        v = value { failure = t.failure ; pkgs = t.pkgs ; resources = t.resources ; seed = t.seed ; sequential = t.sequential ; } ;
                                                                                                                        in ''${ v } "$@"'' ;
                                                                                                            }
                                                                                                    )
                                                                                                ] ;
                                                                                    } ;
                                                                            in "${ user-environment }/bin/release" ;
                                                                null = path : value : "true" ;
                                                            }
                                                            release ;
                                                } ;
                                            scripts =
                                                {
                                                    init =
                                                        visitor
                                                            {
                                                                lambda =
                                                                    path : value :
                                                                        let
                                                                            user-environment =
                                                                                buildFHSUserEnv
                                                                                    {
                                                                                        name = "init" ;
                                                                                        runScript = "init" ;
                                                                                        targetPkgs =
                                                                                            pkgs :
                                                                                                [
                                                                                                    (
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "init" ;
                                                                                                                runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                                text =
                                                                                                                    let
                                                                                                                        t = tools pkgs ;
                                                                                                                        in "echo '${ value { failure = t.failure ; pkgs = t.pkgs ; resources = t.resources ; root = t.root ; seed = t.seed ; sequential = t.sequential ; wrap = t.wrap ; } }'" ;
                                                                                                            }
                                                                                                    )
                                                                                                ] ;
                                                                                    } ;
                                                                                in ''"$( ${ user-environment }/bin/init )" || failure 5f7d7000'' ;
                                                                null = path : value : null ;
                                                            }
                                                            init ;
                                                    release =
                                                        visitor
                                                            {
                                                                lambda =
                                                                    path : value :
                                                                        let
                                                                            user-environment =
                                                                                buildFHSUserEnv
                                                                                    {
                                                                                        name = "release" ;
                                                                                        runScript = "release" ;
                                                                                        targetPkgs =
                                                                                            pkgs :
                                                                                                [
                                                                                                    (
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "release" ;
                                                                                                                runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                                text =
                                                                                                                    let
                                                                                                                        t = tools pkgs ;
                                                                                                                        in "echo '${ value { failure = t.failure ; pkgs = t.pkgs ; resources = t.resources ; seed = t.seed ; sequential = t.sequential ; } }'" ;
                                                                                                            }
                                                                                                    )
                                                                                                ] ;
                                                                                    } ;
                                                                                in ''"$( ${ user-environment }/bin/release )" || failure 5f7d7000'' ;
                                                                null = path : value : null ;
                                                            }
                                                            release ;
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
                                                                                    export INDEX
                                                                                    export DEPTH
                                                                                    export PID
                                                                                    touch "${ resources-directory }/originator-pids/$INDEX/$PID"
                                                                                    if [[ "$PID" -lt 1 ]] || [[ "$PID" -eq 1 ]]
                                                                                    then
                                                                                        failure 9003521f "PID=$PID"
                                                                                    # elif [[ "$DEPTH" -gt 0 ]]
                                                                                    # then
                                                                                    #     NEXT_DEPTH=$(( DEPTH - 1 ))
                                                                                    #     NEXT_PID="$( ps -o ppid= -p "$PID" | tr -d '[:space:]' )" || failure 0c0e976e
                                                                                    #     "$0" "$INDEX" "$NEXT_DEPTH" "$NEXT_PID"
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
                                                                                    # shellcheck disable=SC2089,SC2016
                                                                                    DESCRIPTION='${ builtins.toJSON ( description secondary ) }'
                                                                                    JSON="$( cat | jq --compact-output --argjson DESCRIPTION "$DESCRIPTION" '. + { "description" : $DESCRIPTION }' )" || failure 64cec474
                                                                                    redis-cli PUBLISH "${channel}" "$JSON" > /dev/null || true
                                                                                '' ;
                                                                        }
                                                                )
                                                                sequential
                                                                failure
                                                            ] ;
                                                        text =
                                                            ''
                                                                export SETUP="$0"
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
                                                                INIT_SCRIPT=${ builtins.toString scripts.init }
                                                                RELEASE_SCRIPT=${ builtins.toString scripts.release }
                                                                HASH="$( echo "${ pre-hash secondary } ${ builtins.concatStringsSep "" [ "$TRANSIENT" "$" "{" "ARGUMENTS[*]" "}" ] } $STANDARD_INPUT $HAS_STANDARD_INPUT" "$INIT_SCRIPT" | sha512sum | cut --characters 1-128 )" || failure 2ea66adc
                                                                export HASH
                                                                mkdir --parents "${ resources-directory }/locks"
                                                                export HAS_STANDARD_INPUT
                                                                export HASH
                                                                export STANDARD_INPUT
                                                                export TRANSIENT
                                                                exec 210> "${ resources-directory }/locks/$HASH"
                                                                flock -s 210
                                                                if [[ -L "${ resources-directory }/canonical/$HASH" ]]
                                                                then
                                                                    MOUNT="$( readlink "${ resources-directory }/canonical/$HASH" )" || failure 52f2f8a5
                                                                    export MOUNT
                                                                    INDEX="$( basename "$MOUNT" )" || failure 50a633f1
                                                                    export INDEX
                                                                    originator-pid "$INDEX" ${ builtins.toString depth } "$ULTIMATE_PID"
                                                                    mkdir --parents ${ resources-directory }/marks
                                                                    touch "${ resources-directory }/marks/$INDEX"
                                                                    export PROVENANCE=cached
                                                                    mkdir --parents "${ root-directory }/$INDEX"
                                                                    TARGETS="$( find "${ resources-directory }/mounts/$INDEX" -mindepth 1 -maxdepth 1 -exec basename {} \; | jq -R . | jq -s . )" || failure 91fa3b37
                                                                    mkdir --parents "${ resources-directory }/locks/$INDEX"
                                                                    # shellcheck disable=SC2016
                                                                    jq \
                                                                        --null-input \
                                                                        --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                        --arg HASH "$HASH" \
                                                                        --arg INDEX "$INDEX" \
                                                                        --arg INIT_SCRIPT "$INIT_SCRIPT" \
                                                                        --arg RELEASE_SCRIPT "$RELEASE_SCRIPT" \
                                                                        --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                        --arg PROVENANCE "$PROVENANCE" \
                                                                        --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                        --argjson TARGETS "$TARGETS" \
                                                                        --arg TRANSIENT "$TRANSIENT" \
                                                                        '{
                                                                            "arguments" : $ARGUMENTS ,
                                                                            "hash" : $HASH ,
                                                                            "index" : $INDEX ,
                                                                            "init-script" : $INIT_SCRIPT ,
                                                                            "release-script" : $RELEASE_SCRIPT ,
                                                                            "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                            "provenance" : $PROVENANCE ,
                                                                            "standard-input" : $STANDARD_INPUT ,
                                                                            "targets" : $TARGETS ,
                                                                            "transient" : $TRANSIENT ,
                                                                            "type" : "stale"
                                                                        }' | publish
                                                                    echo -n "$MOUNT"
                                                                else
                                                                    INDEX="$( sequential )" || failure 65a31c86
                                                                    export INDEX
                                                                    originator-pid "$INDEX" ${ builtins.toString depth } "$ULTIMATE_PID"
                                                                    export PROVENANCE=new
                                                                    mkdir --parents "${ resources-directory }/locks/$INDEX"
                                                                    exec 211> "${ resources-directory }/locks/$INDEX/setup.lock"
                                                                    flock -s 211
                                                                    mkdir --parents "${ resources-directory }/applications/$INDEX"
                                                                    ln --symbolic ${ applications.init } "${ resources-directory }/applications/$INDEX/init"
                                                                    ln --symbolic ${ applications.release } "${ resources-directory }/applications/$INDEX/release"
                                                                    mkdir --parents ${ resources-directory }/marks
                                                                    touch "${ resources-directory }/marks/$INDEX"
                                                                    MOUNT="${ resources-directory }/mounts/$INDEX"
                                                                    mkdir --parents "$MOUNT"
                                                                    export MOUNT
                                                                    STANDARD_ERROR_FILE="$( mktemp )" || failure 56a44e28
                                                                    export STANDARD_ERROR_FILE
                                                                    STANDARD_OUTPUT_FILE="$( mktemp )" || failure a330cb07
                                                                    export STANDARD_OUTPUT_FILE
                                                                    cd /
                                                                    if [[ "$HAS_STANDARD_INPUT" == "true" ]]
                                                                    then
                                                                        echo 7e1212fd 7555816d  >> /tmp/DEBUG
                                                                        # shellcheck disable=SC2068
                                                                        if ${ applications.init } ${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] } < "$STANDARD_INPUT_FILE" > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                        then
                                                                            STATUS="$?"
                                                                            echo 7e1212fd aa03ede2 >> /tmp/DEBUG
                                                                        else
                                                                            STATUS="$?"
                                                                            echo 7e1212fd ffa8718d >> /tmp/DEBUG
                                                                        fi
                                                                        echo 7e1212fd 082b7b62 >> /tmp/DEBUG
                                                                    else
                                                                        # shellcheck disable=SC2068
                                                                        if ${ applications.init } ${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] } > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                        then
                                                                            STATUS="$?"
                                                                        else
                                                                            STATUS="$?"
                                                                        fi
                                                                    fi
                                                                    # shellcheck disable=SC2016
                                                                    export STATUS
                                                                    TARGET_HASH_EXPECTED=${ builtins.hashString "sha512" ( builtins.concatStringsSep "" ( builtins.sort builtins.lessThan targets ) ) }
                                                                    TARGET_HASH_OBSERVED="$( find "$MOUNT" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort | tr --delete "\n" | sha512sum | cut --characters 1-128 )" || failure f6bff0bc
                                                                    STANDARD_ERROR="$( cat "$STANDARD_ERROR_FILE" )" || failure 395f8da8
                                                                    export STANDARD_ERROR
                                                                    STANDARD_OUTPUT="$( cat "$STANDARD_OUTPUT_FILE" )" || failure 9ee187fa
                                                                    export STANDARD_OUTPUT
                                                                    TARGETS="$( find "${ resources-directory }/mounts/$INDEX" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort | jq -R . | jq -s . )" || failure 9e22b9a8
                                                                    if [[ "$STATUS" == 0 ]] && [[ ! -s "$STANDARD_ERROR_FILE" ]] && [[ "$TARGET_HASH_EXPECTED" == "$TARGET_HASH_OBSERVED" ]]
                                                                    then
                                                                        # shellcheck disable=SC2016
                                                                        jq \
                                                                            --null-input \
                                                                            --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                            --arg HASH "$HASH" \
                                                                            --arg INDEX "$INDEX" \
                                                                            --arg INIT_SCRIPT "$INIT_SCRIPT" \
                                                                            --arg RELEASE_SCRIPT "$RELEASE_SCRIPT" \
                                                                            --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                            --arg PROVENANCE "$PROVENANCE" \
                                                                            --arg TRANSIENT "$TRANSIENT" \
                                                                            --arg STANDARD_ERROR "$STANDARD_ERROR" \
                                                                            --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                            --arg STANDARD_OUTPUT "$STANDARD_OUTPUT" \
                                                                            --arg STATUS "$STATUS" \
                                                                            --argjson TARGETS "$TARGETS" \
                                                                            --arg TRANSIENT "$TRANSIENT" \
                                                                            '{
                                                                                "arguments" : $ARGUMENTS ,
                                                                                "hash" : $HASH ,
                                                                                "index" : $INDEX ,
                                                                                "init-script" : $INIT_SCRIPT ,
                                                                                "release-script" : $RELEASE_SCRIPT ,
                                                                                "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                "provenance" : $PROVENANCE ,
                                                                                "standard-error" : $STANDARD_ERROR ,
                                                                                "standard-input" : $STANDARD_INPUT ,
                                                                                "standard-output" : $STANDARD_OUTPUT ,
                                                                                "status" : $STATUS ,
                                                                                "targets" : $TARGETS ,
                                                                                "transient" : $TRANSIENT ,
                                                                                "type" : "valid"
                                                                            }' | publish
                                                                        mkdir --parents ${ resources-directory }/canonical
                                                                        ln --symbolic "${ resources-directory }/mounts/$INDEX" "${ resources-directory }/canonical/$HASH"
                                                                        echo -n "$MOUNT"
                                                                    else
                                                                        # shellcheck disable=SC2016
                                                                        jq \
                                                                            --null-input \
                                                                            --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                            --arg HASH "$HASH" \
                                                                            --arg INDEX "$INDEX" \
                                                                            --arg INIT_SCRIPT "$INIT_SCRIPT" \
                                                                            --arg RELEASE_SCRIPT "$RELEASE_SCRIPT" \
                                                                            --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                            --arg PROVENANCE "$PROVENANCE" \
                                                                            --arg STANDARD_ERROR "$STANDARD_ERROR" \
                                                                            --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                            --arg STANDARD_OUTPUT "$STANDARD_OUTPUT" \
                                                                            --arg STATUS "$STATUS" \
                                                                            --argjson TARGETS "$TARGETS" \
                                                                            --arg TRANSIENT "$TRANSIENT" \
                                                                            '{
                                                                                "arguments" : $ARGUMENTS ,
                                                                                "hash" : $HASH ,
                                                                                "index" : $INDEX ,
                                                                                "init-script" : $INIT_SCRIPT ,
                                                                                "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                "provenance" : $PROVENANCE ,
                                                                                "standard-error" : $STANDARD_ERROR ,
                                                                                "standard-input" : $STANDARD_INPUT ,
                                                                                "standard-output" : $STANDARD_OUTPUT ,
                                                                                "status" : $STATUS ,
                                                                                "targets" : $TARGETS ,
                                                                                "transient" : $TRANSIENT ,
                                                                                "type" : "invalid-init"
                                                                            }' | publish
                                                                        failure a05ad0c3 "$STANDARD_ERROR" "$STATUS" "$ARGUMENTS_JSON" "$TARGETS"
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
                                            init-resolutions ? null ,
                                            jd-diff-patch ,
                                            release ? null ,
                                            release-resolutions ? null ,
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
                                                                                            failure 94defd57 "EXPECTED_STATUS=${ builtins.toString expected-status }" "OBSERVED_STATUS=$OBSERVED_STATUS"
                                                                                        fi
                                                                                        if [[ "${ expected-resource }" != "$OBSERVED_RESOURCE" ]]
                                                                                        then
                                                                                            failure f780406e "EXPECTED_RESOURCE=${ expected-resource }" "OBSERVED_RESOURCE=$OBSERVED_RESOURCE"
                                                                                        fi
                                                                                        sleep 10s
                                                                                        cat /build/payload > "$OUT/payload.observed.json"
                                                                                        failure 9ef03235 "$OUT/payload.observed.json"
                                                                                        # if ! jd ${ expected } "$OUT/payload.observed.json"
                                                                                        # then
                                                                                        #     jq "." "$OUT/payload.observed.json" > "$OUT/candidate.json"
                                                                                        #     failure 2bc4ce7b "EXPECTED=$OUT/candidate.json"
                                                                                        # fi
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
