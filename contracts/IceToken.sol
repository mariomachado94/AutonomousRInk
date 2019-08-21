pragma solidity ^0.4.22;

import 'tokens/eip20/EIP20.sol';

contract IceToken is EIP20 {
    address rinkAddress;

    constructor(uint256 _initialAmount) EIP20(_initialAmount, "IceToken", 0, "ICE")
    public {
        rinkAddress = msg.sender;
    }

    modifier rinkControlled() {
        require(msg.sender == rinkAddress);
        _;
    }

    // This method will consume less than the _maxValue if the _address does not
    // have enough tokens
    function consumeTokens(address _from, uint _maxValue) public rinkControlled returns(uint) {
        if (balances[_from] < _maxValue) {
            _maxValue = balances[_from];
        }
        balances[_from] -= _maxValue;
        balances[rinkAddress] += _maxValue;
        emit Transfer(_from, rinkAddress, _maxValue);
        return _maxValue;
    }
}
