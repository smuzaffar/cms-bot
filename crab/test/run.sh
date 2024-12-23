#!/bin/bash
log="$CMSSW_BASE/run.log"
(
set -x
ld.so --help | grep supported | grep x86-64-v
pushd $CMSSW_BASE
  scram b clean
  scram build enable-multi-targets
  eval `scram run -sh`
  export LD_LIBRARY_PATH=".:${LD_LIBRARY_PATH}"
  echo "$PATH" | tr ':' '\n'
  echo "$LD_LIBRARY_PATH" | tr ':' '\n'
  which edmWriteConfigs
  mkdir x
  pushd x
    lib="$CMSSW_RELEASE_BASE/lib/${SCRAM_ARCH}/pluginAlignmentCommonAlignmentAuto.so"
    edmWriteConfigs -p ${lib} || true
    ls
    rm *.py || true
    lib="$CMSSW_RELEASE_BASE/lib/${SCRAM_ARCH}/scram_x86-64-v2/pluginAlignmentCommonAlignmentAuto.so"
    edmWriteConfigs -p ${lib}
    ls
  popd
  rm -rf x
  script="$CMSSW_RELEASE_BASE/src/FWCore/Reflection/scripts/edmCheckClassVersion"
  xml="$CMSSW_RELEASE_BASE/src/DataFormats/HGCDigi/src/classes_def.xml"
  $script -l libDataFormatsHGCDigi.so -x $xml
  pushd $CMSSW_RELEASE_BASE/lib/${SCRAM_ARCH}
    $script -l libDataFormatsHGCDigi.so -x $xml
    $script -l $CMSSW_RELEASE_BASE/lib/${SCRAM_ARCH}/libDataFormatsHGCDigi.so -x $xml
  popd
  pushd $CMSSW_RELEASE_BASE/lib/${SCRAM_ARCH}/scram_x86-64-v2
    $script -l libDataFormatsHGCDigi.so -x $xml    
    $script -l $CMSSW_RELEASE_BASE/lib/${SCRAM_ARCH}/scram_x86-64-v2/libDataFormatsHGCDigi.so -x $xml
  popd
popd ) >>${log} 2>&1 || true
mv $log .
