#!/bin/sh

MAIN_PATH="/home/deploy/sites/kidscloset.biz"
INDEX_PATH="$MAIN_PATH/shared/sphinx/production"
TMP_PATH="$MAIN_PATH/shared/sphinx/tmp"
APP_PATH="$MAIN_PATH/current"

mkdir -p $TMP_PATH
cd $APP_PATH
/usr/local/bin/rake production ts:index

for filename in $( ls $INDEX_PATH ); do
  new_filename=${filename/./.new.}
  /bin/cp $INDEX_PATH/$filename $TMP_PATH/$new_filename
  /bin/rm -f $INDEX_PATH/$filename
done

cd $TMP_PATH
for ip in 173.230.133.42 74.207.226.108; do
  /usr/bin/rsync -rvz -e "ssh" . deploy@$ip:$INDEX_PATH
  ssh deploy@$ip "/home/deploy/sites/kidscloset.biz/current/script/bionic/rotate_index.sh"
done

exit 0
