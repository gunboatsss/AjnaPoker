// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.8.0 <0.9.0;

import {Mode} from "src/AjnaPoker.sol";
// import {console2} from "forge-std/Test.sol";

contract MockPool {
    // internal value of pool
    uint256 lastUpdate;
    uint256 interestRate_; // WAD
    uint256 debt_ = 0;
    Mode mode = Mode.NEUTRAL;

    function updateInterest() external {
        if (block.timestamp - lastUpdate > 12 hours || lastUpdate == 0) {
            if (mode == Mode.NEUTRAL) {} else if (mode == Mode.LENDER) {
                interestRate_ = interestRate_ * 10100 / 10000;
                lastUpdate = block.timestamp;
            } else {
                interestRate_ = interestRate_ - (interestRate_ * 100 / 10000);
                lastUpdate = block.timestamp;
            }
        }
    }

    function set(uint256 debt, uint256 interestRate, Mode _mode) external {
        debt_ = debt;
        interestRate_ = interestRate;
        mode = _mode;
    }

    function interestRateInfo() external view returns (uint256, uint256) {
        return (interestRate_, lastUpdate);
    }

    function debtInfo() external view returns (uint256, uint256, uint256, uint256) {
        return (debt_, 0, 0, 0);
    }
}
