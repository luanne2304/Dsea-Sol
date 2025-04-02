// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OpenInterestTrackerByDay {
    struct OpenInterestData {
        uint256 timestamp;               // Thời gian (theo ngày)
        uint256 sumOpenInterest;         // Tổng OI
        uint256 sumOpenInterestValue;    // Tổng giá trị của OI (có thể là OI * giá)
    }

    // Mapping thời gian -> sàn -> token -> OpenInterestData
    mapping(uint256 => mapping(string => mapping(string => OpenInterestData))) private openInterestRecords;

    event OpenInterestRecorded(uint256 timestamp, string tokenSymbol, string exchangeName, uint256 sumOpenInterest, uint256 sumOpenInterestValue);

    // Hàm lấy khóa thời gian (theo ngày)
    function getTimeKey(uint256 timestamp) internal pure returns (uint256) {
        return timestamp / 1 days; // Chia timestamp theo đơn vị ngày
    }

    function formatTimestamp(uint256 timeIndex) internal pure returns (uint256) {
        return timeIndex * 1 days; // Chia timestamp theo đơn vị ngày
    }

    // Ghi nhận dữ liệu Open Interest vào smart contract theo ngày
    function recordOpenInterest(
        uint256 timestamp, 
        uint256 sumOpenInterest, 
        uint256 sumOpenInterestValue, 
        string calldata tokenSymbol, 
        string calldata exchangeName
    ) external {
        uint256 itemIndex = getTimeKey(timestamp); // Chia theo ngày
        uint256 formatKey = formatTimestamp(itemIndex); // Chia theo ngày
        OpenInterestData storage openInterest = openInterestRecords[itemIndex][exchangeName][tokenSymbol];
        openInterest.sumOpenInterest = sumOpenInterest;
        openInterest.sumOpenInterestValue = sumOpenInterestValue;
        openInterest.timestamp = formatKey;

        emit OpenInterestRecorded(formatKey, tokenSymbol, exchangeName, sumOpenInterest, sumOpenInterestValue);
    }

    // Lấy danh sách Open Interest theo từng ngày trong khoảng thời gian từ startTimestamp đến endTimestamp
    function getOpenInterestInRange(
        uint256 startTimestamp,
        uint256 endTimestamp,
        string calldata tokenSymbol,
        string calldata exchangeName
    ) public view returns (OpenInterestData[] memory) {
        uint256 startKey = getTimeKey(startTimestamp);
        uint256 endKey = getTimeKey(endTimestamp);
        uint256 indexCount = endKey - startKey + 1;

        OpenInterestData[] memory openInterestArray = new OpenInterestData[](indexCount);

        for (uint256 i = 0; i < indexCount; i++) {
            uint256 itemIndex = startKey + i;
            openInterestArray[i] = openInterestRecords[itemIndex][exchangeName][tokenSymbol];
        }

        return openInterestArray;
    }

    // Hàm lấy Open Interest của 7 ngày trước tính từ ngày kết thúc (endTimestamp)
    function getOpenInterest7ItemsAgo(
        uint256 endTimestamp,
        string calldata tokenSymbol,
        string calldata exchangeName
    ) public view returns (OpenInterestData[] memory) {
        uint256 endKey = getTimeKey(endTimestamp);  // Lấy khóa thời gian từ timestamp kết thúc
        uint256 startKey = (endKey >= 7) ? (endKey - 7) : 0; // Đảm bảo startKey không âm
        uint256 indexCount = endKey - startKey + 1;  // Số lượng dữ liệu cần lấy

        OpenInterestData[] memory openInterestArray = new OpenInterestData[](indexCount);

        // Lặp qua và lấy dữ liệu Open Interest từ 7 ngày trước
        for (uint256 i = 0; i < indexCount; i++) {
            uint256 itemIndex = startKey + i;
            openInterestArray[i] = openInterestRecords[itemIndex][exchangeName][tokenSymbol];
        }

        return openInterestArray;
    }


    // Lấy Open Interest của một ngày cụ thể
    function getOpenInterestByTime(
        uint256 timestamp,
        string calldata tokenSymbol,
        string calldata exchangeName
    ) public view returns (OpenInterestData memory) {
        uint256 timeIndex = getTimeKey(timestamp);
        return openInterestRecords[timeIndex][exchangeName][tokenSymbol];
    }
}
