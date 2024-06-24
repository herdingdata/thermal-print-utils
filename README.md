# Thermal print utils

[![Hippocratic License HL3-FULL](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-FULL&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/full.html)

A collection of bash scripts for printing stuff to a thermal printer.

Assumes you have the default printer set so that we can use `lp -s` to print.

Also assumes you have an 80mm receipt roll which can fit 28 characters.

_Important caveat: these are a collection of scripts which work for me.
There are parts which are kinda hardcoded to my particular setup.
I'm publishing them here in the hope that parts of these
scripts which can serve as inspiration for others.
They're not intended to be run verbatim._

I wrote a blog post to explain more about what this does and how to get it all up and running.
https://www.herdingdata.co.uk/calls-to-action-to-change-energy-habits-to-use-less-fossil-fuels-with-a-thermal-receipt-printer/
