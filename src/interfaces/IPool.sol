// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <0.9.0;

import {IPoolLenderActions} from "./IPoolLenderActions.sol";
import {IPoolState} from "./IPoolState.sol";

interface IPool is IPoolLenderActions, IPoolState {}
