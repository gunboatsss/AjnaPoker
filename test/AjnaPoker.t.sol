// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {AjnaPoker, Mode} from "src/AjnaPoker.sol";
import {MockPool} from "./mocks/MockPool.sol";
import {IPoolLenderActions} from "src/interfaces/IPoolLenderActions.sol";
import {AggregatorV3Interface} from "src/interfaces/AggregatorV3Interface.sol";
import {IOpsProxy} from "src/interfaces/IOpsProxy.sol";

contract AjnaPokerTest is Test {
    AjnaPoker public poker;
    AggregatorV3Interface public rateOracle = AggregatorV3Interface(addressFromString("Rate Oracle"));
    MockPool public pool;
    MockPool public pool2;
    MockPool public pool3;

    function setUp() public {
        vm.warp(1 hours);
        poker = new AjnaPoker();
        pool = new MockPool();
        pool2 = new MockPool();
        pool3 = new MockPool();
        console2.log("pool 1", address(pool));
        console2.log("pool 2", address(pool2));
        console2.log("pool 3", address(pool3));
        console2.log(int256(0.1e18));
        vm.mockCall(
            address(rateOracle),
            abi.encodeCall(AggregatorV3Interface.latestRoundData, ()),
            abi.encode(uint80(0), int256(0.1e18), uint256(0), uint256(0), uint80(0))
        );
    }

    function testUpdatePool() public {
        pool.set(1e18, 0.01e18, Mode.LENDER);
        vm.warp(block.timestamp + 12 hours + 1);
        (bool canExec, bytes memory output) = poker.checkPool(address(pool));
        assertEq(abi.encodeCall(pool.updateInterest, ()), output);
        assertTrue(canExec);
    }

    function test_notExecLessThan12Hour() public {
        pool.set(1e18, 0.01e18, Mode.LENDER);
        vm.warp(block.timestamp + 11 hours);
        (bool canExec, ) = poker.checkPool(address(pool));
        assertFalse(canExec);
    }

    function test_notChangingInterest() public {
        pool.set(1e18, 0.01e18, Mode.NEUTRAL);
        vm.warp(block.timestamp + 13 hours);
        (bool canExec, ) = poker.checkPool(address(pool));
        assertFalse(canExec);
    }

    function test_noDebt() public {
        pool.set(0, 0.01e18, Mode.LENDER);
        vm.warp(block.timestamp + 13 hours);
        (bool canExec, ) = poker.checkPool(address(pool));
        assertFalse(canExec);
    }

    function test_withParams() public {
        pool.set(1e18, 0.02e18, Mode.BORROWER);
        pool2.set(1e18, 0.02e18, Mode.LENDER);
        vm.warp(block.timestamp + 13 hours);
        vm.txGasPrice(1e9);
        (bool canExec, bytes memory output) = poker.checkPoolWithParams(
            address(pool),
            2e9,
            Mode.BORROWER,
            0
        );
        assertTrue(canExec);
        assertEq(abi.encodeCall(pool.updateInterest, ()), output);
        (canExec,output) = poker.checkPoolWithParams(
            address(pool2),
            0,
            Mode.LENDER,
            0
        );
        assertTrue(canExec);
        assertEq(abi.encodeCall(pool.updateInterest, ()), output);
    }

    function test_withRateProvider() public {
        pool.set(1e18, 0.11e18, Mode.BORROWER);
        pool2.set(1e18, 0.09e18, Mode.LENDER);
        vm.warp(block.timestamp + 13 hours);
        vm.txGasPrice(1e9);
        (bool canExec, bytes memory output) = poker.checkPoolWithRateProvider(
            address(pool),
            2e9,
            Mode.BORROWER,
            address(rateOracle)
        );
        assertTrue(canExec);
        assertEq(abi.encodeCall(pool.updateInterest, ()), output);
        (canExec, output) = poker.checkPoolWithRateProvider(
            address(pool2),
            0,
            Mode.LENDER,
            address(rateOracle)
        );
        assertTrue(canExec);
        assertEq(abi.encodeCall(pool.updateInterest, ()), output);
    }

    function test_notExecWithParams() public {
        pool.set(1e18, 0.11e18, Mode.LENDER);
        pool2.set(1e18, 0.11e18, Mode.BORROWER);
        pool3.set(0, 0.11e18, Mode.LENDER);
        vm.warp(block.timestamp + 6 hours);
        bool canExec;
        // NO DEBT
        (canExec,) = poker.checkPoolWithParams(
            address(pool3),
            0,
            Mode.LENDER,
            0
        );
        assertFalse(canExec);
        vm.warp(block.timestamp + 7 hours);
        uint256 snapshot = vm.snapshot();
        // BORROWER MODE
        (canExec, ) = poker.checkPoolWithParams(
            address(pool),
            0,
            Mode.BORROWER,
            0
        );
        assertFalse(canExec);
        // LENDER MODE
        (canExec, ) = poker.checkPoolWithParams(
            address(pool2),
            0,
            Mode.LENDER,
            0
        );
        assertFalse(canExec);
        vm.revertTo(snapshot);
        // LENDER HIGHER THAN RATE
        (canExec, ) = poker.checkPoolWithParams(
            address(pool),
            0,
            Mode.LENDER,
            0.1e18
        );
        assertFalse(canExec);
        // BORROWER LOWER THAN RATE
        pool2.set(1e18, 0.09e18, Mode.BORROWER);
        (canExec, ) = poker.checkPoolWithParams(
            address(pool),
            0,
            Mode.BORROWER,
            0.1e18
        );
        assertFalse(canExec);
        vm.revertTo(snapshot);
        vm.txGasPrice(2e9);
        pool3.set(1e18, 0.1e18, Mode.NEUTRAL);
        // NO CHANGE
        (canExec, ) = poker.checkPoolWithParams(
            address(pool3),
            0,
            Mode.LENDER,
            0
        );
        assertFalse(canExec);
        // GAS HIGHER THAN SET RATE
        (canExec, ) = poker.checkPoolWithParams(
            address(pool),
            1e9,
            Mode.LENDER,
            0
        );
        assertFalse(canExec);
        // INVALID CONFIG
        (canExec,) = poker.checkPoolWithParams(
            address(pool),
            0,
            Mode.NEUTRAL,
            0.1e18
        );
        assertFalse(canExec);
        // ZERO DEBT
        (canExec,) = poker.checkPoolWithParams(
            address(pool3),
            0,
            Mode.NEUTRAL,
            0
        );
        assertFalse(canExec);
    }

    function test_arrayOfPool() public {
        address[] memory pools = new address[](5);
        pools[0] = address(new MockPool());
        pools[1] = address(new MockPool());
        pools[2] = address(new MockPool());
        pools[3] = address(new MockPool());
        pools[4] = address(new MockPool());
        MockPool(pools[0]).set(1e18, 0.01e18, Mode.LENDER);
        MockPool(pools[1]).set(0, 0.01e18, Mode.BORROWER);
        MockPool(pools[2]).set(1e18, 0.01e18, Mode.NEUTRAL);
        MockPool(pools[3]).set(1e18, 0.01e18, Mode.BORROWER);
        console2.log(block.timestamp);
        vm.warp(block.timestamp + 7 hours);
        MockPool(pools[4]).set(1e18, 0.01e18, Mode.LENDER);
        MockPool(pools[4]).updateInterest();
        vm.warp(block.timestamp + 6 hours);
        uint256 snapshot = vm.snapshot();
        (bool canExec, bytes memory output) = poker.checkPools(pools);
        address[] memory expectedAddress = new address[](2);
        expectedAddress[0] = pools[0];
        expectedAddress[1] = pools[3];
        bytes[] memory expectedDatas = new bytes[](2);
        expectedDatas[0] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        expectedDatas[1] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        uint256[] memory expectedValues = new uint256[](2);
        assertTrue(canExec);
        assertEq(output, abi.encodeCall(
            IOpsProxy.batchExecuteCall,
            (
                expectedAddress,
                expectedDatas,
                expectedValues
            )
        ));
        vm.revertTo(snapshot);
        address[] memory another = new address[](2);
        another[0] = pools[2];
        another[1] = pools[1];
        (canExec,) = poker.checkPools(another);
        assertFalse(canExec);
    }

    function test_arrayWithParams() public {
        address[] memory pools = new address[](5);
        pools[0] = address(new MockPool());
        pools[1] = address(new MockPool());
        pools[2] = address(new MockPool());
        pools[3] = address(new MockPool());
        pools[4] = address(new MockPool());
        MockPool(pools[0]).set(1e18, 0.01e18, Mode.LENDER);
        MockPool(pools[1]).set(0, 0.01e18, Mode.BORROWER);
        MockPool(pools[2]).set(1e18, 0.01e18, Mode.NEUTRAL);
        MockPool(pools[3]).set(1e18, 0.01e18, Mode.BORROWER);
        vm.warp(block.timestamp + 13 hours);
        uint256 snapshot = vm.snapshot();
        vm.txGasPrice(1e9);
        bool canExec;
        bytes memory output;
        (canExec, ) = poker.checkPoolsWithParams(
            pools,
            2e9,
            Mode.NEUTRAL,
            0
        );
        assertTrue(canExec);
        vm.revertTo(snapshot);
        (canExec, ) = poker.checkPoolsWithParams(
            pools,
            0.5e9,
            Mode.NEUTRAL,
            0
        );
        assertFalse(canExec);
        vm.revertTo(snapshot);
        (canExec, output) = poker.checkPoolsWithParams(
            pools,
            0,
            Mode.LENDER,
            0
        );
        assertTrue(canExec);
        address[] memory expectedAddress = new address[](1);
        bytes[] memory expectedData = new bytes[](1);
        uint256[] memory expectedValue = new uint256[](1);
        expectedAddress[0] = pools[0];
        expectedData[0] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        assertEq(
            output,
            abi.encodeCall(
                IOpsProxy.batchExecuteCall,
                (
                    expectedAddress,
                    expectedData,
                    expectedValue
                )
            )
        );
        assertTrue(canExec);
        vm.revertTo(snapshot);
        (canExec, output) = poker.checkPoolsWithParams(pools, 0, Mode.BORROWER, 0);
        assertTrue(canExec);
        expectedAddress[0] = pools[3];
        assertEq(
            output,
            abi.encodeCall(
                IOpsProxy.batchExecuteCall,
                (
                    expectedAddress,
                    expectedData,
                    expectedValue
                )
            )
        );
        vm.revertTo(snapshot);
        address[] memory noPools = new address[](3);
        noPools[0] = pools[1];
        noPools[1] = pools[2];
        noPools[2] = pools[3];
        (canExec, ) = poker.checkPoolsWithParams(
            noPools,
            0,
            Mode.LENDER,
            0
        );
        assertFalse(canExec);
    }

    function test_arrayWithRateProvider() public {
        pool.set(1e18, 0.11e18, Mode.BORROWER);
        pool2.set(1e18, 0.09e18, Mode.LENDER);
        vm.warp(block.timestamp + 13 hours);
        address[] memory check = new address[](2);
        check[0] = address(pool);
        check[1] = address(pool2);
        (bool canExec, bytes memory output) = poker.checkPoolsWithRateProvider(
            check,
            0,
            Mode.BORROWER,
            address(rateOracle)
        );
        address[] memory expectedAddress = new address[](1);
        bytes[] memory expectedData = new bytes[](1);
        uint256[] memory expectedValue = new uint256[](1);
        expectedAddress[0] = address(pool);
        expectedData[0] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        assertTrue(canExec);
        assertEq(output, abi.encodeCall(
            IOpsProxy.batchExecuteCall,
            (expectedAddress, expectedData, expectedValue)
        ));
    }

    function addressFromString(string memory s) internal pure returns (address) {
        return address(uint160(uint256(keccak256(bytes(s)))));
    }
}
