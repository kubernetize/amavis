FROM alpine:3.24.2

LABEL maintainer="Richard Kojedzinszky <richard@kojedz.in>"

RUN adduser -h /var/amavis -s /bin/false -D -u 3334 amavis

RUN apk --no-cache add amavis spamassassin perl-mail-spf p7zip cabextract tzdata \
    file altermime xz lrzip lz4 perl-dbd-mysql perl-dbd-pg && \
    sa-update -v && \
    chown -R amavis:amavis /etc/mail/spamassassin /var/lib/spamassassin

COPY assets /

RUN \
    chown 0:0 /etc/amavisd.conf /etc/amavisd-env.conf /etc/amavisd-local.conf && \
    chmod 0644 /etc/amavisd.conf /etc/amavisd-env.conf /etc/amavisd-local.conf

USER 3334

CMD ["/usr/sbin/amavisd", "-c", "/etc/amavisd.conf", "-c", "/etc/amavisd-env.conf", "-c", "/etc/amavisd-local.conf", "foreground"]
