// SPDX-License-Identifier: MIT
pragma solidity =0.8.23;

import {IPoolLenderActions} from "./IPoolLenderActions.sol";
import {IPoolState} from "./IPoolState.sol";

interface IPool is IPoolLenderActions, IPoolState {}
