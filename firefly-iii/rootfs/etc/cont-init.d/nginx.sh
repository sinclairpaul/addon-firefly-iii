#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: Firefly III
# This file configures nginx
# ==============================================================================
declare keyfile
declare ingress_interface
declare ingress_entry

bashio::config.require.ssl

if bashio::config.true 'ssl'; then
    certfile=$(bashio::config 'certfile')
    keyfile=$(bashio::config 'keyfile')

    mv /etc/nginx/servers/direct-ssl.disabled /etc/nginx/servers/direct.conf
    sed -i "s/%%certfile%%/${certfile}/g" /etc/nginx/servers/direct.conf
    sed -i "s/%%keyfile%%/${keyfile}/g" /etc/nginx/servers/direct.conf
else
    mv /etc/nginx/servers/direct.disabled /etc/nginx/servers/direct.conf
fi

ingress_interface=$(bashio::addon.ip_address)
sed -i "s/%%interface%%/${ingress_interface}/g" /etc/nginx/servers/ingress.conf

ingress_entry=$(bashio::addon.ingress_entry)
sed -i "s#%%ingress_entry%%#${ingress_entry}#g" \
    /etc/php/7.2/fpm/pool.d/ingress.conf