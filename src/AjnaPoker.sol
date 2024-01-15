// SPDX-License-Identifier: MIT
import {IPool} from "./interfaces/IPool.sol";
import {IPoolLenderActions} from "./interfaces/IPoolLenderActions.sol";
import {IOpsProxy} from "./interfaces/IOpsProxy.sol";
import {Maths} from "./libraries/Maths.sol";

import {console2} from "forge-std/Test.sol";

pragma solidity 0.8.23;

contract AjnaPoker {
    /// @notice internal function of checker
    /// @param _pool Address of pool, this is unchecked by contract!
    /// @return canExec tell Gelato to execute or not
    /// @return data calldata to execute
    function _checker(address _pool) internal view returns (bool canExec, bytes memory data) {
        IPool pool = IPool(_pool);
        (uint256 debt_,,,) = pool.debtInfo();
        if (debt_ == 0) {
            return (false, "unused pool");
        }
        (uint256 debtColEma_, uint256 lupt0DebtEma_, uint256 debtEma_, uint256 depositEma_) = pool.emasInfo();
        if (depositEma_ == 0) {
            return (false, "depositEma_ is 0");
        }
        int256 mau = int256(Maths.wdiv(debtEma_, depositEma_));
        int256 mau102 = mau * 1.02e18 / 1e18;

        int256 tu = (lupt0DebtEma_ != 0) ? int256(Maths.wdiv(debtColEma_, lupt0DebtEma_)) : int256(1e18);
        if (
            // check if interest rate is changing
            !
            (
                (4 * (tu - mau102) < (((tu + mau102 - 1e18) / 1e9) ** 2) - 1e18)
                    || (4 * (tu - mau) > 1e18 - ((tu + mau - 1e18) / 1e9) ** 2)
            )
        ) {
            return (false, "interest rate not changing");
        }
        (, uint256 inflatorUpdate) = pool.inflatorInfo();
        if (block.timestamp > inflatorUpdate + 12 hours) {
            return (true, abi.encodeCall(pool.updateInterest, ()));
        } else {
            return (false, "Pool is poked <12 hours ago");
        }
    }

    /// @notice check pool to see if it's more than 12 hours since last poke
    /// @dev the contract doesn't check to see if it's valid pool, at worst it gonna drain your gelato balance
    /// @param _pool Address of pool, this is unchecked by contract!
    /// @return canExec tell Gelato to execute or not
    /// @return data calldata to execute
    function checker(address _pool) public view returns (bool canExec, bytes memory data) {
        (canExec, data) = _checker(_pool);
    }

    /// @notice check pool to see if it's more than 12 hours since last poke
    /// @dev the contract doesn't check to see if it's valid pool, at worst it gonna drain your gelato balance
    /// @param _pool Address of pool, this is unchecked by contract!
    /// @param _txPrice gas price threshold
    /// @return canExec tell Gelato to execute or not
    /// @return data calldata to execute
    function checkerWithTxPrice(address _pool, uint256 _txPrice)
        public
        view
        returns (bool canExec, bytes memory data)
    {
        if (tx.gasprice > _txPrice) {
            return (false, "gas too high");
        }
        (canExec, data) = _checker(_pool);
    }

    /// @notice internal function of checkers with array of pools
    /// @param _pools an array of pools address
    /// @return canExec tell gelato to execute
    /// @return data calldata to execute (batchExecuteCall(address[],bytes[] memory,uint256[]))
    function _checker(address[] memory _pools) internal view returns (bool canExec, bytes memory data) {
        uint256 length = _pools.length;
        uint256 counts = 0;
        address[] memory targets = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            address pool = _pools[i];
            (uint256 debt_,,,) = IPool(pool).debtInfo();
            if (debt_ == 0) {
                continue;
            }
            (uint256 debtColEma_, uint256 lupt0DebtEma_, uint256 debtEma_, uint256 depositEma_) = IPool(pool).emasInfo();
            if (depositEma_ == 0) {
                continue;
            }
            int256 mau = int256(Maths.wdiv(debtEma_, depositEma_));
            int256 mau102 = mau * 1.02e18 / 1e18;

            int256 tu = (lupt0DebtEma_ != 0) ? int256(Maths.wdiv(debtColEma_, lupt0DebtEma_)) : int256(1e18);
            if (
                // check if interest rate is changing
                !
                (
                    (4 * (tu - mau102) < (((tu + mau102 - 1e18) / 1e9) ** 2) - 1e18)
                        || (4 * (tu - mau) > 1e18 - ((tu + mau - 1e18) / 1e9) ** 2)
                )
            ) {
                continue;
            }
            (, uint256 inflatorUpdate) = IPool(pool).inflatorInfo();
            if (block.timestamp > inflatorUpdate + 12 hours) {
                targets[counts] = _pools[i];
                counts += 1;
            }
        }
        if (counts == 0) {
            return (false, "no pools need to poke");
        }
        assembly {
            mstore(targets, counts)
        }
        uint256[] memory values = new uint256[](counts);
        bytes[] memory payloads = new bytes[](counts);
        for (uint256 i = 0; i < counts; i++) {
            // values[i] = 0;
            payloads[i] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        }
        canExec = true;
        data = abi.encodeCall(IOpsProxy.batchExecuteCall, (targets, payloads, values));
    }

    /// @notice external function of checkers with array of pools
    /// @param _pools an array of pools address
    /// @return canExec tell gelato to execute
    /// @return data calldata to execute (batchExecuteCall(address[],bytes[] memory,uint256[]))
    function checker(address[] calldata _pools) external view returns (bool canExec, bytes memory data) {
        (canExec, data) = _checker(_pools);
    }

    /// @notice external function of checkers with array of pools
    /// @param _pools an array of pools address
    /// @param _txPrice gas price threshold
    /// @return canExec tell gelato to execute
    /// @return data calldata to execute (batchExecuteCall(address[],bytes[] memory,uint256[]))
    function checkerWithTxPrice(address[] calldata _pools, uint256 _txPrice)
        external
        view
        returns (bool canExec, bytes memory data)
    {
        if (tx.gasprice > _txPrice) {
            return (false, "gas too high");
        }
        (canExec, data) = _checker(_pools);
    }
}
