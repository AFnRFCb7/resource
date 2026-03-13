# 1ff73b56
{
	inputs = { } ;
	outputs =
		{ self } :
		    {
		        lib =
                    {
                        buildFHSUserEnv ,
                        gc-root-directory ,
                        invalid-init-channel ,
                        resources ,
                        resources-directory ,
                        root-directory ,
                        sequential-start ,
                        stale-init-channel ,
                        valid-init-channel ,
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
                                                            let
                                                                application =
                                                                    writeShellApplication
                                                                        {
                                                                            name = name ;
                                                                            runtimeInputs =
                                                                                [
                                                                                    coreutils
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
                                                                in "${ application }/bin/${ name }" ;
                                                    sets =
                                                        {
                                                            create =
                                                                {
                                                                    extraBwrapArgs = [ ''--bind ${ resources-directory }/log /log'' ] ;
                                                                    post = "" ;
                                                                    pre =
                                                                        ''
                                                                            mkdir --parents "${ resources-directory }/log
                                                                        '' ;
                                                                    targetPkgs = pkgs : [ environments.failure environments.sequential environments.init environments.sequential pkgs.coreutils ] ;
                                                                    text =
                                                                        ''
                                                                            INDEX="$( sequential )" || failure 5607
                                                                            ARGUMENTS=( "$@" )
                                                                            ARGUMENTS_JSON="$( printf '%s\n' "${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] }" | jq -R . | jq -s . )" || failure 14587
                                                                            STANDARD_ERROR_SEQUENCE="$( sequential )" || failure 7574
                                                                            STANDARD_ERROR_FILE="/log/$STANDARD_ERROR_SEQUENCE.txt"
                                                                            STANDARD_OUTPUT_SEQUENCE="$( sequential )" || failure 7574
                                                                            STANDARD_OUTPUT_FILE="/log/$STANDARD_ERROR_SEQUENCE.txt"
                                                                            if "$HAS_STANDARD_INPUT"
                                                                            then
                                                                                if init "@" > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                                then
                                                                                    STATUS="$?"
                                                                                else
                                                                                    STATUS="$?"
                                                                                fi
                                                                            else
                                                                                if init "$@" > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                                then
                                                                                    STATUS="$?"
                                                                                else
                                                                                    STATUS="$?"
                                                                                fi
                                                                            fi
                                                                            chmod 0400 "$STANDARD_OUTPUT_FILE" "$STANDARD_ERROR_FILE"
                                                                            JSON_SEQUENCE="$( sequential )" || failure 32761
                                                                            JSON_FILE="/log/$JSON_SEQUENCE"
                                                                            jq \
                                                                                --null-input \
                                                                                --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                                --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                --arg HASH "$HASH" \
                                                                                --arg STANDARD_ERROR_FILE "$STANDARD_ERROR_FILE" \
                                                                                --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                                --arg STANDARD_OUTPUT_FILE "$STANDARD_OUTPUT_FILE" \
                                                                                '{
                                                                                    "arguments" : $ARGUMENTS ,
                                                                                    "has-standard-input" : $HAS_STANDARD_INPUT" ,
                                                                                    "hash" : $HASH ,
                                                                                    "standard-error-file" : $STANDARD_ERROR_FILE ,
                                                                                    "standard-input" : $STANDARD_INPUT ,
                                                                                    "standard-output-file" : $STANDARD_OUTPUT_FILE
                                                                                }' > "$JSON_FILE"
                                                                            if [[ "$STATUS" == 0 ]] && [[ ! -s "$STANDARD_ERROR_FILE" ]] && [[ "$TARGETS_EXPECTED" == "$TARGETS_OBSERVED" ]]
                                                                            then
                                                                                redis-cli PUBLISH ${ valid-init-channel } "$JSON_FILE" > /dev/null 2>&1 || true
                                                                                echo "${ resources-directory }/mounts/$HASH"
                                                                            else
                                                                                redis-cli PUBLISH ${ invalid-init-channel } "$JSON_FILE" > /dev/null 2>&1 || true
                                                                                echo "${ resources-directory }/mounts/$HASH"
                                                                                failure 21103
                                                                            fi
                                                                        '' ;
                                                                } ;
                                                            failure =
                                                                {
                                                                    extraBwrapArgs = [ ] ;
                                                                    post =
                                                                        ''
                                                                        '' ;
                                                                    pre =
                                                                        ''
                                                                        '' ;
                                                                    targetPkgs = pkgs : [ pkgs.coreutils pkgs.yq-go ] ;
                                                                    text =
                                                                        ''
                                                                            ARGUMENTS="$( printf '%s\n' "$@" | yq eval --raw-input . | yq eval --slurp . )" || exit 68
                                                                            if [[ -t 0 ]]
                                                                            then
                                                                                yq \
                                                                                    eval \
                                                                                    --null-input \
                                                                                    --prettyPrint \
                                                                                    --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                    '{ arguments : $ARGUMENTS }'
                                                                            else
                                                                                STANDARD_INPUT="$( cat )" || failure 65
                                                                                yq \
                                                                                    eval \
                                                                                    --null-input \
                                                                                    --prettyPrint \
                                                                                    --argjson arguments ARGUMENTS "$ARGUMENTS" \
                                                                                    '{ arguments: $arguments , standard-input : $STANDARD_INPUT }'
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
                                                            scripts =
                                                                {
                                                                    gc-root = null ;
                                                                    lock = false ;
                                                                    log = false ;
                                                                    mounts = null ;
                                                                    mount = null ;
                                                                    sequential = null ;
                                                                    targetPkgs = pkgs : [ pkgs.which ] ;
                                                                    text =
                                                                        visitor
                                                                            {
                                                                                lambda =
                                                                                    path : value :
                                                                                        let
                                                                                            arguments =
                                                                                                if builtins.length path == "2" && builtins.elemAt path 0 == "init" && builtins.elemAt path 1 == "task" then
                                                                                                    {
                                                                                                        failure = environments.failure ;
                                                                                                        pkgs = pkgs ;
                                                                                                        resources = resources ;
                                                                                                        root = environments.root ;
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
                                                                                list = path : list : builtins.concatLists list ;
                                                                                null = path : value : [ ] ;
                                                                                set = path : set : builtins.concatLists ( builtins.attrValues ( set ) ) ;
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
                                                                } ;
                                                            sequential =
                                                                {
                                                                    gc-root = null ;
                                                                    lock = true ;
                                                                    log = null ;
                                                                    mount = null ;
                                                                    sequential = true ;
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
                                                                    gc-root = null ;
                                                                    lock = true ;
                                                                    log = true ;
                                                                    mount = null ;
                                                                    sequential = null ;
                                                                    targetPkgs = pkgs : [ pkgs.coreutils pkgs.flock pkgs.yq-go environments.failure ] ;
                                                                    text =
                                                                        ''
                                                                            ARGUMENTS="$( printf '%s\n' "$@" | yq eval --raw-input . | yq eval --slurp . )" || failure 22397
                                                                            if [[ -t 0 ]]
                                                                            then
                                                                                yq \
                                                                                    eval \
                                                                                    --null-input \
                                                                                    --prettyPrint \
                                                                                    --argjson ARGUMENTS "$ARGUMENTS" \
                                                                                    '{ arguments : $ARGUMENTS }' \
                                                                                    >> /log/trace.log.yaml
                                                                            else
                                                                                STANDARD_INPUT="$( cat )" || failure 32061
                                                                                yq \
                                                                                    eval \
                                                                                    --null-input \
                                                                                    --prettyPrint \
                                                                                    --argjson arguments ARGUMENTS "$ARGUMENTS" \
                                                                                    '{ arguments: $arguments , standard-input : $STANDARD_INPUT }' \
                                                                                    > /log/trace.log.yaml
                                                                            fi
                                                                        '' ;
                                                                } ;
                                                            wrap =
                                                                {
                                                                    gc-root = null ;
                                                                    lock = null ;
                                                                    log = null ;
                                                                    mount = true ;
                                                                    sequential = null ;

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
                                                        runtimeInputs = [ environments.create environments.failure coreutils js procps redis-cli ] ;
                                                        text =
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
                                                                    cat <&0 > "$STANDARD_INPUT_FILE"
                                                                    STANDARD_INPUT="$( cat "$STANDARD_INPUT_FILE" )" || failure 12348
                                                                    PENULTIMATE_PID="$( ps -o ppid= -p "$PPID" | tr -d '[:space:]' )" || failure 27339
                                                                    ULTIMATE_PID="$( ps -o ppid= -p "$PENULTIMATE_PID" | tr -d '[:space:]' )" || failure 17331
                                                                fi
                                                                ARGUMENTS=( "$@" )
                                                                ARGUMENTS_JSON="$( printf '%s\n' "${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] }" | jq -R . | jq -s . )" || failure 14587
                                                                TRANSIENT=${ transient_ }
                                                                HASH="$( echo "${ pre-hash secondary } ${ builtins.concatStringsSep "" [ "$TRANSIENT" "$" "{" "ARGUMENTS[*]" "}" ] } $STANDARD_INPUT $HAS_STANDARD_INPUT" | sha512sum | cut --characters 1-128 )" || failure 21086
                                                                SCRIPTS='${ builtins.toJSON scripts }'
                                                                if [[ -L "${ resources-directory }/mounts/$HASH" ]]
                                                                then
                                                                    echo "${ resources-directory }/mounts/$HASH"
                                                                    JSON_SEQUENCE="$( sequential )" || failure 30634
                                                                    JSON_FILE="${ resources-directory }/log/$JSON_SEQUENCE"
                                                                    jq \
                                                                        --null-output \
                                                                        --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                        --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                        --arg HASH "$HASH" \
                                                                        --arg INDEX "INDEX" \
                                                                        --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                        --arg TRANSIENT "$TRANSIENT" \
                                                                        '{
                                                                            "arguments" : $ARGUMENTS ,
                                                                            "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                            "hash" : $HASH ,
                                                                            "index" : $INDEX ,
                                                                            "standard-input" : $STANDARD_INPUT ,
                                                                            "transient" : $TRANSIENT
                                                                        }' > "$JSON_FILE"
                                                                    redis-cli PUBLISH "${ stale-channel }" "$JSON_FILE"
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
                                                    failure ? 10996 ,
                                                    setup ? setup : "${ setup }"
                                                } :
                                                    ''"$( ${ setup "${ get-or-create }/bin/get-or-create" }" || ${ environments.failure ( builtins.toString failure ) }'' ;
                            in
                                {
                                    check =
                                        {
                                            buildFHSUserEnv ,
                                            expected-invalid-init ,
                                            expected-stale-init ,
                                            expected-status ,
                                            expected-valid-init ,
                                            fixture ,
                                            gc-root ,
                                            invalid-init-channel ,
                                            mkDerivation ,
                                            resources ,
                                            resources-directory ,
                                            root-directory ,
                                            sequential-start ,
                                            stale-init-channel ,
                                            valid-init-channel ,
                                            writeShellApplication
                                        } :
                                            mkDerivation
                                                {
                                                    install = ''check "$out"'' ;
                                                    name = "check" ;
                                                    nativeBuildInputs =
                                                        [
                                                            (
                                                                buildHFSUserEnv
                                                                    {
                                                                        name = "check" ;
                                                                        runScript = ''check "$@"'' ;
                                                                        targetPkgs =
                                                                            pkgs :
                                                                                [
                                                                                    (
                                                                                        pkgs.writeShellApplication
                                                                                            {
                                                                                                name = "check" ;
                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.redis ] ;
                                                                                                text =
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
                                                                                                        nohup subscribe "$OUT" stale-init-channel > /dev/null 2>&1 &
                                                                                                        nohup subscribe "$OUT" valid-init-channel > /dev/null 2>&1  &
                                                                                                        nohup subscribe "$OUT" invalid-init-channel > /dev/null 2>&1  &
                                                                                                        if OBSERVED_RESOURCE="$( resource )"
                                                                                                        then
                                                                                                            OBSERVED_STATUS="$?"
                                                                                                        else
                                                                                                            OBSERVED_STATUS="$?"
                                                                                                        fi
                                                                                                        if [[ -f ${ resources-directory }/log/trace.log ]]
                                                                                                        then
                                                                                                            cat ${ resources-directory }/log/trace.log
                                                                                                        fi
                                                                                                        if [[ ${ builtins.toString expected-status } != "$OBSERVED_STATUS" ]]
                                                                                                        then
                                                                                                            failure 94defd57 "EXPECTED_STATUS=${ builtins.toString expected-status }" "OBSERVED_STATUS=$OBSERVED_STATUS"
                                                                                                        fi
                                                                                                        if [[ "${ expected-resource }" != "$OBSERVED_RESOURCE" ]]
                                                                                                        then
                                                                                                            failure f780406e "EXPECTED_RESOURCE=${ expected-resource }" "OBSERVED_RESOURCE=$OBSERVED_RESOURCE"
                                                                                                        fi
                                                                                                        mkdir --parents "$OUT/expected"
                                                                                                        cat > "$OUT/expected/stale-init.json" <<EOF
                                                                                                        ${ builtins.toJSON expected-stale-init }
                                                                                                        EOF
                                                                                                        cat > "$OUT/expected/stale-init.json" <<EOF
                                                                                                        ${ builtins.toJSON expected-stale-init }
                                                                                                        EOF
                                                                                                        cat > "$OUT/expected/stale-init.json" <<EOF
                                                                                                        ${ builtins.toJSON expected-stale-init }
                                                                                                        EOF
                                                                                                        chmod 0400 "$OUT/expected/stale-init.json" "$OUT/expected/valid-init.json" "$OUT/expected/invalid-init.json"
                                                                                                        if ! jd "$OUT/expected/stale-init.json" "$OUT/observed/stale-init.json"
                                                                                                        then
                                                                                                            failure 979
                                                                                                        elif ! jd "$OUT/expected/valid-init.json" "$OUT/observed/valid-init.json"
                                                                                                        then
                                                                                                            failure 24531
                                                                                                        elif ! jd "$OUT/expected/invalid-init.json" "$OUT/observed/invalid-init.json"
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
                                                                                                            lambda = path : value : value resources-directory ;
                                                                                                            null = path : value : "" ;
                                                                                                        }
                                                                                                        fixture ;
                                                                                            }
                                                                                    )
                                                                                    (
                                                                                        pkgs.writeShellApplication
                                                                                            {
                                                                                                 name = "subscribe" ;
                                                                                                 runtimeInputs = [ coreutils redis ] ;
                                                                                                 text =
                                                                                                    ''
                                                                                                        OUT="$1"
                                                                                                        CHANNEL="$2"
                                                                                                        redis-cli --raw SUBSCRIBE "$CHANNEL" | {
                                                                                                            read -r _     # skip "subscribe"
                                                                                                            read -r _     # skip channel name
                                                                                                            read -r _     # skip
                                                                                                            read -r _     # skip
                                                                                                            read -r _
                                                                                                            read -r PAYLOAD
                                                                                                            mkdir --parents "$OUT/observed"
                                                                                                            echo "$PAYLOAD" > "$OUT/observed/$CHANNEL.json"
                                                                                                            chmod 0400 "$OUT/observed/$CHANNEL.json"
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
