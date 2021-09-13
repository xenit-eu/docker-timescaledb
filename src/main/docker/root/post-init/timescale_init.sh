#!/bin/bash

echo psql "$@" -c 'CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;'
psql "$@" -c 'CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;'

