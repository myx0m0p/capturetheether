pragma solidity ^0.4.21;

contract Suicide {
    function Suicide(address _target) public payable {
        selfdestruct(_target);
    }
}
