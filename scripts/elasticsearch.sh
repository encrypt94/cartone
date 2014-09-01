#!/bin/sh

exec /elasticsearch/bin/elasticsearch >>/var/log/elasticsearch.log 2>&1
