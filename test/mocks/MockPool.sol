// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.23;
import {console2} from "forge-std/Test.sol";

contract MockPool {
    uint256 inflator = 1e18;
    uint256 lastUpdate;

    function inflatorInfo() external view returns (uint256, uint256) {
        return (inflator, lastUpdate);
    }

    function updateInterest() external {
        if (block.timestamp - lastUpdate > 12 hours || lastUpdate == 0) {
            lastUpdate = block.timestamp;
            console2.log("mockpool", lastUpdate);
        }
    }
}
