#!/bin/sh

mv runtime.umd.js runtime.umd.js.old
curl -O https://cdn.jsdelivr.net/npm/@observablehq/runtime@4/dist/runtime.umd.js

exit 0