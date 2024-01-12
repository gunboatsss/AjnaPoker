# PoolState
*Struct holding pool params (in memory only).*


```solidity
struct PoolState {
    uint8 poolType;
    uint256 t0Debt;
    uint256 t0DebtInAuction;
    uint256 debt;
    uint256 collateral;
    uint256 inflator;
    bool isNewInterestAccrued;
    uint256 rate;
    uint256 quoteTokenScale;
}
```

