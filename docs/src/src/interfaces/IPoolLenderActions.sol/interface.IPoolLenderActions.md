# IPoolLenderActions

## Functions
### addQuoteToken

Called by lenders to add an amount of credit at a specified price bucket.


```solidity
function addQuoteToken(uint256 amount_, uint256 index_, uint256 expiry_)
    external
    returns (uint256 bucketLP_, uint256 addedAmount_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount_`|`uint256`|          The amount of quote token to be added by a lender (`WAD` precision).|
|`index_`|`uint256`|           The index of the bucket to which the quote tokens will be added.|
|`expiry_`|`uint256`|          Timestamp after which this transaction will revert, preventing inclusion in a block with unfavorable price.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`bucketLP_`|`uint256`|        The amount of `LP` changed for the added quote tokens (`WAD` precision).|
|`addedAmount_`|`uint256`|     The amount of quote token added (`WAD` precision).|


### moveQuoteToken

Called by lenders to move an amount of credit from a specified price bucket to another specified price bucket.


```solidity
function moveQuoteToken(uint256 maxAmount_, uint256 fromIndex_, uint256 toIndex_, uint256 expiry_)
    external
    returns (uint256 fromBucketLP_, uint256 toBucketLP_, uint256 movedAmount_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxAmount_`|`uint256`|       The maximum amount of quote token to be moved by a lender (`WAD` precision).|
|`fromIndex_`|`uint256`|       The bucket index from which the quote tokens will be removed.|
|`toIndex_`|`uint256`|         The bucket index to which the quote tokens will be added.|
|`expiry_`|`uint256`|          Timestamp after which this transaction will revert, preventing inclusion in a block with unfavorable price.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`fromBucketLP_`|`uint256`|    The amount of `LP` moved out from bucket (`WAD` precision).|
|`toBucketLP_`|`uint256`|      The amount of `LP` moved to destination bucket (`WAD` precision).|
|`movedAmount_`|`uint256`|     The amount of quote token moved (`WAD` precision).|


### removeCollateral

Called by lenders to claim collateral from a price bucket.


```solidity
function removeCollateral(uint256 maxAmount_, uint256 index_)
    external
    returns (uint256 removedAmount_, uint256 redeemedLP_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxAmount_`|`uint256`|    The amount of collateral (`WAD` precision for `ERC20` pools, number of `NFT` tokens for `ERC721` pools) to claim.|
|`index_`|`uint256`|        The bucket index from which collateral will be removed.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`removedAmount_`|`uint256`|The amount of collateral removed (`WAD` precision).|
|`redeemedLP_`|`uint256`|   The amount of `LP` used for removing collateral amount (`WAD` precision).|


### removeQuoteToken

Called by lenders to remove an amount of credit at a specified price bucket.


```solidity
function removeQuoteToken(uint256 maxAmount_, uint256 index_)
    external
    returns (uint256 removedAmount_, uint256 redeemedLP_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxAmount_`|`uint256`|    The max amount of quote token to be removed by a lender (`WAD` precision).|
|`index_`|`uint256`|        The bucket index from which quote tokens will be removed.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`removedAmount_`|`uint256`|The amount of quote token removed (`WAD` precision).|
|`redeemedLP_`|`uint256`|   The amount of `LP` used for removing quote tokens amount (`WAD` precision).|


### updateInterest

Called by actors to update pool interest rate (can be updated only once in a `12` hours period of time).


```solidity
function updateInterest() external;
```

