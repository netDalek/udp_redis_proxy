#!/bin/sh
erl -pa ebin deps/*/ebin -eval 'application:start(udp_redis_proxy, permanent).'
