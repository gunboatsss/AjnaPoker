# Bucket
*Struct holding bucket state.*


```solidity
struct Bucket {
    uint256 lps;
    uint256 collateral;
    uint256 bankruptcyTime;
    mapping(address => Lender) lenders;
}
```

