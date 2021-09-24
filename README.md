# TimescaleDB Docker Image

This is a Postgresql image that includes Patroni, TimescaleDB and the Promscale-extension. It is based on https://github.com/xenit-eu/docker-patroni.

The TimescaleDB extension will be created automatically by a Patroni post-init script. The Promscale extension will not be created automatically, it should be created by Promscale itself.