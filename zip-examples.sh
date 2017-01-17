#!/usr/bin/env bash

pushd src/main/resources/examples
ls -1 | grep "^.*zip$" |  xargs -I{} rm {}
ls -1 | xargs -I{} zip -r {}.zip {}
popd

pushd src/main/resources/invalid-examples
ls -1 | grep "^.*(zip|txt)$" |  xargs -I{} rm {}
ls -1 | xargs -I{} zip -r {}.zip {}
popd