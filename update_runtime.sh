#!/bin/sh

npm install @observablehq/runtime
npm install @observablehq/stdlib
npm install @observablehq/inspector

R -e 'packer::bundle_prod()'

exit 0