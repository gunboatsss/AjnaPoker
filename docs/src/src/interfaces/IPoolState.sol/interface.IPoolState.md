# IPoolState

## Functions
### auctionInfo

Returns details of an auction for a given borrower address.


```solidity
function auctionInfo(address borrower_)
    external
    view
    returns (
        address kicker_,
        uint256 bondFactor_,
        uint256 bondSize_,
        uint256 kickTime_,
        uint256 referencePrice_,
        uint256 neutralPrice_,
        uint256 debtToCollateral_,
        address head_,
        address next_,
        address prev_
    );
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`borrower_`|`address`|        Address of the borrower that is liquidated.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`kicker_`|`address`|          Address of the kicker that is kicking the auction.|
|`bondFactor_`|`uint256`|      The factor used for calculating bond size.|
|`bondSize_`|`uint256`|        The bond amount in quote token terms.|
|`kickTime_`|`uint256`|        Time the liquidation was initiated.|
|`referencePrice_`|`uint256`|  Price used to determine auction start price.|
|`neutralPrice_`|`uint256`|    `Neutral Price` of auction.|
|`debtToCollateral_`|`uint256`|Borrower debt to collateral, which is used in BPF for kicker's reward calculation.|
|`head_`|`address`|            Address of the head auction.|
|`next_`|`address`|            Address of the next auction in queue.|
|`prev_`|`address`|            Address of the prev auction in queue.|


### debtInfo

Returns pool related debt values.


```solidity
function debtInfo()
    external
    view
    returns (uint256 debt_, uint256 accruedDebt_, uint256 debtInAuction_, uint256 t0Debt2ToCollateral_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`debt_`|`uint256`|               Current amount of debt owed by borrowers in pool.|
|`accruedDebt_`|`uint256`|        Debt owed by borrowers based on last inflator snapshot.|
|`debtInAuction_`|`uint256`|      Total amount of debt in auction.|
|`t0Debt2ToCollateral_`|`uint256`|t0debt accross all borrowers divided by their collateral, used in determining a collateralization weighted debt.|


### borrowerInfo

Mapping of borrower addresses to `Borrower` structs.

*NOTE: Cannot use appended underscore syntax for return params since struct is used.*


```solidity
function borrowerInfo(address borrower_)
    external
    view
    returns (uint256 t0Debt_, uint256 collateral_, uint256 npTpRatio_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`borrower_`|`address`|  Address of the borrower.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`t0Debt_`|`uint256`|    Amount of debt borrower would have had if their loan was the first debt drawn from the pool.|
|`collateral_`|`uint256`|Amount of collateral that the borrower has deposited, in collateral token.|
|`npTpRatio_`|`uint256`| Np to Tp ratio of borrower at the time of last borrow or pull collateral.|


### bucketInfo

Mapping of buckets indexes to `Bucket` structs.

*NOTE: Cannot use appended underscore syntax for return params since struct is used.*


```solidity
function bucketInfo(uint256 index_)
    external
    view
    returns (
        uint256 lpAccumulator_,
        uint256 availableCollateral_,
        uint256 bankruptcyTime_,
        uint256 bucketDeposit_,
        uint256 bucketScale_
    );
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index_`|`uint256`|              Bucket index.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`lpAccumulator_`|`uint256`|      Amount of `LP` accumulated in current bucket.|
|`availableCollateral_`|`uint256`|Amount of collateral available in current bucket.|
|`bankruptcyTime_`|`uint256`|     Timestamp when bucket become insolvent, `0` if healthy.|
|`bucketDeposit_`|`uint256`|      Amount of quote tokens in bucket.|
|`bucketScale_`|`uint256`|        Bucket multiplier.|


### burnInfo

Mapping of burnEventEpoch to `BurnEvent` structs.

*Reserve auctions correspond to burn events.*


```solidity
function burnInfo(uint256 burnEventEpoch_) external view returns (uint256, uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`burnEventEpoch_`|`uint256`| Id of the current reserve auction.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|burnBlock_       Block in which a reserve auction started.|
|`<none>`|`uint256`|totalInterest_   Total interest as of the reserve auction.|
|`<none>`|`uint256`|totalBurned_     Total ajna tokens burned as of the reserve auction.|


### currentBurnEpoch

Returns the latest `burnEventEpoch` of reserve auctions.

*If a reserve auction is active, it refers to the current reserve auction. If no reserve auction is active, it refers to the last reserve auction.*


```solidity
function currentBurnEpoch() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Current `burnEventEpoch`.|


### emasInfo

Returns information about the pool `EMA (Exponential Moving Average)` variables.


```solidity
function emasInfo()
    external
    view
    returns (uint256 debtColEma_, uint256 lupt0DebtEma_, uint256 debtEma_, uint256 depositEma_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`debtColEma_`|`uint256`|  Debt squared to collateral Exponential, numerator to `TU` calculation.|
|`lupt0DebtEma_`|`uint256`|Exponential of `LUP * t0 debt`, denominator to `TU` calculation|
|`debtEma_`|`uint256`|     Exponential debt moving average.|
|`depositEma_`|`uint256`|  sample of meaningful deposit Exponential, denominator to `MAU` calculation.|


### inflatorInfo

Returns information about pool inflator.


```solidity
function inflatorInfo() external view returns (uint256 inflator_, uint256 lastUpdate_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`inflator_`|`uint256`|  Pool inflator value.|
|`lastUpdate_`|`uint256`|The timestamp of the last `inflator` update.|


### interestRateInfo

Returns information about pool interest rate.


```solidity
function interestRateInfo() external view returns (uint256 interestRate_, uint256 interestRateUpdate_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`interestRate_`|`uint256`|      Current interest rate in pool.|
|`interestRateUpdate_`|`uint256`|The timestamp of the last interest rate update.|


### kickerInfo

Returns details about kicker balances.


```solidity
function kickerInfo(address kicker_) external view returns (uint256 claimable_, uint256 locked_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`kicker_`|`address`|   The address of the kicker to retrieved info for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`claimable_`|`uint256`|Amount of quote token kicker can claim / withdraw from pool at any time.|
|`locked_`|`uint256`|   Amount of quote token kicker locked in auctions (as bonds).|


### lenderInfo

Mapping of buckets indexes and owner addresses to `Lender` structs.


```solidity
function lenderInfo(uint256 index_, address lender_) external view returns (uint256 lpBalance_, uint256 depositTime_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index_`|`uint256`|      Bucket index.|
|`lender_`|`address`|     Address of the liquidity provider.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`lpBalance_`|`uint256`|  Amount of `LP` owner has in current bucket.|
|`depositTime_`|`uint256`|Time the user last deposited quote token.|


### lpAllowance

Return the `LP` allowance a `LP` owner provided to a spender.


```solidity
function lpAllowance(uint256 index_, address spender_, address owner_) external view returns (uint256 allowance_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index_`|`uint256`|    Bucket index.|
|`spender_`|`address`|  Address of the `LP` spender.|
|`owner_`|`address`|    The initial owner of the `LP`.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`allowance_`|`uint256`|Amount of `LP` spender can utilize.|


### loanInfo

Returns information about a loan in the pool.


```solidity
function loanInfo(uint256 loanId_) external view returns (address borrower_, uint256 t0DebtToCollateral_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`loanId_`|`uint256`|            Loan's id within loan heap. Max loan is position `1`.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`borrower_`|`address`|          Borrower address at the given position.|
|`t0DebtToCollateral_`|`uint256`|Borrower t0 debt to collateral.|


### loansInfo

Returns information about pool loans.


```solidity
function loansInfo() external view returns (address maxBorrower_, uint256 maxT0DebtToCollateral_, uint256 noOfLoans_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`maxBorrower_`|`address`|          Borrower address with highest t0 debt to collateral.|
|`maxT0DebtToCollateral_`|`uint256`|Highest t0 debt to collateral in pool.|
|`noOfLoans_`|`uint256`|            Total number of loans.|


### reservesInfo

Returns information about pool reserves.


```solidity
function reservesInfo()
    external
    view
    returns (
        uint256 liquidationBondEscrowed_,
        uint256 reserveAuctionUnclaimed_,
        uint256 reserveAuctionKicked_,
        uint256 lastKickedReserves_,
        uint256 totalInterestEarned_
    );
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`liquidationBondEscrowed_`|`uint256`|Amount of liquidation bond across all liquidators.|
|`reserveAuctionUnclaimed_`|`uint256`|Amount of claimable reserves which has not been taken in the `Claimable Reserve Auction`.|
|`reserveAuctionKicked_`|`uint256`|   Time a `Claimable Reserve Auction` was last kicked.|
|`lastKickedReserves_`|`uint256`|     Amount of reserves upon last kick, used to calculate price.|
|`totalInterestEarned_`|`uint256`|    Total interest earned by all lenders in the pool|


### pledgedCollateral

Returns the `pledgedCollateral` state variable.


```solidity
function pledgedCollateral() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total pledged collateral in the system, in WAD units.|


### totalAuctionsInPool

Returns the total number of active auctions in pool.


```solidity
function totalAuctionsInPool() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|totalAuctions_ Number of active auctions.|


### totalT0Debt

Returns the `t0Debt` state variable.

*This value should be multiplied by inflator in order to calculate current debt of the pool.*


```solidity
function totalT0Debt() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total `t0Debt` in the system, in `WAD` units.|


### totalT0DebtInAuction

Returns the `t0DebtInAuction` state variable.

*This value should be multiplied by inflator in order to calculate current debt in auction of the pool.*


```solidity
function totalT0DebtInAuction() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total `t0DebtInAuction` in the system, in `WAD` units.|


### approvedTransferors

Mapping of addresses that can transfer `LP` to a given lender.


```solidity
function approvedTransferors(address lender_, address transferor_) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`lender_`|`address`|    Lender that receives `LP`.|
|`transferor_`|`address`|Transferor that transfers `LP`.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the transferor is approved by lender.|


