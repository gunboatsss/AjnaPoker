# ReserveAuctionState
*Struct holding reserve auction state.*


```solidity
struct ReserveAuctionState {
    uint256 kicked;
    uint256 lastKickedReserves;
    uint256 unclaimed;
    uint256 latestBurnEventEpoch;
    uint256 totalAjnaBurned;
    uint256 totalInterestEarned;
    mapping(uint256 => BurnEvent) burnEvents;
}
```

