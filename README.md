# Tools

A grab bag of Bash scripts that I have used often enough to find semi-useful

## Backup APK

    backup-apk.sh <destination-dir>

Backup all APK files from an attached Android device.

## Bundle Updates

    bundle-updates.sh

Run Bundle update in a Ruby project, determine the appropriate direct and transitive dependencies, and add a Git commit with a corresponding message.

## Fetch Apple Event

    fetch-apple-event.sh <url> <quality>

Download all TS files for a specified Apple event and concatenate them using FFmpeg.

## JKS to CRT Key

    jks-to-crt-key.sh <source-key-store> <source-alias>

Extract a specific key from a Java Key Store file and convert into an OpenSSL PEM formatted public/private key pair.

## Make CA

    make-ca.sh <ca-root-dir> <ca-cn> <server-cn> <client-cn>

Make a local Certificate Authority using OpenSSL.

## MySQL Root

    mysql-root.sh

Under Debian, Log into MySQL as the root user, using the specific maintainer user created at package install time.

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
