FROM alpine:3.20

LABEL maintainer="Richard Kojedzinszky <richard@kojedz.in>"

RUN adduser -h /var/amavis -s /bin/false -D -u 3334 amavis

RUN apk --no-cache add amavis spamassassin perl-mail-spf p7zip cabextract tzdata \
    file altermime xz lrzip lz4 perl-dbd-mysql perl-dbd-pg && \
    grep '^use Amavis::IO::Zlib' /usr/share/perl5/vendor_perl/Amavis/Out/Local.pm | wc -l | grep -q "^0$" && \
    sed -i -r -e '/^use Amavis::Conf/,/^$/{/^$/{ i\' -e 'use Amavis::IO::Zlib;' -e '}}' /usr/share/perl5/vendor_perl/Amavis/Out/Local.pm && \
    sa-update -v && \
    chown -R amavis:amavis /etc/mail/spamassassin /var/lib/spamassassin

COPY assets /

USER 3334

CMD ["/usr/sbin/amavisd", "-c",  "/etc/amavisd.conf", "-c", "/etc/amavisd-local.conf", "foreground"]
