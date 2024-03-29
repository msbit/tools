# Tools

A grab bag of scripts that I have used often enough to find semi-useful

## (Dis)Assemble APK

    assemble-apk.sh <source-dir> <apk-file>
    disassemble-apk.sh <apk-file> <dest-dir>

## Backup APK

    backup-apk.sh <destination-dir>

Backup all APK files from an attached Android device.

## Build RSA Key

    build-rsa-key.sh <bae64-modulus> <base64-exponent>

Build an RSA key from the provided Base64 encoded `modulus` and `exponent`.

## Bundle Updates

    bundle-updates.sh

Run Bundle update in a Ruby project, determine the appropriate direct and transitive dependencies, and add a Git commit with a corresponding message.

## Curl Benchmark

    curl-benchmark.sh <curl-arguments>

Execute a Curl request a number of times, reporting the total time spent on the request, for a loose benchmark of the request.

## Fetch Apple Event

    fetch-apple-event.sh <url> <quality>

Download all TS files for a specified Apple event and concatenate them using FFmpeg.

## Hash Files

    hash-files.sh <file> [<file> ...]

Hash provided files and rename to that hash, preserving file extension.

## JKS to CRT Key

    jks-to-crt-key.sh <source-key-store> <source-alias>

Extract a specific key from a Java Key Store file and convert into an OpenSSL PEM formatted public/private key pair.

## Make CA

    make-ca.sh <ca-root-dir> <ca-cn> <server-cn> <client-cn>

Make a local Certificate Authority using OpenSSL.

## MySQL Root

    mysql-root.sh

Under Debian, log into MySQL as the root user, using the specific maintainer user created at package install time.

## NG Updates

    ng-updates.js

Run `ng update` in a NodeJS project with all currently configured package and version specifications, determine the appropriate direct and transitive dependencies, and add a Git commit with a corresponding message.

## NPM Updates

    npm-updates.js

Run NPM install in a NodeJS project after removing the existing lockfile, determine the appropriate direct and transitive dependencies, and add a Git commit with a corresponding message.

## Pkg Remove

    pkg-remove.sh <pkg-id>

Under macOS, remove all files associated with a package and then forget the package itself, ostensibly acting as the missing pkgutil remove command.

## Push All

    push-all.sh <push-arguments>

Iterate over each Git remote and push with the provided arguments.

## Scratch

    scratch.sh

Open a new shell instance in a temporary scratch directory, and clean up the directory once the shell has closed.

## Strip JAR

    strip-jar.sh <in-jar-file> <out-jar-file> <class>

Unpack a JAR file and create an updated JAR file with the specified classes/packages removed.

## Update Drupal

    update-drupal.sh

Perform an appropriate sequence of `drush` commands to properly update Drupal.

## Version APK

    version-apk.sh <apk-file> [<apk-file> ...]

Print out the package, version and version code of a specified APK file.

## Zopfli Files

    zopfli-files.sh <file.png> [<file.png> ...]

Optimise PNG files using `zopflipng`, updating them in place.

## Zopfli Files (Concurrent)

    zopfli-files-concurrent.sh <file.png> [<file.png> ...]

As per `Zopfli Files`, running as many jobs as there are logical cores on the machine.
