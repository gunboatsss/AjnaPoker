// SPDX-License-Identifier: MIT
import {IPool} from "./interfaces/IPool.sol";
import {IPoolLenderActions} from "./interfaces/IPoolLenderActions.sol";
import {IOpsProxy} from "./interfaces/IOpsProxy.sol";

pragma solidity 0.8.23;

contract AjnaPoker {
    /// @notice internal function of checker
    /// @param _pool Address of pool, this is unchecked by contract!
    /// @return canExec tell Gelato to execute or not
    /// @return data calldata to execute
    function _checker(address _pool) internal returns (bool canExec, bytes memory data) {
        IPool pool = IPool(_pool);
        (uint256 debt_,,,) = pool.debtInfo();
        if (debt_ == 0) {
            return (false, "unused pool");
        }
        (uint256 interestRateBefore ,uint256 interestRateTimestamp) = pool.interestRateInfo();
        if (block.timestamp > interestRateTimestamp + 12 hours) {
            pool.updateInterest();
            (uint256 interestRateAfter,) = pool.interestRateInfo();
            if(interestRateBefore != interestRateAfter) {
                return (true, abi.encodeCall(pool.updateInterest, ()));
            }
            else {
                return (false, "no change in interest rate");
            }
        } else {
            return (false, "Pool is poked <12 hours ago");
        }
    }

    /// @notice check pool to see if it's more than 12 hours since last poke
    /// @dev the contract doesn't check to see if it's valid pool, at worst it gonna drain your gelato balance
    /// @param _pool Address of pool, this is unchecked by contract!
    /// @return canExec tell Gelato to execute or not
    /// @return data calldata to execute
    function checker(address _pool) public returns (bool canExec, bytes memory data) {
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
    function _checker(address[] memory _pools) internal returns (bool canExec, bytes memory data) {
        uint256 length = _pools.length;
        uint256 counts = 0;
        address[] memory targets = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            address pool = _pools[i];
            (uint256 debt_,,,) = IPool(pool).debtInfo();
            if (debt_ == 0) {
                continue;
            }
            (uint256 interestRateBefore ,uint256 interestRateTimestamp) = IPool(pool).interestRateInfo();
            if (block.timestamp > interestRateTimestamp + 12 hours) {
                IPool(pool).updateInterest();
                (uint256 interestRateAfter,) = IPool(pool).interestRateInfo();
                if(interestRateBefore != interestRateAfter) {
                    targets[counts] = _pools[i];
                    counts += 1;
                }
                else {
                    continue;
                }
            }
            else {
                continue;
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
    function checker(address[] calldata _pools) external returns (bool canExec, bytes memory data) {
        (canExec, data) = _checker(_pools);
    }

    /// @notice external function of checkers with array of pools
    /// @param _pools an array of pools address
    /// @param _txPrice gas price threshold
    /// @return canExec tell gelato to execute
    /// @return data calldata to execute (batchExecuteCall(address[],bytes[] memory,uint256[]))
    function checkerWithTxPrice(address[] calldata _pools, uint256 _txPrice)
        external
        returns (bool canExec, bytes memory data)
    {
        if (tx.gasprice > _txPrice) {
            return (false, "gas too high");
        }
        (canExec, data) = _checker(_pools);
    }
}
