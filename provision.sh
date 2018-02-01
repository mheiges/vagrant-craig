#!/bin/bash

set -e

cat > /home/vagrant/.craig <<EOF
export PREFIX_INSTALLATION=/opt/craig
export CRAIG_HOME=\$PREFIX_INSTALLATION
export SAMTOOLS_HOME=/opt/samtools
export REGTOOLS_HOME=/opt/regtools
export PATH=\$CRAIG_HOME/bin:\$CRAIG_HOME/perl/bin:\$CRAIG_HOME/python/bin:\$REGTOOLS_HOME/build:\$SAMTOOLS_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$CRAIG_HOME/lib
EOF

if ! grep -q 'source .craig' /home/vagrant/.bashrc; then
  echo 'source .craig' >> /home/vagrant/.bashrc
fi

source /home/vagrant/.craig

WORKDIR=/tmp

yum install -y --disableplugin=fastestmirror epel-release && \
yum clean all
yum update -y --disableplugin=fastestmirror

yum install -y --disableplugin=fastestmirror \
  autoconf \
  automake \
  boost-regex \
  bzip2-devel \
  cmake \
  gcc \
  gcc-c++ \
  git \
  libtool \
  make \
  ncurses-devel \
  python2-pip \
  xz-devel \
  zlib-devel


echo "====== INSTALL SPARSEHASH ====="
cd $WORKDIR
if [[ -e sparsehash ]]; then
  pushd sparsehash
  git reset -- .
  git clean -f -x -d -- .
  git pull
  popd
else
  git clone https://github.com/sparsehash/sparsehash.git
fi

cd sparsehash && \
  ./configure && \
  make install

echo "====== INSTALL REGTOOLS ====="
# regtools
# https://regtools.readthedocs.io/en/latest/
if [[ -e $REGTOOLS_HOME ]]; then
  pushd $REGTOOLS_HOME
  git reset -- .
  git clean -f -x -d -- .
  git pull
  popd
else
  git clone https://github.com/griffithlab/regtools $REGTOOLS_HOME
fi
cd $REGTOOLS_HOME
mkdir build
cd build/
cmake ..
make

echo "====== INSTALL CRAIG ====="
cd $WORKDIR
if [[ -e CraiG ]]; then
  pushd CraiG
  git reset -- .
  git clean -f -x -d -- .
  git pull
  popd
else
  git clone https://github.com/axl-bernal/CraiG.git
fi

cd CraiG  && \
  ./autogen.sh  && \
  ./configure --prefix="$PREFIX_INSTALLATION" CXXFLAGS="$CXXFLAGS -std=c++11" --enable-opt=no --enable-mpi=no && \
  make && make install && make installcheck && \
  if [[ -f python/requirements.txt ]]; then pip install -r python/requirements.txt; fi

echo "====== INSTALL SAMTOOLS ====="
cd $WORKDIR
curl -LO https://gigenet.dl.sourceforge.net/project/samtools/samtools/1.7/samtools-1.7.tar.bz2
tar xf samtools-1.7.tar.bz2
pushd samtools-1.7
./configure --prefix=/opt/samtools
make
make install
popd

echo "====== INSTALL NUMPY ====="
pip install numpy
