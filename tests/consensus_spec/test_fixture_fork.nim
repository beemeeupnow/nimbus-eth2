# beacon_chain
# Copyright (c) 2021-2023 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at https://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at https://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

{.used.}

import
  # Beacon chain internals
  ../../beacon_chain/spec/beaconstate,
  ../../beacon_chain/spec/datatypes/phase0,
  # Test utilities
  ../testutil,
  ./fixtures_utils, ./os_ops,
  ../helpers/debug_state

proc runTest(
    BeaconStateAnte, BeaconStatePost: type, forkName, forkDir: static[string],
    upgrade_func: auto, suiteName, unitTestName: string) =
  let testDir = forkDir / unitTestName

  test "EF - " & forkName & " - Fork - " & unitTestName & preset():
    let
      preState = newClone(
        parseTest(testDir/"pre.ssz_snappy", SSZ, BeaconStateAnte))
      postState = newClone(
        parseTest(testDir/"post.ssz_snappy", SSZ, BeaconStatePost))

    var cfg = defaultRuntimeConfig
    when BeaconStateAnte is phase0.BeaconState:
      cfg.ALTAIR_FORK_EPOCH = preState[].slot.epoch

    let upgradedState = upgrade_func(cfg, preState[])
    check: upgradedState[].hash_tree_root() == postState[].hash_tree_root()
    reportDiff(upgradedState, postState)

from ../../beacon_chain/spec/datatypes/altair import BeaconState

suite "EF - Altair - Fork " & preset():
  const OpForkDir =
    SszTestsDir/const_preset/"altair"/"fork"/"fork"/"pyspec_tests"
  for kind, path in walkDir(OpForkDir, relative = true, checkDir = true):
    runTest(phase0.BeaconState, altair.BeaconState, "Altair", OpForkDir,
            upgrade_to_altair, suiteName, path)

from ../../beacon_chain/spec/datatypes/bellatrix import BeaconState

suite "EF - Bellatrix - Fork " & preset():
  const OpForkDir =
    SszTestsDir/const_preset/"bellatrix"/"fork"/"fork"/"pyspec_tests"
  for kind, path in walkDir(OpForkDir, relative = true, checkDir = true):
    runTest(altair.BeaconState, bellatrix.BeaconState, "Bellatrix", OpForkDir,
            upgrade_to_bellatrix, suiteName, path)

from ../../beacon_chain/spec/datatypes/capella import BeaconState

suite "EF - Capella - Fork " & preset():
  const OpForkDir =
    SszTestsDir/const_preset/"capella"/"fork"/"fork"/"pyspec_tests"
  for kind, path in walkDir(OpForkDir, relative = true, checkDir = true):
    runTest(bellatrix.BeaconState, capella.BeaconState, "Capella", OpForkDir,
            upgrade_to_capella, suiteName, path)

from ../../beacon_chain/spec/datatypes/deneb import BeaconState

suite "EF - Deneb - Fork " & preset():
  const OpForkDir =
    SszTestsDir/const_preset/"deneb"/"fork"/"fork"/"pyspec_tests"
  for kind, path in walkDir(OpForkDir, relative = true, checkDir = true):
    runTest(capella.BeaconState, deneb.BeaconState, "Deneb", OpForkDir,
            upgrade_to_deneb, suiteName, path)
