#!/bin/sh
APP_PATH="/home/deploy/sites/kidscloset.biz/current"
kill -HUP `cat $APP_PATH/log/searchd.production.pid`
