#!/bin/sh

npm install @observablehq/runtime
npm install @observablehq/stdlib
npm install @observablehq/inspector

curl https://raw.githubusercontent.com/observablehq/inspector/main/src/style.css -o srcjs/widgets/inspector.css

R -e 'packer::bundle_prod()'

exit 0