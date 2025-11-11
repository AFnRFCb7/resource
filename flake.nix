{
	inputs = { } ;
	outputs =
		{ self } :
		    {
		        lib =
                    {
                        buildFHSUserEnv ,
                        channel ? "resource" ,
                        coreutils ,
                        failure ,
                        findutils ,
                        flock ,
                        jq ,
                        makeBinPath ,
                        makeWrapper ,
                        mkDerivation ,
                        nix ,
                        ps ,
                        redis ,
                        resources ? null ,
                        resources-directory ,
                        store-garbage-collection-root ,
                        string ,
                        visitor ,
                        writeShellApplication ,
                        yq-go
                    } @primary :
                        let
                            _string = string ;
                            description =
                                { init ? null , seed ? null , targets ? [ ] , transient ? false } @secondary :
                                    let
                                        seed = path : value : [ { path = path ; type = builtins.typeOf value ; value = if builtins.typeOf value == "lambda" then null else value ; } ] ;
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
                                        init ? null ,
                                        seed ? null ,
                                        targets ? [ ] ,
                                        transient ? false
                                    } @secondary :
                                        let
                                            init-application =
                                                if builtins.typeOf init == "null" then null
                                                else
                                                    buildFHSUserEnv
                                                        {
                                                            extraBwrapArgs =
                                                                [
                                                                    "--bind $MOUNT /mount"
                                                                    "--tmpfs /scratch"
                                                                ] ;
                                                            name = "init-application" ;
                                                            runScript =
                                                                ''
                                                                    bash -c '
                                                                        if [[ -t 0 ]]
                                                                        then
                                                                            echo c85257a8 "$0 $#" >> /tmp/DEBUG
                                                                            execute-init "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }"
                                                                        else
                                                                            cat | execute-init "${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }"
                                                                        fi
                                                                    ' "$0" "$@"
                                                                '' ;
                                                            targetPkgs =
                                                                pkgs :
                                                                    let
                                                                        root =
                                                                            pkgs.writeShellApplication
                                                                                {
                                                                                    name = "root" ;
                                                                                    runtimeInputs = [ pkgs.coreutils failure ] ;
                                                                                    text =
                                                                                        ''
                                                                                            ROOT_DIRECTORY="$1"
                                                                                            MAGIC="$2"
                                                                                            HASH="$( basename "$MAGIC" )" || failure 388f974f
                                                                                            mkdir --parents "$ROOT_DIRECTORY/$INDEX"
                                                                                            if [[ -L "$ROOT_DIRECTORY/$INDEX/$HASH" ]]
                                                                                            then
                                                                                                CHECK="$( readlink "$ROOT_DIRECTORY/$INDEX/$HASH" )" || failure acce2ddb
                                                                                                if [[ "$MAGIC" != "$CHECK" ]]
                                                                                                then
                                                                                                    failure 4745d66a
                                                                                                fi
                                                                                            elif [[ -e "$ROOT_DIRECTORY/$INDEX/$HASH" ]]
                                                                                            then
                                                                                                failure 6513a7a8
                                                                                            else
                                                                                                ln --symbolic "$MAGIC" "$ROOT_DIRECTORY/$INDEX"
                                                                                            fi
                                                                                        '' ;
                                                                                } ;
                                                                        in
                                                                    [
                                                                        pkgs.bash
                                                                        pkgs.coreutils
                                                                        (
                                                                            pkgs.writeShellApplication
                                                                                {
                                                                                    name = "execute-init" ;
                                                                                    runtimeInputs = [ ] ;
                                                                                    text =
                                                                                        if builtins.typeOf ( init { pkgs = pkgs ; resources = resources ; self = "${ resources-directory }/mounts/$INDEX" ; } ) == "string" then
                                                                                            ''
                                                                                                echo "7743675e $0 $#" >> /tmp/DEBUG
                                                                                                ${ init { pkgs = pkgs ; resources = resources ; self = "${ resources-directory }/mounts/$INDEX" ; } } "$@"
                                                                                            ''
                                                                                        else builtins.throw "WTF" ;
                                                                                }
                                                                        )
                                                                        (
                                                                            pkgs.writeShellApplication
                                                                                {
                                                                                    name = "root-resource" ;
                                                                                    runtimeInputs = [ root ] ;
                                                                                    text =
                                                                                        ''
                                                                                            MAGIC="$1"
                                                                                            root "${ resources-directory }/links" "$MAGIC"
                                                                                        '' ;
                                                                                }
                                                                        )
                                                                        (
                                                                            pkgs.writeShellApplication
                                                                                {
                                                                                    name = "root-store" ;
                                                                                    runtimeInputs = [ root ] ;
                                                                                    text =
                                                                                        ''
                                                                                            MAGIC="$1"
                                                                                            root "${ store-garbage-collection-root }" "$MAGIC"
                                                                                        '' ;
                                                                                }
                                                                        )
                                                                    ] ;
                                                        } ;
                                            publish =
                                                writeShellApplication
                                                    {
                                                        name = "publish" ;
                                                        runtimeInputs = [ coreutils failure jq redis ] ;
                                                        text =
                                                            ''
                                                                JSON="$( cat | jq --compact-output '. + { "description" : ${ builtins.toJSON ( description secondary ) } }' )" || failure d8cf8058 publish
                                                                redis-cli PUBLISH "${ channel }" "$JSON" > /dev/null 2>&1 || true
                                                            '' ;
                                                    } ;
                                            setup =
                                                if builtins.typeOf init == "null" then
                                                    writeShellApplication
                                                        {
                                                            name = "setup" ;
                                                            runtimeInputs = [ coreutils flock jq ps publish sequential yq-go failure ] ;
                                                            text =
                                                                ''
                                                                    if [[ -t 0 ]]
                                                                    then
                                                                        HAS_STANDARD_INPUT=false
                                                                        STANDARD_INPUT=
                                                                        STANDARD_INPUT_FILE="$( mktemp )" || failure eb7705c0
                                                                    else
                                                                        HAS_STANDARD_INPUT=true
                                                                        cat <&0 > "$STANDARD_INPUT_FILE"
                                                                        STANDARD_INPUT="$( cat "$STANDARD_INPUT_FILE" )" || failure 75bc6a1a
                                                                    fi
                                                                    TRANSIENT=${ transient_ }
                                                                    ORIGINATOR_PID="$( ps -o ppid= -p "$PPID" )" || failure f4a77245
                                                                    HASH="$( echo "${ pre-hash secondary } ${ builtins.concatStringsSep "" [ "$TRANSIENT" "$" "{" "ARGUMENTS[*]" "}" ] } $STANDARD_INPUT $HAS_STANDARD_INPUT" | sha512sum | cut --characters 1-128 )" || failure b589ecbe
                                                                    mkdir --parents "${ resources-directory }/locks"
                                                                    ARGUMENTS_YAML="$( printf '%s\n' "${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] }" | jq -R . | jq -s . | yq -P )" || failure fa33f5ec
                                                                    export ARGUMENTS_YAML
                                                                    export HAS_STANDARD_INPUT
                                                                    export HASH
                                                                    export STANDARD_INPUT
                                                                    export ORIGINATOR_PID
                                                                    export TRANSIENT
                                                                    exec 210> "${ resources-directory }/locks/$HASH"
                                                                    flock -s 210
                                                                    if [[ -L "${ resources-directory }/canonical/$HASH" ]]
                                                                    then
                                                                        MOUNT="$( readlink "${ resources-directory }/canonical/$HASH" )" || failure 2d2f0668
                                                                        export MOUNT
                                                                        INDEX="$( basename "$MOUNT" )" || failure b1a9811a
                                                                        export INDEX
                                                                        export PROVENENCE=cached
                                                                        mkdir --parents "${ resources-directory }/locks/$INDEX"
                                                                        exec 211> "${ resources-directory }/locks/$INDEX/setup.lock"
                                                                        flock -s 211
                                                                        jq \
                                                                            --null-input \
                                                                            --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                            '{
                                                                                "has-standard-input" : $HAS_STANDARD_INPUT
                                                                            }' | publish
                                                                        ln --symbolic "$MOUNT" "${ resources-directory }/canonical/$HASH"
                                                                        echo -n "$MOUNT"
                                                                    else
                                                                        INDEX="$( sequential )" || failure 8fb421c4
                                                                        export INDEX
                                                                        export PROVENANCE=new
                                                                        mkdir --parents "${ resources-directory }/locks/$INDEX"
                                                                        exec 211> "${ resources-directory }/locks/$INDEX/setup.lock"
                                                                        flock -s 211
                                                                        MOUNT="${ resources-directory }/mounts/$INDEX"
                                                                        mkdir --parents "$MOUNT"
                                                                        mkdir --parents ${ resources-directory }/canonical
                                                                        jq \
                                                                            --null-input \
                                                                            --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                            '{
                                                                                "has-standard-input" : $HAS_STANDARD_INPUT
                                                                            }' | publish
                                                                        mkdir --parents ${ resources-directory }/canonical
                                                                        ln --symbolic "$MOUNT" "${ resources-directory }/canonical/$HASH"
                                                                        echo -n "$MOUNT"
                                                                    fi
                                                                '' ;
                                                        }
                                                else
                                                    writeShellApplication
                                                        {
                                                            name = "setup" ;
                                                            runtimeInputs = [ coreutils flock jq ps publish redis sequential yq-go failure ] ;
                                                            text =
                                                                string
                                                                    {
                                                                        template =
                                                                            {
                                                                                arguments-nix ,
                                                                                hash ,
                                                                                init-application ,
                                                                                pre-hash ,
                                                                                resources-directory ,
                                                                                store-garbage-collection-root ,
                                                                                target-hash-expected ,
                                                                                transient
                                                                            } :
                                                                                ''
                                                                                    if [[ -t 0 ]]
                                                                                    then
                                                                                        HAS_STANDARD_INPUT=false
                                                                                        STANDARD_INPUT=
                                                                                    else
                                                                                        STANDARD_INPUT_FILE="$( mktemp )" || failure 92bc2ab1
                                                                                        export STANDARD_INPUT_FILE
                                                                                        HAS_STANDARD_INPUT=true
                                                                                        cat <&0 > "$STANDARD_INPUT_FILE"
                                                                                        STANDARD_INPUT="$( cat "$STANDARD_INPUT_FILE" )" || failure 101ddecf
                                                                                    fi
                                                                                    mkdir --parents ${ resources-directory }
                                                                                    ARGUMENTS=( "$@" )
                                                                                    ARGUMENTS_JSON="$( printf '%s\n' "${ arguments-nix }" | jq -R . | jq -s . )"
                                                                                    TRANSIENT=${ transient }
                                                                                    ORIGINATOR_PID="$( ps -o ppid= -p "$PPID" | tr -d '[:space:]')" || failure 9db056a1
                                                                                    export ORIGINATOR_PID
                                                                                    HASH="$( echo "${ pre-hash } ${ hash } $STANDARD_INPUT $HAS_STANDARD_INPUT" | sha512sum | cut --characters 1-128 )" || failure 2ea66adc
                                                                                    export HASH
                                                                                    mkdir --parents "${ resources-directory }/locks"
                                                                                    export HAS_STANDARD_INPUT
                                                                                    export HASH
                                                                                    export STANDARD_INPUT
                                                                                    export ORIGINATOR_PID
                                                                                    export TRANSIENT
                                                                                    exec 210> "${ resources-directory }/locks/$HASH"
                                                                                    flock -s 210
                                                                                    if [[ -L "${ resources-directory }/canonical/$HASH" ]]
                                                                                    then
                                                                                        MOUNT="$( readlink "${ resources-directory }/canonical/$HASH" )" || failure 52f2f8a5
                                                                                        export MOUNT
                                                                                        INDEX="$( basename "$MOUNT" )" || failure 50a633f1
                                                                                        export INDEX
                                                                                        export PROVENANCE=cached
                                                                                        RESOURCE_DEPENDENCIES="$( find "${ resources-directory }/links/$INDEX" -mindepth 1 -maxdepth 1 -exec basename {} \; | jq -R . | jq -s . )" || failure b39ed4ef
                                                                                        mkdir --parents "${ store-garbage-collection-root }/$INDEX"
                                                                                        STORE_DEPENDENCIES="$( find "${ store-garbage-collection-root }/$INDEX" -mindepth 1 -maxdepth 1 -exec basename {} \; | jq -R . | jq -s . )" || failure 8a54bbd4
                                                                                        TARGETS="$( find "${ resources-directory }/mounts/$INDEX" -mindepth 1 -maxdepth 1 -exec basename {} \; | jq -R . | jq -s . )" || failure 91fa3b37
                                                                                        mkdir --parents "${ resources-directory }/locks/$INDEX"
                                                                                        # shellcheck disable=SC2016
                                                                                        jq \
                                                                                            --null-input \
                                                                                            --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                                            --argjson RESOURCE_DEPENDENCIES "$RESOURCE_DEPENDENCIES" \
                                                                                            --argjson STORE_DEPENDENCIES "$STORE_DEPENDENCIES" \
                                                                                            --arg HASH "$HASH" \
                                                                                            --arg INDEX "$INDEX" \
                                                                                            --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                            --arg ORIGINATOR_PID "$ORIGINATOR_PID" \
                                                                                            --arg PROVENANCE "$PROVENANCE" \
                                                                                            --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                                            --argjson TARGETS "$TARGETS" \
                                                                                            --arg TRANSIENT "$TRANSIENT" \
                                                                                            '{
                                                                                                "arguments" : $ARGUMENTS ,
                                                                                                "dependencies" :
                                                                                                  {
                                                                                                    "resource" : $RESOURCE_DEPENDENCIES ,
                                                                                                    "store" : "$STORE_DEPENDENCIES"
                                                                                                  } ,
                                                                                                "hash" : $HASH ,
                                                                                                "index" : $INDEX ,
                                                                                                "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                                "originator-pid" : $ORIGINATOR_PID ,
                                                                                                "provenance" : $PROVENANCE ,
                                                                                                "standard-input" : $STANDARD_INPUT ,
                                                                                                "targets" : $TARGETS ,
                                                                                                "transient" : $TRANSIENT
                                                                                            }' | publish > /dev/null 2>&1
                                                                                        echo -n "$MOUNT"
                                                                                    else
                                                                                        INDEX="$( sequential )" || failure 65a31c86
                                                                                        export INDEX
                                                                                        export PROVENANCE=new
                                                                                        mkdir --parents "${ resources-directory }/locks/$INDEX"
                                                                                        exec 211> "${ resources-directory }/locks/$INDEX/setup.lock"
                                                                                        flock -s 211
                                                                                        MOUNT="${ resources-directory }/mounts/$INDEX"
                                                                                        mkdir --parents "$MOUNT"
                                                                                        export MOUNT
                                                                                        mkdir --parents "$MOUNT"
                                                                                        STANDARD_ERROR_FILE="$( mktemp )" || failure 56a44e28
                                                                                        export STANDARD_ERROR_FILE
                                                                                        STANDARD_OUTPUT_FILE="$( mktemp )" || failure a330cb07
                                                                                        export STANDARD_OUTPUT_FILE
                                                                                        if [[ "$HAS_STANDARD_INPUT" == "true" ]]
                                                                                        then
                                                                                            if ${ init-application }/bin/init-application "${ arguments-nix }" < "$STANDARD_INPUT_FILE" > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                                            then
                                                                                                STATUS="$?"
                                                                                            else
                                                                                                STATUS="$?"
                                                                                            fi
                                                                                        else
                                                                                            cat >> /tmp/DEBUG <<EOF
                                                                                            if ${ init-application }/bin/init-application "${ arguments-nix }" > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                                    EOF
                                                                                            if ${ init-application }/bin/init-application "${ arguments-nix }" > "$STANDARD_OUTPUT_FILE" 2> "$STANDARD_ERROR_FILE"
                                                                                            then
                                                                                                STATUS="$?"
                                                                                            else
                                                                                                STATUS="$?"
                                                                                            fi
                                                                                        fi
                                                                                        export STATUS
                                                                                        TARGET_HASH_EXPECTED=${ target-hash-expected }
                                                                                        TARGET_HASH_OBSERVED="$( find "$MOUNT" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort | tr --delete "\n" | sha512sum | cut --characters 1-128 )" || failure f6bff0bc
                                                                                        STANDARD_ERROR="$( cat "$STANDARD_ERROR_FILE" )" || failure
                                                                                        export STANDARD_ERROR
                                                                                        STANDARD_OUTPUT="$( cat "$STANDARD_OUTPUT_FILE" )" || failure
                                                                                        export STANDARD_OUTPUT
                                                                                        mkdir --parents "${ resources-directory }/links/$INDEX"
                                                                                        RESOURCE_DEPENDENCIES="$( find "${ resources-directory }/links/$INDEX" -mindepth 1 -maxdepth 1 -exec basename {} \; | jq -R . | jq -s . )" || failure 1e739712
                                                                                        mkdir --parents "${ store-garbage-collection-root }/$INDEX"
                                                                                        STORE_DEPENDENCIES="$( find "${ store-garbage-collection-root }/$INDEX" -mindepth 1 -maxdepth 1 -exec basename {} \; | jq -R . | jq -s . )" || failure c5553f2b
                                                                                        TARGETS="$( find "${ resources-directory }/mounts/$INDEX" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort | jq -R . | jq -s . )" || failure 9e22b9a8
                                                                                        if [[ "$STATUS" == 0 ]] && [[ ! -s "$STANDARD_ERROR_FILE" ]] && [[ "$TARGET_HASH_EXPECTED" == "$TARGET_HASH_OBSERVED" ]]
                                                                                        then
                                                                                            # shellcheck disable=SC2016
                                                                                            jq \
                                                                                                --null-input \
                                                                                                --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                                                --argjson RESOURCE_DEPENDENCIES "$RESOURCE_DEPENDENCIES" \
                                                                                                --argjson STORE_DEPENDENCIES "$STORE_DEPENDENCIES" \
                                                                                                --arg HASH "$HASH" \
                                                                                                --arg INDEX "$INDEX" \
                                                                                                --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                                --arg ORIGINATOR_PID "$ORIGINATOR_PID" \
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
                                                                                                    "dependencies" :
                                                                                                      {
                                                                                                        "resource" : $RESOURCE_DEPENDENCIES ,
                                                                                                        "store" : $STORE_DEPENDENCIES
                                                                                                      } ,
                                                                                                    "hash" : $HASH ,
                                                                                                    "index" : $INDEX ,
                                                                                                    "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                                    "originator-pid" : $ORIGINATOR_PID ,
                                                                                                    "provenance" : $PROVENANCE ,
                                                                                                    "standard-error" : $STANDARD_ERROR ,
                                                                                                    "standard-input" : $STANDARD_INPUT ,
                                                                                                    "standard-output" : $STANDARD_OUTPUT ,
                                                                                                    "status" : $STATUS ,
                                                                                                    "targets" : $TARGETS ,
                                                                                                    "transient" : $TRANSIENT
                                                                                                }' | publish > /dev/null 2>&1
                                                                                            mkdir --parents ${ resources-directory }/canonical
                                                                                            ln --symbolic "$MOUNT" "${ resources-directory }/canonical/$HASH"
                                                                                            echo -n "$MOUNT"
                                                                                        else
                                                                                            # shellcheck disable=SC2016
                                                                                            jq \
                                                                                                --null-input \
                                                                                                --argjson ARGUMENTS "$ARGUMENTS_JSON" \
                                                                                                --argjson RESOURCE_DEPENDENCIES "$RESOURCE_DEPENDENCIES" \
                                                                                                --argjson STORE_DEPENDENCIES "$STORE_DEPENDENCIES" \
                                                                                                --arg HASH "$HASH" \
                                                                                                --arg INDEX "$INDEX" \
                                                                                                --arg HAS_STANDARD_INPUT "$HAS_STANDARD_INPUT" \
                                                                                                --arg ORIGINATOR_PID "$ORIGINATOR_PID" \
                                                                                                --arg PROVENANCE "$PROVENANCE" \
                                                                                                --arg STANDARD_ERROR "$STANDARD_ERROR" \
                                                                                                --arg STANDARD_INPUT "$STANDARD_INPUT" \
                                                                                                --arg STANDARD_OUTPUT "$STANDARD_OUTPUT" \
                                                                                                --arg STATUS "$STATUS" \
                                                                                                --argjson TARGETS "$TARGETS" \
                                                                                                --arg TRANSIENT "$TRANSIENT" \
                                                                                                '{
                                                                                                    "arguments" : $ARGUMENTS ,
                                                                                                    "dependencies" :
                                                                                                      {
                                                                                                        "resource" : $RESOURCE_DEPENDENCIES ,
                                                                                                        "store" : $STORE_DEPENDENCIES
                                                                                                      } ,
                                                                                                    "hash" : $HASH ,
                                                                                                    "index" : $INDEX ,
                                                                                                    "has-standard-input" : $HAS_STANDARD_INPUT ,
                                                                                                    "originator-pid" : $ORIGINATOR_PID ,
                                                                                                    "provenance" : $PROVENANCE ,
                                                                                                    "standard-error" : $STANDARD_ERROR ,
                                                                                                    "standard-input" : $STANDARD_INPUT ,
                                                                                                    "standard-output" : $STANDARD_OUTPUT ,
                                                                                                    "status" : $STATUS ,
                                                                                                    "targets" : $TARGETS ,
                                                                                                    "transient" : $TRANSIENT
                                                                                                }' | publish
                                                                                            failure a05ad0c3 "$STANDARD_ERROR" "$STATUS"
                                                                                        fi
                                                                                    fi
                                                                                '' ;
                                                                        values =
                                                                            {
                                                                                arguments-nix = "${ builtins.concatStringsSep "" [ "$" "{" "ARGUMENTS[@]" "}" ] }" ;
                                                                                hash = "${ builtins.concatStringsSep "" [ "$TRANSIENT" "$" "{" "ARGUMENTS[*]" "}" ] }" ;
                                                                                init-application = init-application ;
                                                                                pre-hash = pre-hash secondary ;
                                                                                resources-directory = resources-directory ;
                                                                                store-garbage-collection-root = store-garbage-collection-root ;
                                                                                target-hash-expected = "${ builtins.hashString "sha512" ( builtins.concatStringsSep "" ( builtins.sort builtins.lessThan targets ) ) }" ;
                                                                                transient = transient_ ;
                                                                            } ;
                                                                    } ;
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
                                                                            CURRENT=0
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
                                                script :
                                                    string
                                                        {
                                                            template = { setup , failure } : ''"$( ${ setup } )" || ${ failure }'' ;
                                                            values =
                                                                {
                                                                    setup = script "${ setup }/bin/setup" ;
                                                                    failure = "${ failure }/bin/failure b06fc102" ;
                                                                } ;
                                                        } ;
                            pre-hash =
                                { init ? null , seed ? null , targets ? [ ] , transient ? false } @secondary :
                                    builtins.hashString "sha512" ( builtins.toJSON ( description secondary ) ) ;
                            in
                                {
                                    check =
                                        {
                                            arguments ? [ ] ,
                                            diffutils ,
                                            expected-resource-dependencies ? [ ] ,
                                            expected-store-dependencies ? [ ] ,
                                            expected-index ? 0 ,
                                            expected-originator-pid ,
                                            expected-provenance ? "new" ,
                                            expected-standard-error ,
                                            expected-standard-output ,
                                            expected-status ,
                                            expected-targets ,
                                            expected-transient ,
                                            init ,
                                            resources ? null ,
                                            resources-directory ? "/build/resources" ,
                                            resources-directory-fixture ? null ,
                                            seed ? null ,
                                            self ? null ,
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
                                                                                            null = path : value : implementation { init = init ; seed = seed ; targets = targets ; transient = transient ; } ( setup : "${ setup } ${ builtins.concatStringsSep " " arguments } 2> /build/standard-error" ) ;
                                                                                            string = path : value : implementation { init = init ; seed = seed ; targets = targets ; transient = transient ; } ( setup : "${ setup } ${ builtins.concatStringsSep " " arguments } < ${ builtins.toFile "standard-input" standard-input } 2> /build/standard-error" ) ;
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
                                                                                        echo b05a609e7e3d8c9674412ea01428dcd05923f4685f54ab4b8bc72698eeb39e13dbd0448605fa2df05f0cea571e74126bc6e15309f5943153ca83dce5afc2f4b7 "$0" >&2
                                                                                        fixture
                                                                                        echo cd88cbba913f8cbd7c808bdb9fee733a302661a486c6ba3236071491878afad91c6504bcbfac09ce282797d3914dcf949f64950ca5aabbebfeb6651eb9355910 "$0" >&2
                                                                                        subscribe &
                                                                                        echo f23eca599a6c3834474d3469ce8bce8c178d7e9da38a34685d1dbcba0605c8c6e02414efd2e9be088f73cfdf7d62751daa8784b4066700ccb4cecf3aa1e0ea60 >&2
                                                                                        if RESOURCE=${ resource }
                                                                                        then
                                                                                            STATUS="$?"
                                                                                        else
                                                                                            STATUS="$?"
                                                                                        fi
                                                                                        echo e32340d2f3d1ff5cd9d197a8f2574643d81cffaf68ac495eead443c2cdb5fc68a3561efa303606e0ba072047c60d6dc986d9be6da6f1a927cb85af01d98aa826 "$0" >&2
                                                                                        while [[ ! -f /build/payload ]]
                                                                                        do
                                                                                            redis-cli PUBLISH ${ channel } '{"test" : true}'
                                                                                        done
                                                                                        echo 6f9fe2879dff2ae71781351c64b5057da4350e0b403691653e78c6ad5c61c071210afa550e9f8c7f8a1035b548e97a0c2c1a176bc3a201262c112d24b10ab5bc >&2
                                                                                        EXPECTED_ARGUMENTS="$( jq --null-input '${ builtins.toJSON arguments }' )" || failure 20634b7e
                                                                                        OBSERVED_ARGUMENTS="$( jq ".arguments" /build/payload )" || failure 022394ca
                                                                                        if [[ "$EXPECTED_ARGUMENTS" != "$OBSERVED_ARGUMENTS" ]]
                                                                                        then
                                                                                            echo PAYLOAD >&2
                                                                                            cat /build/payload >&2
                                                                                            failure 75431637 "We expected the payload arguments to be $EXPECTED_ARGUMENTS but it was $OBSERVED_ARGUMENTS"
                                                                                        fi
                                                                                        echo 29d187dee3b012c489f8b8847915e28932b8022b9c6d2b5e7f1a083d71ba6838a38a577033d330acc32352493f3c6387006a0373cc389fa6dada9a4e48572dfe >&2
                                                                                        EXPECTED_RESOURCE_DEPENDENCIES="$( jq --null-input '${ builtins.toJSON expected-resource-dependencies }' )" || failure 9a30de23
                                                                                        cat /build/payload >&2
                                                                                        OBSERVED_RESOURCE_DEPENDENCIES="$( jq ".dependencies.resource" /build/payload )" || failure c2b2d099
                                                                                        if [[ "$EXPECTED_RESOURCE_DEPENDENCIES" != "$OBSERVED_RESOURCE_DEPENDENCIES" ]]
                                                                                        then
                                                                                            failure 93f8acb4 "We expected the payload resource dependencies to be $EXPECTED_RESOURCE_DEPENDENCIES but it was $OBSERVED_RESOURCE_DEPENDENCIES"
                                                                                        fi
                                                                                        EXPECTED_STORE_DEPENDENCIES="$( jq --null-input '${ builtins.toJSON expected-store-dependencies }' )" || failure f364c24b
                                                                                        cat /build/payload >&2
                                                                                        OBSERVED_STORE_DEPENDENCIES="$( jq ".dependencies.store" /build/payload )" || failure ebf0993a
                                                                                        if [[ "$EXPECTED_STORE_DEPENDENCIES" != "$OBSERVED_STORE_DEPENDENCIES" ]]
                                                                                        then
                                                                                            cat /build/payload >&2
                                                                                            failure 9597a6d7 "We expected the payload store dependencies to be $EXPECTED_STORE_DEPENDENCIES but it was $OBSERVED_STORE_DEPENDENCIES"
                                                                                        fi
                                                                                        echo 3352fc3e83a360ffcd717d31caa1b3f30f4beb598edb7aec9d5b6f9744823b121edd3d063f9b1eaa3c3c3f699aa629144cb1f0ddf3a0e453cb1f6d4ac4fdb95b >&2
                                                                                        EXPECTED_DESCRIPTION="$( echo '${ builtins.toJSON ( description { init = init ; seed = seed ; targets = targets ; transient = transient ; } ) }' | jq '.' )" || failure 504d55c5
                                                                                        OBSERVED_DESCRIPTION="$( jq ".description" /build/payload )" || failure 338e000e
                                                                                        if [[ "$EXPECTED_DESCRIPTION" != "$OBSERVED_DESCRIPTION" ]]
                                                                                        then
                                                                                            failure 2057af05 "We expected the payload description to be $EXPECTED_DESCRIPTION but it was $OBSERVED_DESCRIPTION"
                                                                                        fi
                                                                                        echo b942108ab1fc77f5708bbbb9817167ed4a9b615520d764443e690ac080170b9f0cd838967f0294658dcdaf66fd6e81bf14993a070c5c04015f9e0f6cf5296c21 >&2
                                                                                        EXPECTED_INDEX="${ expected-index }"
                                                                                        OBSERVED_INDEX="$( jq --raw-output ".index" /build/payload )" || failure 0f907573
                                                                                        if [[ "$EXPECTED_INDEX" != "$OBSERVED_INDEX" ]]
                                                                                        then
                                                                                            failure 778fa410 "We expected the payload index to be $EXPECTED_INDEX but it was $OBSERVED_INDEX"
                                                                                        fi
                                                                                        echo 8203c90fd1bc42ecbeb27679d364c0102fad5d480ed9263ffe1844f08dc4ed273f314b83dc7c312b5bbfe3900d1e1e1ed38953b72c61f3fce80dce5b59ea5dfa >&2
                                                                                        EXPECTED_HAS_STANDARD_INPUT="${ if builtins.typeOf standard-input == "null" then "false" else "true" }"
                                                                                        OBSERVED_HAS_STANDARD_INPUT="$( jq --raw-output '."has-standard-input"' /build/payload )" || failure de76f4b9
                                                                                        if [[ "$EXPECTED_HAS_STANDARD_INPUT" != "$OBSERVED_HAS_STANDARD_INPUT" ]]
                                                                                        then
                                                                                            failure 9a4d9e4d "We expected the payload has-standard-input to be $EXPECTED_STANDARD_INPUT but it was $OBSERVED_STANDARD_INPUT"
                                                                                        fi
                                                                                        echo 1763f54ece3e60be327e7e32587b1aaf69128d636cdc118dbb7890d87511d547c22505e8a2531cac57aa23c3ac289bb8562d173e64c0dd3e5c0e0818dd77983c >&2
                                                                                        EXPECTED_ORIGINATOR_PID="${ builtins.toString expected-originator-pid }"
                                                                                        OBSERVED_ORIGINATOR_PID="$( jq --raw-output '."originator-pid"' /build/payload )" || failure a3893bb0
                                                                                        if [[ "$EXPECTED_ORIGINATOR_PID" != "$OBSERVED_ORIGINATOR_PID" ]]
                                                                                        then
                                                                                            failure 2f8a9617 "We expected the payload originator-pid to be $EXPECTED_ORIGINATOR_PID but it was $OBSERVED_ORIGINATOR_PID"
                                                                                        fi
                                                                                        echo 043542631b87c60c516dbca29e7cd7042005fdf43d32d8ec4b3810ab365c3674c9c33b597e12f7b463bf7c29d2092949c913fc85dd947b49e660284bba0aa7fc >&2
                                                                                        EXPECTED_PROVENANCE="${ expected-provenance }"
                                                                                        OBSERVED_PROVENANCE="$( jq --raw-output ".provenance" /build/payload )" || failure 028e5f26
                                                                                        if [[ "$EXPECTED_PROVENANCE" != "$OBSERVED_PROVENANCE" ]]
                                                                                        then
                                                                                            failure f2004c0e "We expected the payload provenance to be $EXPECTED_PROVENANCE but it was $OBSERVED_PROVENANCE"
                                                                                        fi
                                                                                        EXPECTED_TARGETS="$( jq --null-input '${ builtins.toJSON expected-targets }' )" || failure 07d64c0d
                                                                                        OBSERVED_TARGETS="$( jq ".targets" /build/payload )" || failure 1f77984f
                                                                                        if [[ "$EXPECTED_TARGETS" != "$OBSERVED_TARGETS" ]]
                                                                                        then
                                                                                            failure 1cd1def6 "We expected the payload targets to be $EXPECTED_TARGETS but it was $OBSERVED_TARGETS"
                                                                                        fi
                                                                                        echo b14d06629264984b8f276fff0c9b6112f64736ac00c04890b54ce584270bc1ce07ad83f1861bfe8cd5c236f8a5b05b802da4626c8b60c52da43a7d90098c22ac >&2
                                                                                        EXPECTED_STANDARD_ERROR="${ expected-standard-error }"
                                                                                        OBSERVED_STANDARD_ERROR="$( jq --raw-output '."standard-error"' /build/payload )" || failure 1f1ee25c
                                                                                        if [[ "$EXPECTED_STANDARD_ERROR" != "$OBSERVED_STANDARD_ERROR" ]]
                                                                                        then
                                                                                            failure d2646d82 "We expected the payload standard-error to be $EXPECTED_STANDARD_ERROR but it was $OBSERVED_STANDARD_ERROR"
                                                                                        fi
                                                                                        EXPECTED_STANDARD_INPUT="${ if builtins.typeOf standard-input == "null" then "" else standard-input }"
                                                                                        OBSERVED_STANDARD_INPUT="$( jq --raw-output '."standard-input"' /build/payload )" || failure e4c24bb8
                                                                                        if [[ "$EXPECTED_STANDARD_INPUT" != "$OBSERVED_STANDARD_INPUT" ]]
                                                                                        then
                                                                                            failure 724dbca6 "We expected the payload standard-input to be $EXPECTED_STANDARD_INPUT but it was $OBSERVED_STANDARD_INPUT"
                                                                                        fi
                                                                                        echo 457f5df94d4d034df1b81a84bcf79db1a68d1b074b4150e5892e75e07df7a99be15055ed35c67460a6ab85fa74929b4137031fca146ed4fc640f27fb1f4aa7e5 >&2
                                                                                        EXPECTED_STANDARD_OUTPUT="${ builtins.toFile "standard-output" expected-standard-output }"
                                                                                        echo e25353a73db53ec30cdd4ee7a59c6a51135c65867330fe6b419e6b36f8fb42bca619c0bc18a685709ecaaded651a824e201b0ce6b6a8658d8eac241edab1623b >&2
                                                                                        echo "a848eba021e0006248fc6d98217a58c30dacba6cec4e23c29b5bed81991e60f514648588aeea34e6559a9c57f3e5fc948c577b6b35649504fbf64a2e13d3b31c $OUT/payload" >&2
                                                                                        mkdir --parents "/build/observed/payload"
                                                                                        echo 831dc85c382d50c75d93e31082d489a8aa0024194321f80aad30c4bb02c8e925d10dc9a8d9aa21b444cf76de1b7703c06135ad4bffb7dcd07d5d560b85aee010 >&2
                                                                                        jq --raw-output '."standard-output"' /build/payload > "/build/observed/payload/standard-output"
                                                                                        echo 8e85f21da99e7ecedb49022cce6a7dc8e9b1720a6d2e7489ab2478740fe87d9b0335eac575b7f21dea8da77de0da3645aea8a37231062ef33e54506e79c854bc >&2
                                                                                        if ! diff --unified "$EXPECTED_STANDARD_OUTPUT" "/build/observed/payload/standard-output"
                                                                                        then
                                                                                            mkdir --parents "$OUT/payload"
                                                                                            cp /build/observed/payload/standard-output "$OUT/payload/standard-output"
                                                                                            failure 0d3810c3 "We expected the payload standard-output to be $EXPECTED_STANDARD_OUTPUT but it was $OUT/payload/standard-output"
                                                                                        fi
                                                                                        echo 412334ef83627ae9156840c2b8f2e1874ee0a42ca6ad06776ba0b806b26ed312b658f8f9af9619c2fa61c1c026433db697a2a4dfd5a1082c2bf6fe4bddb7221a >&2
                                                                                        EXPECTED_STATUS="${ builtins.toString expected-status }"
                                                                                        OBSERVED_STATUS="$( jq --raw-output ".status" /build/payload )" || failure ef32fe9f
                                                                                        if [[ "$EXPECTED_STATUS" != "$OBSERVED_STATUS" ]]
                                                                                        then
                                                                                            failure 8a455ee1 "We expected the payload status to be $EXPECTED_STATUS but it was $OBSERVED_STATUS"
                                                                                        fi
                                                                                        echo 7bb9c6f19f9e2cd621024703291f2aad6cb593fc8ba3710ebb3e7c8511f9291c9f60ac5af7178fd853f2754c0fa91770c7fdc98a5f75ae91953755f0147bc6d3 >&2
                                                                                        EXPECTED_TRANSIENT="${ builtins.toString expected-transient }"
                                                                                        OBSERVED_TRANSIENT="$( jq --raw-output ".transient" /build/payload )" || failure c51dee8f
                                                                                        if [[ "$EXPECTED_TRANSIENT" != "$OBSERVED_TRANSIENT" ]]
                                                                                        then
                                                                                            failure ba808c74 "We expected the payload transient to be $EXPECTED_TRANSIENT but it was $OBSERVED_TRANSIENT"
                                                                                        fi
                                                                                        echo bd094b80d0c86c33b0915838ea6474176585685e3246de6338b69709dbf0554318fc7596edf98a1203c8aeb70c2792686540866f0e4a11763d590f5afad75bba >&2
                                                                                        PRE_HASH="${ pre-hash { init = init ; seed = seed ; targets = targets ; transient = transient ; } }"
                                                                                        echo 51ecd77c8f30740a52efc520a7efc5bff5ab90c5f76fbfbf9f8800d5c293db75ebc64c22670c3e29a997d71394c6ab2604293141f9c3a7ba07183fd075b07371 >&2
                                                                                        FORMATTED_ARGUMENTS="${ builtins.concatStringsSep " " arguments }"
                                                                                        EXPECTED_HASH="$( echo "$PRE_HASH $EXPECTED_TRANSIENT$FORMATTED_ARGUMENTS $EXPECTED_STANDARD_INPUT $EXPECTED_HAS_STANDARD_INPUT" | sha512sum | cut --characters 1-128 )" || failure 291ae43b
                                                                                        OBSERVED_HASH="$( jq --raw-output ".hash" /build/payload )" || failure ad74a1ed
                                                                                        if [[ "$EXPECTED_HASH" != "$OBSERVED_HASH" ]]
                                                                                        then
                                                                                            failure f40a3551 "We expected the payload hash to be $EXPECTED_HASH but it was $OBSERVED_HASH"
                                                                                        fi
                                                                                        EXPECTED_KEYS="$( echo '${ builtins.toJSON [ "arguments" "dependencies" "description" "has-standard-input" "hash" "index" "originator-pid" "provenance" "standard-error" "standard-input" "standard-output" "status" "targets" "transient" ] }' | jq --raw-output "." )" || failure a90aef96
                                                                                        OBSERVED_KEYS="$( jq --raw-output "[keys[]]" /build/payload )" || failure ed34aceb
                                                                                        if [[ "$EXPECTED_KEYS" != "$OBSERVED_KEYS" ]]
                                                                                        then
                                                                                            failure 7e35fa52 "We expected the payload keys to be $EXPECTED_KEYS but it was $OBSERVED_KEYS"
                                                                                        fi
                                                                                        if [[ "${ standard-output }" != "$RESOURCE" ]]
                                                                                        then
                                                                                            failure 5f110695 "We expected the standard output to be ${ standard-output } but it was $RESOURCE"
                                                                                        fi
                                                                                        if [[ "${ builtins.toString status }" != "$STATUS" ]]
                                                                                        then
                                                                                            failure 85b629ef "We expected the status to be ${ builtins.toString status } but it was $STATUS"
                                                                                        fi
                                                                                        echo 3d91c76e34e174908af328b36c07bf31e1ffd82f709a1bd4668f252a3882eb30c5e400cbfcbc8fef7ddbe24af5d9e337cd6f46edfee3bcb489f3700e9056d5fe /build/standard-error "$OUT/standard-error" >&2
                                                                                        echo 5070b76a530a48e5c61c41880674dc3a850e28e974a9a6adcf5021d6363e71a1b4a83538df4afb7588b5d94e9d80226446447d5226f1dac94a47231c9b2dbc23 >&2
                                                                                        if ! diff --unified ${ builtins.toFile "standard-error" standard-error } /build/standard-error
                                                                                        then
                                                                                            echo 0aadd697be4a826aa1d6a0a023065aefded13a789407c7705eaf73e4322e218ffd56c14cc4fe3ab1f801581f026115e318464ebc49f125726025c220294f4566 >&2
                                                                                            cp /build/standard-error "$OUT/standard-error"
                                                                                            echo 7f5ebff2cac0591df963be03c307617684981c85bc9b7c3960a064c543951ec175fc9ee98e1e6592d0ad68fa18abbd146ad5e43c8ad3c5ce75449035f91376fa >&2
                                                                                            failure 19e7dbe8 "We expected the standard error file to be ${ builtins.toFile "standard-error" standard-error } but it was $OUT/standard-error"
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
