# AuctionsState
*Struct holding pool auctions state.*


```solidity
struct AuctionsState {
    uint96 noOfAuctions;
    address head;
    address tail;
    uint256 totalBondEscrowed;
    mapping(address => Liquidation) liquidations;
    mapping(address => Kicker) kickers;
}
```

