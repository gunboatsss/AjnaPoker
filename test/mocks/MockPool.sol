// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.23;
import {console2} from "forge-std/Test.sol";

contract MockPool {

    // internal value of pool
    uint256 inflator = 1e18;
    uint256 lastUpdate;
    uint256 debt_ = 0;

    // mocking EMA used for TU and MAU
    uint256 debtEma_;
    uint256 depositEma_;
    uint256 debtColEma_;
    uint256 lupt0DebtEma_;

    function inflatorInfo() external view returns (uint256, uint256) {
        return (inflator, lastUpdate);
    }

    function updateInterest() external {
        if (block.timestamp - lastUpdate > 12 hours || lastUpdate == 0) {
            lastUpdate = block.timestamp;
            console2.log("mockpool", lastUpdate);
        }
    }

    function setDebt_(uint256 _debt) external {
        debt_ = _debt;
    }

    function setEMA(uint256 _debtEma, uint256 _depositEma, uint256 _debtColEma, uint256 _luptoDebtEma) external {
        debtEma_ = _debtEma;
        depositEma_ = _depositEma;
        debtColEma_ = _debtColEma;
        lupt0DebtEma_ = _luptoDebtEma;
    }

    function emasInfo()
        external
        view
        returns (uint256 debtColEma, uint256 lupt0DebtEma, uint256 debtEma, uint256 depositEma) {
            return (debtColEma_, lupt0DebtEma_, debtEma_, depositEma_);
        }

    function debtInfo() external view returns (uint256,uint256,uint256,uint256) {
        return (debt_, 0, 0, 0);
    }
}
