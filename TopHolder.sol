// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TopHolder {
    struct Holder {
        address tokenHolderAddress;
        string tokenHolderQuantity;
        string tokenName;
        string tokenSymbol;
        string tokenDivisor;
    }

    // Coin -> index -> TopHolder
    mapping(string => mapping(uint256 => Holder[])) public holders;

    mapping(string => uint) public tokenIndexCount;

    event updHolders(string coin, Holder[] holders);

    // Thêm nhiều Holder vào một ID cụ thể
    function addHolders(string memory coin,Holder[] memory _holders) public {
        tokenIndexCount[coin]++;
        for (uint256 i = 0; i < _holders.length; i++) {
            holders[coin][tokenIndexCount[coin]].push(_holders[i]);
        }
        emit updHolders(coin,  holders[coin][tokenIndexCount[coin]] );
    }

    // Lấy tất cả holders của một ID cụ thể (Truyền 0 vào ID để lấy danh sách hiện tại)
    function getHolders(string memory coin,uint256 _id) public view returns (Holder[] memory) {
        if(_id > 0 && _id <= tokenIndexCount[coin]){
             return holders[coin][_id];
        }
        else{
            return holders[coin][tokenIndexCount[coin]];
        }
    }

}
