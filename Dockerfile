ARG VERSION="8.1"

FROM php:${VERSION}-fpm

RUN apt-get update -y
RUN apt-get -y install gcc make autoconf libc-dev pkg-config libzip-dev

RUN apt-get install -y --no-install-recommends \
	git \
	libmemcached-dev \
	libz-dev \
	wget \
	libpq-dev \
	libssl-dev libssl-doc libsasl2-dev \
	libmcrypt-dev \
	libxml2-dev \
	zlib1g-dev libicu-dev g++ \
	libldap2-dev libbz2-dev \
	curl libcurl4-openssl-dev \
	libgmp-dev firebird-dev libib-util \
	re2c libpng++-dev \
	libwebp-dev libjpeg-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libvpx-dev libfreetype6-dev \
	libmagick++-dev \
	libmagickwand-dev \
	zlib1g-dev libgd-dev \
	libtidy-dev libxslt1-dev libmagic-dev libexif-dev file \
	sqlite3 libsqlite3-dev libxslt-dev \
	libmhash2 libmhash-dev libc-client-dev libkrb5-dev libssh2-1-dev \
	unzip libpcre3 libpcre3-dev \
	poppler-utils ghostscript libmagickwand-6.q16-dev libsnmp-dev libedit-dev libreadline6-dev libsodium-dev \
	freetds-bin freetds-dev freetds-common libct4 libsybdb5 tdsodbc libreadline-dev librecode-dev libpspell-dev libonig-dev

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
	docker-php-ext-install imap iconv

# fix for docker-php-ext-install pdo_dblib
# https://stackoverflow.com/questions/43617752/docker-php-and-freetds-cannot-find-freetds-in-know-installation-directories
RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/
RUN docker-php-ext-install pdo_dblib

RUN docker-php-ext-install bcmath bz2 calendar ctype curl dba dom
RUN docker-php-ext-install fileinfo exif ftp gettext gmp
RUN docker-php-ext-install intl ldap mbstring mysqli
RUN docker-php-ext-install opcache pcntl pspell
RUN docker-php-ext-install pdo_mysql pdo_pgsql pdo_sqlite pgsql phar posix
RUN docker-php-ext-install session shmop simplexml soap sockets sodium
RUN docker-php-ext-install sysvmsg sysvsem sysvshm
RUN docker-php-ext-install snmp
RUN docker-php-ext-install xml xsl
RUN docker-php-ext-install tidy zip
RUN docker-php-ext-install filter

# install pecl extension
RUN pecl install ds && \
	pecl install imagick && \
	pecl install igbinary && \
	pecl install memcached && \
	pecl install mcrypt && \
	docker-php-ext-enable ds imagick igbinary memcached

# RUN pecl install mongodb && docker-php-ext-enable mongodb

# install xdebug
RUN pecl install xdebug

RUN yes "" | pecl install msgpack && \
	docker-php-ext-enable msgpack

# install APCu
RUN pecl install apcu && \
	docker-php-ext-enable apcu --ini-name docker-php-ext-10-apcu.ini

RUN apt-get update -y && apt-get install -y apt-transport-https locales gnupg

# install GD
RUN docker-php-ext-configure gd \
	--with-jpeg \
	--with-xpm \
	--with-webp \
	--with-freetype \
	&& docker-php-ext-install -j$(nproc) gd

# set locale to utf-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# install composer
RUN EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)" && \
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" && \
	if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then >&2 echo 'ERROR: Invalid installer checksum' && exit 1; fi

RUN php composer-setup.php --quiet && rm composer-setup.php && \
	mv composer.phar /usr/local/sbin/composer && \
	chmod +x /usr/local/sbin/composer

# Add default configuration files
ADD docker/php/php.ini /usr/local/etc/php/
ADD docker/php/www.conf /usr/local/etc/php-fpm.d/

# Copy scripts
COPY docker/bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Clean up
RUN apt-get remove -y git && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create non-root user
RUN useradd -u 1000 --create-home --shell "/bin/bash" app && \
    usermod -a -G www-data app && \
    mkdir /app && \
    chown -R app:app /app

USER app
WORKDIR /app

# Install dependencies with composer
COPY app/composer.json composer.json
COPY app/composer.lock composer.lock

RUN composer install --optimize-autoloader --classmap-authoritative --no-scripts --no-interaction --no-dev

COPY app /app

