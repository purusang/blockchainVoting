// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

contract ElectionContract {
    // using SafeMathChainlink for uint256;

    // mapping(address => uint256) public addressToAmountFunded;
    struct votesTransactions {
        uint32 vote; // this will hold encrypted votes+mask of fixed length
        int32 signature; // not sure how to store these.
        int32 keyImage;
    }
    votesTransactions[] public votes_ransactions; //each vote is bound in this structure.
    address public owner; // Election Commission will be the owner
    int32 public no_of_shares;
    int32 public threshold_of_shares;
    int32 public modulus;
    int32 public public_verification_key;
    int32[] public public_shares; // I think we don't put private shares here.
    address[] public voters; // consists of OTPKs
    mapping(address => int32) public voterToR; // This will have OTPKs => rG
    uint32 public start_time; // unix Time in seconds need to be passed from JS or Python.
    uint32 public end_time;
    uint32 public ring_size;
    string[] public parties; // array of party's names

    constructor(int32 _modulus, int32 _public_verification_key) public {
        modulus = _modulus;
        public_verification_key = _public_verification_key;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    // 1000000000
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
