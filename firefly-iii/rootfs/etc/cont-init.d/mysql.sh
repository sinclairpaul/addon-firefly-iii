#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: Firefly
# This file initialises the MySQL database
# ==============================================================================
if ! bashio::fs.directory_exists "/data/mysql"; then
    bashio::log "Creating MySql directory"
    mkdir /data/mysql
    chown mysql:mysql /data/mysql
fi
# Initialize the database data directory.
if ! bashio::fs.directory_exists "/data/mysql/mysql"; then

    bashio::log.info "Initializing database..."
    s6-setuidgid mysql mysql_install_db --datadir=/data/mysql
    # Start MySQL.
    /usr/bin/mysqld_safe --datadir=/data/mysql \
        --tmpdir=/tmp/ --user=mysql &
    rc="$?"
    pid="$!"
    if [ "$rc" -ne 0 ]; then
        bashio::exit.nok "Failed to start the database."
    fi

    # Wait until it is ready.
    for _ in $(seq 1 30); do
        if echo 'SELECT 1' | mysql &> /dev/null; then
            break
        fi
        sleep 1
    done

    # Secure the installation.
    printf '\nn\n\n\n\n\n' | /usr/bin/mysql_secure_installation

    # Create the database.
    bashio::log.info "Creating Database..."
    echo "CREATE DATABASE IF NOT EXISTS \`firefly\` ;" | mysql

    # Create the user.
    bashio::log.info "Creating User..."
    echo "CREATE USER 'firefly'@'localhost' IDENTIFIED BY 'firefly' ;" | mysql
    echo "GRANT ALL ON \`firefly\`.* TO 'firefly'@'localhost' ;" | mysql
    echo "FLUSH  PRIVILEGES ;" | mysql
    # Stop the MySQL server
    if ! kill -s TERM "$pid" || ! wait "$pid"; then
        bashio::exit.nok "Initialization of database failed."
    fi
fi
#Setup error logging
ln -sf /dev/stderr /data/mysql/log.err 
chown mysql:mysql /data/mysql/log.err