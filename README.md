# amavis

Amavis installed from Alpine. Configuration is layered, with later layers
winning:

1. `/etc/amavisd.conf` — the configuration shipped by the Alpine `amavis`
   package. The image does not modify its contents.
2. `/etc/amavisd-env.conf` — environment-variable driven overrides shipped by
   this image. See [amavisd-env.conf](assets/etc/amavisd-env.conf) for the
   supported variables and their defaults.
3. `/etc/amavisd-local.conf` — optional local overrides, loaded last. Mount
   your own file here; it wins over both layers above.

An unset environment variable normally keeps the value from the distribution
configuration, except for documented container-specific overrides such as the
disabled unix socket and stderr logging. Numeric and boolean variables treat
an empty value as unset. Boolean variables accept `1`/`0`, `true`/`false`,
`yes`/`no`, and `on`/`off`. For example, `ENABLE_DKIM_VERIFICATION=0`
disables DKIM verification while leaving it unset keeps the distribution
default (enabled), and `SA_TAG_LEVEL_DEFLT` unset keeps the distribution's
threshold (2.0).

`MYHOSTNAME` must be a fully qualified domain name. If it is unset,
`hostname -f` is used; amavis refuses to start when that does not return an
FQDN.

Admin notifications are disabled by default. Set `VIRUS_ADMIN` and/or
`SPAM_ADMIN` to enable virus/banned and spam notifications respectively.

Logs are written to stderr; the image does not run syslog.

The `amavisd-release`/milter unix socket is disabled by default. Set
`UNIX_SOCKETNAME` to a path only when a release or milter helper is actually
used.

## ClamAV

The image does not run a local virus scanner. Set `CLAMAV_HOST` to use a
remote clamd; `CLAMAV_PORT` defaults to `3310`. If `CLAMAV_HOST` already
contains a `host:port` address, that port is used unless `CLAMAV_PORT` is also
set, in which case `CLAMAV_PORT` wins.

## Custom configuration

Settings that are not covered by environment variables can be placed in
`/etc/amavisd-local.conf`, or a file can be mounted over it. This includes
container-specific settings that are intentionally not exposed, such as paths,
syslog, the daemon user, and BerkeleyDB.

Mounting a complete configuration over `/etc/amavisd.conf` replaces the
distribution base, but `/etc/amavisd-env.conf` is still loaded afterwards and
can override it. To use a fully custom configuration without the environment
layer, override the container command and omit `/etc/amavisd-env.conf`.

## Policy banks

The distribution's `MYNETS` and `ORIGINATING` policy banks are kept. Because
`@mynetworks` includes the private IPv4/IPv6 ranges, a mail server connecting
from a private address is treated as `originating`. Port 10026 uses the
`ORIGINATING` bank, which forwards to `smtp:127.0.0.1:10027`; run a DKIM
signing service there or override the policy bank in
`/etc/amavisd-local.conf`.
