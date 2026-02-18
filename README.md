# Resource Flake

A Nix flake providing modular, reusable resources for NixOS and Nix-based workflows.

## Features

The lib lambda takes the following parameters and returns two lambdas:  implementation and check.
Most of these parameters can be sourced from pkgs.

| name                    | probable source                                                                                                                                                                | 
|-------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| buildFHSUserEnv         | pkgs                                                                                                                                                                           |
| channel                 | "redis" - it does not really matter what the channel is named as long as it is consistent                                                                                      |
| coreutils               | pkgs                                                                                                                                                                           |
| failure                 | this is a script that is called on failure.  my implementation echos a UUID to standard error and exits with code 64.  In the event of error, the UUID makes debugging easier. |
| findutils               | pkgs                                                                                                                                                                           |
| flock                   | pkgs                                                                                                                                                                           |
| jq                      | pkgs                                                                                                                                                                           |
| makeBinPath             | pkgs                                                                                                                                                                           |
| makeWrapper             | pkgs                                                                                                                                                                           |
| mkDerivation            | pkgs                                                                                                                                                                           |
| nix                     | pkgs                                                                                                                                                                           |
| originator-pid-variable | a long random string.  it does not really matter what this is as long as it does not conflict with your variable names                                                         |
| ps                      | pkgs                                                                                                                                                                           |
| redis                   | pkgs                                                                                                                                                                           |
| resources               | you can put anything here.  i define a lot of "resources" using this flake and make them available to the flake as resources.                                                  |
| resources-directory         | this is arbitrary.  I set it at ~/resources                                                                                                                                    |
| sequential-start         | this is arbitrary and probably not important.  I set it randomly.  The sequence starts with this number.                                                                       |
| store-garbage-collection-root         | I think this is not arbitrary.  I think this must be ~/.gc-root                                                                                                                |
| string                  | i plan to delete this soon.                                                                                                                                                    |
| visitor                 | this is a a flake that is like builtins.map or builtins.mapAttrs but !!better!!                                                                                                |
| writeShellApplication         | pkgs                                                                                                                                                                           |
| yq-go                   | pkgs                                                                                                                                                                           |


### Implementation

implementation is a lambda that takes

| name     | description                                                                                                                                                                                                                                                                           |
|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| init     | probably the single most important thing.  this is a method for constructing the resource.                                                                                                                                                                                            |
| seed     | this can be anything including null.  the contents are completely up to the user.  the contents are used to calculate the hash address of the resource (but for nothing else).  in this way two otherwise identical resources can have different hashes if the seed is not identical. |
| targets  | this is what the resource creates.  if the resources does not create the targets or creates more than the targets there is an error                                                                                                                                                   |
| transient | this is for saying that the resource should or should not be cached                                                                                                                                                                                                                   |

and returns a lambda that we will call resource.

The resource lambda takes

| name | description |
| -----|-------------|
| failure | this is what we do in case of failure.  this has a default value.  failure can either be a string or an integer.  If it is an integer then we are just going to echo that integer to standard error and exit with status 64.  In the event of error we can examine the standard error and the searching for this error integer will help us debug. |
| setup | this has a default value.  for the most part we will just use the default value.  but if we want to it is like setup = setup : ''${ setup } arg1 arg2 < /tmp/standard-input-file'' |

In code we use the resource lambda.
We can specify what happens in failure and the exact setup (but in practice we would rarely use setup).
So ALPHA=\${ my-resource { failure = 1001 ; setup = setup : ''${ setup } hello world'' ; }
would map to
ALPHA="\$( /nix/store/{something long}/bin/setup hello world )" || /nix/store/{ some other long thing }/bin/failure 1001

The setup method is the heart of the resource and it is based on the above parameters.
1. It calculates a hash based on all the inputs.  Changing an input even slightly changes the hash.
   1. The seed parameter is provided for the express purpose of allowing the user to perturb the input ever so slightly and obtaining a new hash.
   2. The transient parameter is provided for the express purpose of effectively disabling cache.  If transient is true then we will roll a sequential number into the hash calculation.  Since the sequential number is always unique, setting transient true means no caching.
2. It looks to see if we have that cached value.
   1. If yes then
      1. it returns that cached value
      2. It publishes an appropriate yaml to redis
   2. If no then
      1. it uses the init to generate the value
         1. The user provided init is a lambda that takes parameters:  { pid , pkgs , resources , root , sequential , wrap }
         2. The setup function builds a fhsUserEnvironment and runs the script based on init
         3. The variables are:
            1. pid - to be deleted
            2. pkgs - this is the standard pkgs. but it is from the buildFHSUserEnv.  so for example if the user does not have chromium on their system then when the init method is executed chromium will be installed iff the user references it.  Soon the system will no longer need chromium and it will be eligible for collection.
            3. resources - this is a way for the user to make some resources dependent on other resources.  an init function might use other resources.  I am thinking of a pass script that needs a gpg directory.  That can be a resource itself that needs a secret-key resource.
            4. root - this is a script that creates a symbolic link to the argument inside the users ~/.gc-roots directory.
               1. root { pkgs.chromium } ... rooting a nix store ... if our system does not have chromium installed then the setup will install it.  in general, as soon as setup is complete chromium is eligible for collection.  However we can root chromium and since a link to it is in ~/.gc-roots it is not eligible for collection.
               2. root { resource } ... we have our own collection system that does not collect resources linked in ~/gc-roots.  by rooting a resource we insure that it survives post setup
            5. sequential - this is a script that returns a sequential incremented number.  0, 1, 2, ....  It is unique
            6. wrap - this is a script that is like ln or setenvs
      2. it caches the generated value
      3. it returns that generated value
      4. it publishes an appropriate yaml to redis

### check
check is a supporting function for testing. It produces a derivation that validates an implementation against expected values at compile time, ensuring deterministic behavior. Use it to verify your resources during development.

## Usage

Add the flake as an input in your flake.nix:

inputs = {
nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
resource-flake.url = "github:AFnRFCb7/resource-flake";
};


Invoke a resource:

let
lib = import resource-flake {};
in
lib.implementation {
buildFHSUserEnv = ...;
coreutils = ...;
# provide required dependencies
};


(Optional) Run a check:

lib.check {
expected-standard-output = "hello world";
arguments = [ "arg1" ];
diffutils = ...;
};

## Lifecycle

This flake is the start of the resource life cycle.
The execution of the setup command can either be a success or a failure.
Either way it will publish a redis message.
If it is a success it will output the path of the resource.
If it is a failure it will create a "quarantine directory".

### success init
The published success message contains an originator pid.
This is the pid of the process that invoked the setup command.
The published success message also contains the assigned path of the resource.
A release listener can spawn a process that
1. waits for the originator pid to finish
2. waits while there still are references to the assigned path of the resource in ~/.gc-roots

and then execute the user provided release script (also in the message).
After that, the script deletes the resource and any files associated with the resource in ~/.gc-roots
After this, the resource no longer exists and this is success.

### failed init
In the event of failure, a resolve listener can create a quarantine directory.
This quarantine directory can contain the failure message.
It also contains one or more resolution scripts.
Invoking one of the resolution script, the user can indicate manual resolution of the problem.
The resource goes back into the flow as a "now" successful init.

### failed release
Whether the init succeeded or failed, the release script will eventually be invoked.
Assuming it failed much the same thing will happen as if the init failed.
A quarantine directory will be created.
The message will be recorded.
One or more resolution scripts will be generated.
Invoking one of the resolution scripts will put the resource back in flow.
But the next step is success and that is terminal.
