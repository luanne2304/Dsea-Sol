// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FlowTrackerByDay {
    struct FlowData {
        uint timestamp;
        string incoming;
        string outgoing;
        string balance;
    }

    // Mapping thời gian -> sàn -> token -> FlowData
    mapping(uint256 => mapping(string => mapping(string => FlowData))) private flowRecords;

    event FlowTotalRecorded(uint256 timestamp, string tokenSymbol, string exchangeName, string incoming, string outgoing, string balance);

    // Hàm lấy khóa thời gian (theo ngày)
    function getTimeKey(uint256 timestamp) internal pure returns (uint256) {
        return timestamp / 1 days; // Chia timestamp theo đơn vị ngày   
    }

    function formatTimestamp(uint256 timeIndex) internal pure returns (uint256) {
        return timeIndex * 1 days; // Chia timestamp theo đơn vị ngày
    }

    // Ghi nhận dữ liệu vào smart contract theo ngày
    function recordFlow(uint256 timestamp, string memory incoming, string memory outgoing,string memory balance, string calldata tokenSymbol, string calldata exchangeName) external {
        uint256 itemIndex = getTimeKey(timestamp); // Chia theo ngày
        uint256 formatKey = formatTimestamp(itemIndex); // Chia theo ngày
        FlowData storage flow= flowRecords[itemIndex][exchangeName][tokenSymbol];
        flow.incoming = incoming;
        flow.outgoing = outgoing;
        flow.balance = balance;
        flow.timestamp =formatKey;

        emit FlowTotalRecorded(formatKey, tokenSymbol, exchangeName, incoming, outgoing, balance );
    }

    // Lấy danh sách vào/ra theo từng ngày trong khoảng thời gian từ startTimestamp đến endTimestamp
    function getFlowInRange(
        uint256 startTimestamp,
        uint256 endTimestamp,
        string calldata tokenSymbol,
        string calldata exchangeName
    ) public view returns (FlowData[] memory) {
        uint256 startKey = getTimeKey(startTimestamp);
        uint256 endKey = getTimeKey(endTimestamp);
        uint256 indexCount = endKey - startKey + 1;

        FlowData[] memory flowArray = new FlowData[](indexCount);

        for (uint256 i = 0; i < indexCount; i++) {
            uint256 itemIndex = startKey + i;
            flowArray[i] = flowRecords[itemIndex][exchangeName][tokenSymbol];
        }

        return flowArray;
    }


    function getFlow7ItemsAgo(
        uint256 endTimestamp,
        string calldata tokenSymbol,
        string calldata exchangeName
    ) public view returns (FlowData[] memory) {
        uint256 endKey = getTimeKey(endTimestamp);
        uint256 startKey = (endKey >= 7) ? (endKey - 7) : 0; // Đảm bảo không âm
        uint256 indexCount = endKey - startKey + 1;

        FlowData[] memory flowArray = new FlowData[](indexCount);

        for (uint256 i = 0; i < indexCount; i++) {
            uint256 itemIndex = startKey + i;
            flowArray[i] = flowRecords[itemIndex][exchangeName][tokenSymbol];
        }

        return flowArray;
    }

    function getFlowbyTime(
        uint256 timestamp,
        string calldata tokenSymbol,
        string calldata exchangeName
    ) public view returns (FlowData memory) {
        uint256 timeIndex = getTimeKey(timestamp);
        return flowRecords[timeIndex][exchangeName][tokenSymbol];
    }
}
