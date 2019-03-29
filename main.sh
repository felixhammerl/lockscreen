#!/usr/bin/env bash
# shellcheck disable=1090

touch /Users/felixhammerl/projects/lockscreen/foo.bar

##!/usr/bin/env node

#'use strict'

#console.log('starting...')

#const path = require('path')
#const childProcess = require('child_process')
#const usb = require('usb')
#const { vid, pid } = require('./cfg.json')

#usb.on('detach', function ({ deviceDescriptor: { idVendor, idProduct } }) {
#  if (idVendor === vid && idProduct === pid) {
#    console.log('detach detected!')
#    childProcess.execFileSync(path.join(__dirname, 'lockscreen'))
#  }
#})

#console.log('started!')
