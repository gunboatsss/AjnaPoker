# LoansState
*Struct holding loans state.*


```solidity
struct LoansState {
    Loan[] loans;
    mapping(address => uint256) indices;
    mapping(address => Borrower) borrowers;
}
```

