// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

interface IOpsProxy {
    function batchExecuteCall(address[] calldata targets, bytes[] calldata datas, uint256[] calldata values)
        external
        payable;
}
