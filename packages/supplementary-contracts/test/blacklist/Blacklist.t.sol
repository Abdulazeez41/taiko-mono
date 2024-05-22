// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/src/Test.sol";
import "forge-std/src/console2.sol";

import "../../contracts/blacklist/Blacklist.sol";

contract TestBlacklist is Test {
    address private admin = vm.addr(0x1);
    address private updater = vm.addr(0x2);

    address private Alice = vm.addr(0x3);
    address private Bob = vm.addr(0x4);

    Blacklist private target;

    function setUp() public {
        address[] memory blacklist = new address[](1);
        blacklist[0] = Alice;

        target = new Blacklist(admin, updater, blacklist);
    }

    function test_not_blacklisted() public {
        bool isBlacklisted = target.isBlacklisted(Bob);
        assertTrue(!isBlacklisted);
    }

    function test_blacklisted() public {
        bool isBlacklisted = target.isBlacklisted(Alice);
        assertTrue(isBlacklisted);
    }

    function test_revert_addToBlacklist_notUpdater() public {
        address[] memory blacklist = new address[](1);
        blacklist[0] = Bob;
        vm.expectRevert("Must be updater");
        target.addToBlacklist(blacklist);
    }

    function test_addToBlacklist() public {
        vm.startBroadcast(updater);
        address[] memory blacklist = new address[](1);
        blacklist[0] = Bob;
        target.addToBlacklist(blacklist);
        bool isBlacklisted = target.isBlacklisted(Bob);
        assertTrue(isBlacklisted);
        vm.stopBroadcast();
    }

    function test_revert_removeFromBlacklist_notUpdater() public {
        address[] memory blacklist = new address[](1);
        blacklist[0] = Alice;
        vm.expectRevert("Must be updater");
        target.removeFromBlacklist(blacklist);
    }

    function test_removeFromBlacklist() public {
        vm.startBroadcast(updater);
        address[] memory blacklist = new address[](1);
        blacklist[0] = Alice;
        target.removeFromBlacklist(blacklist);
        bool isBlacklisted = target.isBlacklisted(Alice);
        assertTrue(!isBlacklisted);
        vm.stopBroadcast();
    }

    function test_updateBlacklist() public {
        vm.startBroadcast(updater);
        address[] memory addressesToAdd = new address[](1);
        addressesToAdd[0] = Bob;
        address[] memory addressesToRemove = new address[](1);
        addressesToRemove[0] = Alice;
        target.updateBlacklist(addressesToAdd, addressesToRemove);
        bool isBobBlacklisted = target.isBlacklisted(Bob);
        bool isAliceBlacklisted = target.isBlacklisted(Alice);
        assertTrue(isBobBlacklisted);
        assertTrue(!isAliceBlacklisted);
        vm.stopBroadcast();
    }

    function test_revert_addAddressAlreadyBlacklisted() public {
        vm.startBroadcast(updater);
        address[] memory blacklist = new address[](1);
        blacklist[0] = Alice;
        vm.expectRevert("Address already in blacklist");
        target.addToBlacklist(blacklist);
        vm.stopBroadcast();
    }
}
