// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransactionStorage {
    struct Transaction {
        uint256 timestamp;
        address from;
        address to;
        string value;
        string usd;
    }
    //token -> listTrans
    mapping(string => Transaction[]) public history;
    //token -> countTrans
    mapping(string => uint256) public historyCount;

    event TransactionAdded(
        uint256 indexed timestamp,
        address indexed from,
        address indexed to,
        string value,
        string token,
        string usd
    );

    function addTransaction(uint timestamp,address _from,address _to, string memory _value, string memory _token, string memory _usd) public {
        historyCount[_token]++;
        history[_token].push(Transaction(timestamp, _from, _to, _value, _usd));
        

        emit TransactionAdded(timestamp, _from, _to, _value, _token, _usd);
    }

    function getRecentlyTransaction(uint256 quantity, string memory coin) public view returns (Transaction[] memory) {
        uint256 totalTransactions = historyCount[coin]; // Tổng số giao dịch của coin đó
        require(quantity <= totalTransactions, "Transaction index out of bounds");

        Transaction[] memory recentTransactions = new Transaction[](quantity);

        // Lấy từ giao dịch gần nhất (cuối mảng) trở về trước
        for (uint256 i = 0; i < quantity; i++) {
            recentTransactions[i] = history[coin][totalTransactions - quantity + i];
        }

        return recentTransactions;
    }

}
