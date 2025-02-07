set -e
for x in met metplus; do
  f=$PREFIX/etc/$x.tar.bz2
  tar xjf $f --one-top-level --strip-components=1 -C $PREFIX/etc
  rm $f
done
