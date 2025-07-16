exec 2>&1

bufr() {
  (
    set -eux
    cd bufr
    mkdir -pv build
    cd build
    flags=(
      -DENABLE_TESTS=OFF
      -DCMAKE_INSTALL_PREFIX=$PREFIX
      -DCMAKE_MAKE_PROGRAM=$(which make)
      -Wno-dev
    )
    cmake ${flags[*]} ..
    make -j
    make install
  )
}

datascript() {
  (
    metbase_url=$(jq -r .metbase $RECIPE_DIR/urls.json)
    metplus_url=$(jq -r .metplus $RECIPE_DIR/urls.json)
    outfile=$PREFIX/bin/met2go-data
    mkdir -pv $(dirname $outfile)
    args=(
      -e "s@<METBASE_URL>.*@$metbase_url@"
      -e "s@<METPLUS_URL>.*@$metplus_url@"
      $RECIPE_DIR/datascript
    )
    sed ${args[*]} >$outfile
    chmod +x $outfile
  )
}

met() {
  (
    set -eux
    cd met
    export BUFRLIB_NAME=-lbufr_4_DA
    export GRIB2CLIB_NAME=-lg2c
    export MET_BUFR=$PREFIX
    export MET_GRIB2CINC=$PREFIX
    export MET_GRIB2CLIB=$PREFIX
    export MET_GSL=$PREFIX
    export MET_HDF5=$PREFIX
    export MET_NETCDF=$PREFIX
    export MET_PYTHON_BIN_EXE=$PYTHON
    export MET_PYTHON_CC=$(python3-config --cflags)
    export MET_PYTHON_LD=$(python3-config --ldflags --embed)
    flags=(
      --datarootdir=/dev/null # do not install data files
      --enable-grib2
      --enable-python
      --prefix=$PREFIX
    )
    ./configure ${flags[*]}
    make install
    mkdir -pv $PREFIX/etc/
  )
}

metcalcpy() {
  (
    cd metcalcpy
    rsync -av metcalcpy/ $SP_DIR/metcalcpy/
  )
}

metdataio() {
  (
    cd metdataio
    for pkg in METdbLoad METreformat; do
      rsync -av $pkg/ $SP_DIR/$pkg/
    done
    mkdir -pv $PREFIX/bin/
    exes=(
      METreformat/write_stat_ascii.py
    )
    for exe in ${exes[*]}; do
      chmod +x $SP_DIR/$exe
      ln -s $SP_DIR/$exe $PREFIX/bin/
    done
  )
}

metplotpy() {
  (
    cd metplotpy
    rsync -av metplotpy/ $SP_DIR/metplotpy/
    mkdir -pv $PREFIX/bin/
    exes=(
      metplotpy/plots/line/line.py
    )
    for exe in ${exes[*]}; do
      sed -i '1s@^@#!/usr/bin/env python\n@' $SP_DIR/$exe
      chmod +x $SP_DIR/$exe
      ln -s $SP_DIR/$exe $PREFIX/bin/
    done
  )
}

metplus() {
  (
    cd metplus
    pip install -v .
    mkdir -pv $PREFIX/bin/
    cp -dv ush/*.py $PREFIX/bin/
    rsync -av metplus/ $SP_DIR/metplus/
    rsync -av produtil/ $SP_DIR/produtil/
    mkdir -pv $PREFIX/etc/
  )
}

netcdf_cxx() {
  (
    set -eux
    cd netcdf-cxx
    mkdir -pv build
    cd build
    flags=(
      -DBUILD_TESTING=OFF
      -DCMAKE_INSTALL_PREFIX=$PREFIX
      -DCMAKE_MAKE_PROGRAM=$(which make)
      -Wno-dev
    )
    cmake ${flags[*]} ..
    make -j
    make install
    ln -s $PREFIX/lib/libnetcdf-cxx4.so $PREFIX/lib/libnetcdf_c++4.so
  )
}

set -eux

bufr
netcdf_cxx
met
metplus
metcalcpy
metdataio
metplotpy
datascript

rsync -av $RECIPE_DIR/etc/ $PREFIX/etc/
