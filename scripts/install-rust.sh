#!/usr/bin/env bash
workspace=$HOME/workspace

mkdir -p $workspace &&
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o $workspace/rust-setup.sh &&
chmod a+x $workspace/rust-setup.sh &&
$workspace/rust-setup.sh -y && 
rm $workspace/rust-setup.sh &&
source $HOME/.cargo/env &&
rustup default nightly