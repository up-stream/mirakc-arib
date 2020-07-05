#!/bin/sh

set -u

MIRAKC_ARIB="$1"

export MIRAKC_ARIB_LOG=none

assert() {
  expected=$1
  cmd="$2"
  sh -c "$cmd </dev/null >/dev/null"
  actual=$?
  if [ $expected -eq $actual ]; then
    echo "PASS: $cmd"
  else
    echo "FAIL: $cmd: expectd($expected) actual($actual)"
    exit 1
  fi
}

for opt in '-h' '--help'
do
  assert 0 "$MIRAKC_ARIB $opt"
  for cmd in 'scan-services' 'sync-clocks' 'collect-eits' 'collect-logos' \
             'filter-service' 'filter-program' 'track-airtime' 'seek-start' \
             'print-timetable'
  do
    assert 0 "$MIRAKC_ARIB $cmd $opt"
  done
done

assert 0 "$MIRAKC_ARIB --version"

assert 1 "$MIRAKC_ARIB scan-services"
assert 1 "$MIRAKC_ARIB scan-services --sids=1 --sids=0xFFFF --xsids=1 --xsids=0xFFFF"

assert 1 "$MIRAKC_ARIB sync-clocks"
assert 1 "$MIRAKC_ARIB sync-clocks --sids=1 --sids=0xFFFF --xsids=1 --xsids=0xFFFF"

assert 1 "$MIRAKC_ARIB collect-eits"
assert 1 "$MIRAKC_ARIB collect-eits --sids=1 --sids=0xFFFF --xsids=1 --xsids=0xFFFF --time-limit=0x7FFFFFFFFFFFFFFF --streaming"
assert 134 "$MIRAKC_ARIB collect-eits --time-limit=0xFFFFFFFFFFFFFFFF"

assert 0 "$MIRAKC_ARIB filter-service --sid=1"
assert 0 "$MIRAKC_ARIB filter-service --sid=0xFFFF"

assert 0 "$MIRAKC_ARIB filter-program --sid=1 --eid=1 --clock-pcr=1 --clock-time=1"
assert 0 "$MIRAKC_ARIB filter-program --sid=0xFFFF --eid=0xFFFF --clock-pcr=0xFFFFFFFFFFFFFFFF --clock-time=-9223372036854775808 --start-margin=1 --end-margin=1 --pre-streaming"
assert 134 "$MIRAKC_ARIB filter-program --sid=1 --eid=1 --clock-pcr=0xFFFFFFFFFFFFFFFFF --clock-time=1"
assert 134 "$MIRAKC_ARIB filter-program --sid=1 --eid=1 --clock-pcr=1 --clock-time=-9223372036854775809"

assert 0 "$MIRAKC_ARIB track-airtime --sid=1 --eid=1"
assert 0 "$MIRAKC_ARIB track-airtime --sid=0xFFFF --eid=0xFFFF"

assert 0 "$MIRAKC_ARIB seek-start --sid=1 --max-duration=1"
assert 0 "$MIRAKC_ARIB seek-start --sid=0xFFFF --max-duration=0x7FFFFFFFFFFFFFFF --max-packets=0x7FFFFFFF"
assert 134 "$MIRAKC_ARIB seek-start --sid=0xFFFF --max-duration=0xFFFFFFFFFFFFFFFF --max-packets=0x7FFFFFFF"

assert 0 "$MIRAKC_ARIB print-timetable"
