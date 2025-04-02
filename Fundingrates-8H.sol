// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FundingRates8H {
    struct FlowData {
        uint timestamp;
        string fundingRates;
        string markPrice;
        uint timeIndex;
    }

    // Mapping thời gian -> sàn -> token -> FlowData
    mapping(uint256 => mapping(string => mapping(string => FlowData))) public flowRecords;

    event FlowTotalRecorded(uint256 timeIndex, string tokenSymbol, string exchangeName, string fundingRates, string markPrice);

    // Hàm lấy khóa thời gian 8h
    function getTimeKey(uint256 timestamp) internal pure returns (uint256) {
        return timestamp / 8 hours; 
    }

    function formatTimestamp(uint256 timeIndex) internal pure returns (uint256) {
        return timeIndex * 8 hours; 
    }

    // Ghi nhận dữ liệu vào smart contract theo  8h
    function recordFlow(uint256 timestamp, string memory fundingRates, string memory markPrice ,string calldata tokenSymbol, string calldata exchangeName) external {
        uint256 timeIndex = getTimeKey(timestamp); 
        FlowData storage flow= flowRecords[timeIndex][exchangeName][tokenSymbol];
        flow.fundingRates = fundingRates;
        flow.markPrice = markPrice;
        flow.timeIndex=timeIndex;

        emit FlowTotalRecorded(timeIndex, tokenSymbol, exchangeName, fundingRates,markPrice );
    }

    // Lấy danh sách vào/ra theo từng mốc 8h trong khoảng thời gian từ startTimestamp đến endTimestamp
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
            uint256 timeIndex = startKey + i;
            flowArray[i] = flowRecords[timeIndex][exchangeName][tokenSymbol];
        }

        return flowArray;
    }

}
