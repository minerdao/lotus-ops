#!/usr/bin/env bash
env CGO_CFLAGS_ALLOW="-D__BLST_PORTABLE__" RUSTFLAGS="-C target-cpu=native -g" FFI_BUILD_FROM_SOURCE=1 CGO_CFLAGS="-D__BLST_PORTABLE__" make clean all lotus-bench lotus-shed
sudo make install

lotus -v
lotus-miner -v
