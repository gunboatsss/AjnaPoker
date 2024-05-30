// SPDX-License-Identifier: MIT
import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";
import {IPool} from "./interfaces/IPool.sol";
import {IPoolLenderActions} from "./interfaces/IPoolLenderActions.sol";
import {IOpsProxy} from "./interfaces/IOpsProxy.sol";

pragma solidity >0.8.0 <0.9.0;

enum Mode {
    NEUTRAL,
    LENDER,
    BORROWER
}
/// @title AjnaPoker
/// @author GUNBOATs
/// @notice Gelato Solidity Web3Functions for updating interest rate
/// @dev All functions in this contract is intended to be simulated, not execute onchain.

contract AjnaPoker {
    function checkPool(address _pool) external returns (bool canExec, bytes memory data) {
        IPool pool = IPool(_pool);
        if (!_checkDebtExists(pool)) {
            return (false, "no debt in the pool");
        }
        (, int256 change, bool overTwelveHours) = _checkInterestRate(pool);
        if (!overTwelveHours) {
            return (false, "interest rate is updated < 12 hours ago");
        }
        if (change == 0) {
            return (false, "no change in interest rate");
        }
        return (true, abi.encodeCall(pool.updateInterest, ()));
    }

    function checkPoolWithParams(address _pool, uint256 _txGasPrice, Mode _mode, uint256 _targetRate)
        external
        returns (bool canExec, bytes memory data)
    {
        (canExec, data) = _checkPoolWithParams(_pool, _txGasPrice, _mode, _targetRate);
    }

    function checkPoolWithRateProvider(address _pool, uint256 _txGasPrice, Mode _mode, address _rateProvider)
        external
        returns (bool canExec, bytes memory data)
    {
        (, int256 answer,,,) = AggregatorV3Interface(_rateProvider).latestRoundData();
        // skip checking oracle staleness
        (canExec, data) = _checkPoolWithParams(_pool, _txGasPrice, _mode, uint256(answer));
    }

    function checkPools(address[] calldata _pools) external returns (bool canExec, bytes memory data) {
        uint256 length = _pools.length;
        uint256 counts = 0;
        address[] memory targets = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            IPool pool = IPool(_pools[i]);
            if (!_checkDebtExists(pool)) {
                continue;
            }
            (, int256 change, bool overTwelveHours) = _checkInterestRate(pool);
            if (!overTwelveHours) {
                continue;
            }
            if (change == 0) {
                continue;
            }
            targets[counts] = address(pool);
            counts += 1;
        }
        if (counts == 0) {
            return (false, "no pools to update");
        }
        assembly {
            mstore(targets, counts)
        }
        uint256[] memory values = new uint256[](counts);
        bytes[] memory payloads = new bytes[](counts);
        for (uint256 i = 0; i < counts; i++) {
            payloads[i] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        }
        canExec = true;
        data = abi.encodeCall(IOpsProxy.batchExecuteCall, (targets, payloads, values));
    }

    function checkPoolsWithParams(address[] calldata _pools, uint256 _txGasPrice, Mode _mode, uint256 _targetRate)
        external
        returns (bool canExec, bytes memory data)
    {
        (canExec, data) = _checkPoolsWithParams(_pools, _txGasPrice, _mode, _targetRate);
    }

    function checkPoolsWithRateProvider(
        address[] calldata _pools,
        uint256 _txGasPrice,
        Mode _mode,
        address _rateProvider
    ) external returns (bool canExec, bytes memory data) {
        (, int256 answer,,,) = AggregatorV3Interface(_rateProvider).latestRoundData();
        (canExec, data) = _checkPoolsWithParams(_pools, _txGasPrice, _mode, uint256(answer));
    }

    function _checkDebtExists(IPool _pool) internal view returns (bool) {
        (uint256 debt,,,) = _pool.debtInfo();
        return debt > 0;
    }

    function _checkInterestRate(IPool _pool)
        internal
        returns (uint256 initialRate, int256 change, bool overTwelveHours)
    {
        (uint256 interestRateBefore, uint256 interestRateTimestamp) = _pool.interestRateInfo();
        if (block.timestamp <= interestRateTimestamp + 12 hours) {
            return (interestRateBefore, 0, false);
        }
        _pool.updateInterest();
        (uint256 interestRateAfter,) = _pool.interestRateInfo();
        initialRate = interestRateBefore;
        change = int256(interestRateAfter) - int256(interestRateBefore);
        overTwelveHours = true;
    }

    function _checkPoolWithParams(address _pool, uint256 _txGasPrice, Mode _mode, uint256 _targetRate)
        internal
        returns (bool canExec, bytes memory data)
    {
        if (_mode == Mode.NEUTRAL && _targetRate > 0) {
            return (false, "invalid config");
        }
        if (tx.gasprice > _txGasPrice && _txGasPrice > 0) {
            return (false, "gas too high");
        }
        IPool pool = IPool(_pool);
        if (!_checkDebtExists(pool)) {
            return (false, "no debt in the pool");
        }
        (uint256 initialRate, int256 change, bool overTwelveHours) = _checkInterestRate(pool);
        if (!overTwelveHours) {
            return (false, "interest rate is updated < 12 hours ago");
        }
        if (_targetRate > 0) {
            if ((_mode == Mode.LENDER) && (initialRate > _targetRate)) {
                return (false, "LENDER: target rate reached");
            }
            if ((_mode == Mode.BORROWER) && (initialRate < _targetRate)) {
                return (false, "BORROWER: target rate reached");
            }
        }
        if (change == 0) {
            return (false, "no change in interest rate");
        }
        if (_mode == Mode.LENDER && change < 0) {
            return (false, "LENDER: interest rate decreased");
        }
        if (_mode == Mode.BORROWER && change > 0) {
            return (false, "BORROWER: interest rate increased");
        }
        return (true, abi.encodeCall(pool.updateInterest, ()));
    }

    function _checkPoolsWithParams(address[] memory _pools, uint256 _txGasPrice, Mode _mode, uint256 _targetRate)
        internal
        returns (bool canExec, bytes memory data)
    {
        if (_mode == Mode.NEUTRAL && _targetRate > 0) {
            return (false, "invalid config");
        }
        if (tx.gasprice > _txGasPrice && _txGasPrice > 0) {
            return (false, "gas too high");
        }
        uint256 length = _pools.length;
        uint256 counts = 0;
        address[] memory targets = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            IPool pool = IPool(_pools[i]);
            if (!_checkDebtExists(pool)) {
                continue;
            }
            (uint256 initialRate, int256 change, bool overTwelveHours) = _checkInterestRate(pool);
            if (!overTwelveHours) {
                continue;
            }
            if (_targetRate > 0) {
                if (_mode == Mode.LENDER && initialRate > _targetRate) {
                    continue;
                }
                if (_mode == Mode.BORROWER && initialRate < _targetRate) {
                    continue;
                }
            }
            if (change == 0) {
                continue;
            }
            if (_mode == Mode.LENDER && change < 0) {
                continue;
            }
            if (_mode == Mode.BORROWER && change > 0) {
                continue;
            }
            targets[counts] = address(pool);
            counts += 1;
        }
        if (counts == 0) {
            return (false, "no pools to update");
        }
        assembly {
            mstore(targets, counts)
        }
        uint256[] memory values = new uint256[](counts);
        bytes[] memory payloads = new bytes[](counts);
        for (uint256 i = 0; i < counts; i++) {
            payloads[i] = abi.encodeCall(IPoolLenderActions.updateInterest, ());
        }
        canExec = true;
        data = abi.encodeCall(IOpsProxy.batchExecuteCall, (targets, payloads, values));
    }
}
