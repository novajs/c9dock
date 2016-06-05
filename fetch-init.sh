#!/usr/bin/env bash

echo "fetching latest init script for runtime"
git clone https://github.com/novajs/INIT /root/.novajs/

echo "launching INIT"
pushd /root/.novajs
sh init.sh
popd

echo "NOTICE: INIT died."
exit 0
