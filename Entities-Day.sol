// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ExchangeWalletTracker {
    struct TokenInfo {
        string symbol;
        uint256 balance;
        uint8 decimals;
        uint256 quote_rate;
        uint256 quote_rate_24h;
        int256 profit;
    }

    struct ExchangeInfo {
        uint256 timestamp;
        string name;
        uint256 totalBalance;
        int256 profit;
        TokenInfo[] listCoinHolding;
    }

    mapping(uint256 => mapping(string => ExchangeInfo)) private dailyExchangeData;
    mapping(string => uint256) private exchangeIds; // Ánh xạ tên sàn -> ID tăng dần
    string[] public exchangeList; // Danh sách tất cả sàn giao dịch

    event ExchangeUpdated(uint256 timestamp, string exchange, uint256 totalBalance, int256 profit, TokenInfo[]);

    // Hàm lấy khóa thời gian
    function getTimeKey(uint256 timestamp) internal pure returns (uint256) {
        return timestamp / 1 days;
    }

    function formatTimestamp(uint256 timeIndex) internal pure returns (uint256) {
        return timeIndex * 1 days; 
    }

    function storeExchangeData(
        uint256 timestamp,
        string memory _exchangeName,
        uint256 _totalBalance,
        int256 _profit,
        TokenInfo[] memory _tokens
    ) public {
        uint256 dayIndex = getTimeKey(timestamp);
        uint256 formatKey = formatTimestamp(dayIndex);
        ExchangeInfo storage exchange = dailyExchangeData[dayIndex][_exchangeName];

        // Nếu đây là lần đầu tiên sàn được lưu, thêm vào danh sách và gán ID
        if (exchangeIds[_exchangeName] == 0) {
            exchangeIds[_exchangeName] = exchangeList.length + 1; // ID tăng dần
            exchangeList.push(_exchangeName);
        }

        exchange.name = _exchangeName;
        exchange.totalBalance = _totalBalance;
        exchange.profit = _profit;
        exchange.timestamp=formatKey;

        delete exchange.listCoinHolding;
        for (uint256 i = 0; i < _tokens.length; i++) {
            exchange.listCoinHolding.push(_tokens[i]);
        }

        emit ExchangeUpdated(formatKey, _exchangeName, _totalBalance, _profit, _tokens);
    }

    function getExchangeData(uint256 timestamp, string calldata _exchange) public view returns (ExchangeInfo memory) {
        uint256 dayIndex = getTimeKey(timestamp);
        return dailyExchangeData[dayIndex][_exchange];
    }

    // Hàm xóa sàn khỏi danh sách
    function removeExchangeFromList(string memory _exchangeName) public {
        require(exchangeIds[_exchangeName] != 0, "Exchange does not exist");

        uint256 index = exchangeIds[_exchangeName] - 1; // Lấy index thực tế
        uint256 lastIndex = exchangeList.length - 1;

        if (index != lastIndex) {
            exchangeList[index] = exchangeList[lastIndex]; // Đưa phần tử cuối lên vị trí bị xóa
            exchangeIds[exchangeList[index]] = index + 1; // Cập nhật index mới
        }

        exchangeList.pop(); // Xóa phần tử cuối cùng
        delete exchangeIds[_exchangeName]; // Xóa ID

    }

    function getAllExchangesByTimestamp(uint256 timestamp) public view returns (ExchangeInfo[] memory) {
        uint256 dayIndex = getTimeKey(timestamp);
        uint256 totalExchanges = exchangeList.length;

        ExchangeInfo[] memory exchanges = new ExchangeInfo[](totalExchanges);

        for (uint256 i = 0; i < totalExchanges; i++) {
            exchanges[i] = dailyExchangeData[dayIndex][exchangeList[i]];
        }

        return exchanges;
    }

    // Hàm lấy dữ liệu Exchange của 7 ngày trước tính từ ngày kết thúc (endTimestamp)
    function getExchangeData7ItemsAgo(
        uint256 endTimestamp,
        string calldata _exchangeName
    ) public view returns (ExchangeInfo[] memory) {
        uint256 endKey = getTimeKey(endTimestamp);  // Lấy khóa thời gian từ timestamp kết thúc
        uint256 startKey = (endKey >= 7) ? (endKey - 7) : 0; // Đảm bảo startKey không âm
        uint256 indexCount = endKey - startKey + 1;  // Số lượng ngày cần lấy

        ExchangeInfo[] memory exchangeArray = new ExchangeInfo[](indexCount);

        // Lặp qua và lấy dữ liệu Exchange từ 7 ngày trước
        for (uint256 i = 0; i < indexCount; i++) {
            uint256 timeIndex = startKey + i;
            exchangeArray[i] = dailyExchangeData[timeIndex][_exchangeName];
        }

        return exchangeArray;
    }


    function getDataInRangeByExchangeName(
        uint256 startTimestamp,
        uint256 endTimestamp,
        string calldata _exchangeName
    ) public view returns (ExchangeInfo[] memory) {
        uint256 startKey = getTimeKey(startTimestamp);
        uint256 endKey = getTimeKey(endTimestamp);
        uint256 indexCount = endKey - startKey + 1;

        ExchangeInfo[] memory DataArray = new ExchangeInfo[](indexCount);

        for (uint256 i = 0; i < indexCount; i++) {
            uint256 timeIndex = startKey + i;
            DataArray[i] = dailyExchangeData[timeIndex][_exchangeName];
        }
        return DataArray;
    }
}
