// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FearAndGreedIndex {
    struct FormData {
        uint256 timestamp;
        uint256 value;
        string value_classification;
    }

    // Mapping thời gian -> chỉ số Fear & Greed
    mapping(uint256 => FormData) private Records;

    event Recorded(FormData _formData );

    // Hàm lấy khóa thời gian (theo ngày)
    function getTimeKey(uint256 timestamp) internal pure returns (uint256) {
        return timestamp / 1 days;
    }

    function formatTimestamp(uint256 timeIndex) internal pure returns (uint256) {
        return timeIndex * 1 days;
    }

    // Ghi nhận dữ liệu Fear & Greed theo ngày
    function recordIndex(FormData memory _formData) external {
        uint256 itemIndex = getTimeKey(_formData.timestamp);
        uint256 formatKey = formatTimestamp(itemIndex);
        _formData.timestamp=formatKey;
        
        Records[itemIndex]=_formData;
        
        emit Recorded(_formData);
    }

    // Lấy dữ liệu Fear & Greed theo ngày cụ thể
    function getIndexByTime(uint256 timestamp) public view returns (FormData memory) {
        uint256 timeIndex = getTimeKey(timestamp);
        return Records[timeIndex];
    }
}
