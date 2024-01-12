# InterestState
*Struct holding pool interest state.*


```solidity
struct InterestState {
    uint208 interestRate;
    uint48 interestRateUpdate;
    uint256 debt;
    uint256 meaningfulDeposit;
    uint256 t0Debt2ToCollateral;
    uint256 debtCol;
    uint256 lupt0Debt;
}
```

