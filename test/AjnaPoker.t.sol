// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {AjnaPoker} from "../src/AjnaPoker.sol";
import {MockPool} from "./mocks/MockPool.sol";
import {IPoolLenderActions} from "../src/interfaces/IPoolLenderActions.sol";
import {IOpsProxy} from "../src/interfaces/IOpsProxy.sol";

contract AjnaPokerTest is Test {
    AjnaPoker public poker;
    MockPool public pool;
    MockPool public pool2;
    MockPool public pool3;

    function setUp() public {
        vm.warp(1 hours);
        poker = new AjnaPoker();
        pool = new MockPool();
        pool2 = new MockPool();
        pool3 = new MockPool();
    }

    function test_checker() public {
        console2.log("time before", block.timestamp);
        pool.updateInterest();
        vm.warp(block.timestamp + 14 hours);
        console2.log("time after", block.timestamp);
        (bool shouldExec, bytes memory data) = poker.checker(address(pool));
        assertTrue(shouldExec, "fail to check");
        assertEq(data, abi.encodeWithSelector(IPoolLenderActions.updateInterest.selector));
        (bool succ,) = address(pool).call(data);
        assertTrue(succ, "fail to update");
    }

    function test_checkers_not_12_hours() public {
        pool.updateInterest();
        vm.warp(block.timestamp + 6 hours);
        (bool shouldExec,) = poker.checker(address(pool));
        assertFalse(shouldExec, "shouldn't execute");
    }

    function test_checkerWithGasPrice() public {
        vm.txGasPrice(2 gwei);
        pool.updateInterest();
        vm.warp(block.timestamp + 13 hours);
        (bool shouldExec, bytes memory data) = poker.checkerWithTxPrice(address(pool), 3 gwei);
        assertTrue(shouldExec, "fail to check");
        assertEq(data, abi.encodeWithSelector(IPoolLenderActions.updateInterest.selector));
    }

    function test_checkerWithGasPriceTooHigh() public {
        vm.txGasPrice(50 gwei);
        pool.updateInterest();
        vm.warp(block.timestamp + 13 hours);
        (bool shouldExec, ) = poker.checkerWithTxPrice(address(pool), 3 gwei);
        assertFalse(shouldExec, "gas check failed");
    }

    function test_checkerWithGasPrice_not_12_hours() public {
        vm.txGasPrice(2 gwei);
        pool.updateInterest();
        vm.warp(block.timestamp + 6 hours);
        (bool shouldExec,) = poker.checkerWithTxPrice(address(pool), 3 gwei);
        assertFalse(shouldExec, "shouldn't execute");
    }

    function test_checkers_array() public {
        pool.updateInterest();
        pool3.updateInterest();
        vm.warp(block.timestamp + 6 hours);
        pool2.updateInterest();
        vm.warp(block.timestamp + 7 hours);
        address[] memory pools = new address[](3);
        pools[0] = address(pool);
        pools[1] = address(pool2);
        pools[2] = address(pool3);
        address[] memory results = new address[](2);
        results[0] = address(pool);
        results[1] = address(pool3);
        bytes[] memory payload_res = new bytes[](2);
        payload_res[0] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        payload_res[1] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        uint256[] memory values = new uint256[](2);
        (bool shouldExec, bytes memory payload) = poker.checker(pools);
        assertTrue(shouldExec, "can't execute");
        assertEq(
            payload,
            abi.encodeCall(
                IOpsProxy.batchExecuteCall,
                (
                    results, payload_res, values
                )
            )
            );
        (,uint256 before) = pool.inflatorInfo();
        (bool succ,) = address(pool).call(payload_res[0]);
        assertTrue(succ, "call failed");
        (,uint256 _after) = pool.inflatorInfo();
        assertTrue(_after > before);
    }

    function test_array_no_pool() public {
        pool.updateInterest();
        pool3.updateInterest();
        vm.warp(block.timestamp + 6 hours);
        address[] memory pools = new address[](2);
        pools[0] = address(pool);
        pools[1] = address(pool2);
        (bool shouldExec, ) = poker.checker(pools);
        assertFalse(shouldExec);
    }

    function test_checkers_array_with_tx_price() public {
        vm.txGasPrice(3 gwei);
        pool.updateInterest();
        pool3.updateInterest();
        vm.warp(block.timestamp + 6 hours);
        pool2.updateInterest();
        vm.warp(block.timestamp + 7 hours);
        address[] memory pools = new address[](3);
        pools[0] = address(pool);
        pools[1] = address(pool2);
        pools[2] = address(pool3);
        address[] memory results = new address[](2);
        results[0] = address(pool);
        results[1] = address(pool3);
        bytes[] memory payload_res = new bytes[](2);
        payload_res[0] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        payload_res[1] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        uint256[] memory values = new uint256[](2);
        (bool shouldExec, bytes memory payload) = poker.checkerWithTxPrice(pools, 4 gwei);
        assertTrue(shouldExec, "can't execute");
        assertEq(
            payload,
            abi.encodeCall(
                IOpsProxy.batchExecuteCall,
                (
                    results, payload_res, values
                )
            )
            );
        (,uint256 before) = pool.inflatorInfo();
        (bool succ,) = address(pool).call(payload_res[0]);
        assertTrue(succ, "call failed");
        (,uint256 _after) = pool.inflatorInfo();
        assertTrue(_after > before);
    }

    function test_checkers_array_gas_too_high() public {
        vm.txGasPrice(3 gwei);
        address[] memory pools = new address[](3);
        pools[0] = address(pool);
        pools[1] = address(pool2);
        pools[2] = address(pool3);
        (bool shouldExec, ) = poker.checkerWithTxPrice(pools, 2 gwei);
        assertFalse(shouldExec);
    }
}
