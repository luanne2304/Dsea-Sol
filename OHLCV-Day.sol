// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OHLCVDay {
    struct FormData {
        //precent = ((open/close)-1)*100
        string symbol;
        uint openTime;
        string open;
        string high;
        string low;
        string close;
        string volume;
        uint closeTime;
        string quoteAssetVolume;
        uint numberOfTrades;
        string takerBuyBaseVol;
        string takerBuyQuoteVol;
    }

    // Mapping thời gian -> string symbol -> FormData
    mapping(uint256 => mapping(string => FormData)) internal Records;

    //Lưu tên symbol 
    mapping(string => uint256) internal symbolID;

    string[] allSymbols;

    event Recorded(
        FormData formData
    );

    // Hàm lấy khóa thời gian
    function getTimeKey(uint256 timestamp) internal pure returns (uint256) {
        return timestamp / 1 days;
    }

    function formatTimestamp(uint256 timeIndex) internal pure returns (uint256) {
        return timeIndex * 1 days; 
    }



    function recordData(
        FormData memory formData
    ) external {

        if(symbolID[formData.symbol] == 0){
            uint256 newId = allSymbols.length + 1; // ID bắt đầu từ 1
            symbolID[formData.symbol] = newId;
            allSymbols.push(formData.symbol);
        }
        uint256 timeIndex = getTimeKey(formData.openTime);

        Records[timeIndex][formData.symbol]= formData;

        emit Recorded(formData);
    }

    function getDataInRange(
        uint256 startTimestamp,
        uint256 endTimestamp,
        string calldata tokenSymbol
    ) public view returns (FormData[] memory) {

        uint256 startKey = getTimeKey(startTimestamp);
        uint256 endKey = getTimeKey(endTimestamp);
        uint256 indexCount = endKey - startKey + 1;

        FormData[] memory DataArray = new FormData[](indexCount);

        for (uint256 i = 0; i < indexCount; i++) {
            uint256 timeIndex = startKey + i;
            DataArray[i] = Records[timeIndex][tokenSymbol];
        }

        return DataArray;
    }

    function getData7ItemsAgo(
        uint256 endTimestamp,
        string calldata tokenSymbol
    ) public view returns (FormData[] memory) {
        uint256 endKey = getTimeKey(endTimestamp);
        uint256 startKey = (endKey >= 7) ? (endKey - 7) : 0; // Đảm bảo không âm
        uint256 indexCount = endKey - startKey + 1;

        FormData[] memory DataArray = new FormData[](indexCount);

        for (uint256 i = 0; i < indexCount; i++) {
            uint256 timeIndex = startKey + i;
            DataArray[i] = Records[timeIndex][tokenSymbol];
        }

        return DataArray;
    }

    function getSymbolByTime(uint256 timestamp, string calldata symbol) public view returns (FormData memory) 
    {
        uint256 timeIndex = getTimeKey(timestamp);
        FormData memory data =  Records[timeIndex][symbol];

        return data;
    }

    function getAllSymbolByTime(uint256 timestamp) public view returns (FormData[] memory) 
    {
        uint256 timeIndex = getTimeKey(timestamp);
        uint256 count = allSymbols.length;

        FormData[] memory data = new FormData[](count);

        for (uint256 i = 0; i < count; i++) {
            string memory tokenSymbol = allSymbols[i];
            data[i] = Records[timeIndex][tokenSymbol];
        }

        return data;
    }

}