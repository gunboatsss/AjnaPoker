# AjnaPoker

## Functions
### _checker

internal function of checker


```solidity
function _checker(address _pool) internal view returns (bool canExec, bytes memory data);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Address of pool, this is unchecked by contract!|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`canExec`|`bool`|tell Gelato to execute or not|
|`data`|`bytes`|calldata to execute|


### checker

check pool to see if it's more than 12 hours since last poke

*the contract doesn't check to see if it's valid pool, at worst it gonna drain your gelato balance*


```solidity
function checker(address _pool) public view returns (bool canExec, bytes memory data);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Address of pool, this is unchecked by contract!|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`canExec`|`bool`|tell Gelato to execute or not|
|`data`|`bytes`|calldata to execute|


### checkerWithTxPrice

check pool to see if it's more than 12 hours since last poke

*the contract doesn't check to see if it's valid pool, at worst it gonna drain your gelato balance*


```solidity
function checkerWithTxPrice(address _pool, uint256 _txPrice) public view returns (bool canExec, bytes memory data);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pool`|`address`|Address of pool, this is unchecked by contract!|
|`_txPrice`|`uint256`|gas price threshold|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`canExec`|`bool`|tell Gelato to execute or not|
|`data`|`bytes`|calldata to execute|


### _checker

internal function of checkers with array of pools


```solidity
function _checker(address[] memory _pools) internal view returns (bool canExec, bytes memory data);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pools`|`address[]`|an array of pools address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`canExec`|`bool`|tell gelato to execute|
|`data`|`bytes`|calldata to execute (batchExecuteCall(address[],bytes[] memory,uint256[]))|


### checker

external function of checkers with array of pools


```solidity
function checker(address[] calldata _pools) external view returns (bool canExec, bytes memory data);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pools`|`address[]`|an array of pools address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`canExec`|`bool`|tell gelato to execute|
|`data`|`bytes`|calldata to execute (batchExecuteCall(address[],bytes[] memory,uint256[]))|


### checkerWithTxPrice

external function of checkers with array of pools


```solidity
function checkerWithTxPrice(address[] calldata _pools, uint256 _txPrice)
    external
    view
    returns (bool canExec, bytes memory data);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pools`|`address[]`|an array of pools address|
|`_txPrice`|`uint256`|gas price threshold|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`canExec`|`bool`|tell gelato to execute|
|`data`|`bytes`|calldata to execute (batchExecuteCall(address[],bytes[] memory,uint256[]))|


