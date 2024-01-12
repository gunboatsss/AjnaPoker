# Liquidation
*Struct holding liquidation state.*


```solidity
struct Liquidation {
    address kicker;
    uint96 bondFactor;
    uint96 kickTime;
    address prev;
    uint96 referencePrice;
    address next;
    uint160 bondSize;
    uint96 neutralPrice;
    uint256 debtToCollateral;
    uint256 t0ReserveSettleAmount;
}
```

