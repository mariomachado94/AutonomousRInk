pragma solidity ^0.4.22;

import 'tokens/eip20/EIP20.sol';
import './IceToken.sol';

contract Rink {
    address public rinkCoinAddress;
    address public iceTokenAddress;

    address[] public players;
    uint8 public MAX_PLAYERS;

    // in future versions, the price of ice time should be dynamically grabbed
    // from an oracle
    uint public iceTimePerToken;
    uint8 public ENTRANCE_FEE;

    //where uint is the timestamp for when the player entered the rink.
    mapping (address => uint) public onIceTime;

    uint slfEarnings;
    uint public MAX_PAYOUT;

    event PlayerEntered(address _player, uint _time);
    event PlayerLeft(address _player, uint _duration, uint _ICEfee);
    event RinkFlooded(address _maintainer, uint _payout);

    constructor() public {
        //set the max amount of skaters allowed on the rink at once
        MAX_PLAYERS = 12;

        iceTimePerToken = 30 seconds;
        ENTRANCE_FEE = 1;

        slfEarnings = 0;
        MAX_PAYOUT = MAX_PLAYERS*ENTRANCE_FEE/4;

        //create RinkCoin (ownership of rink) and IceToken (1 token/unit of ice time for 4 weeks)
        EIP20 rinkCoin = new EIP20(100, "RinkCoin", 0, "RNK");
        IceToken iceToken = new IceToken(MAX_PLAYERS*(28 days)/iceTimePerToken);

        //transfer all RinkCoins (ownership) and IceTokens (ice time) to contract creater
        rinkCoin.transfer(msg.sender, 100);
        iceToken.transfer(msg.sender, MAX_PLAYERS*(28 days)/iceTimePerToken);

        rinkCoinAddress = address(rinkCoin);
        iceTokenAddress = address(iceToken);
    }

    function numOfPlayers() public view returns (uint) {
        return players.length;
    }

    function enter() public {
        require(players.length < MAX_PLAYERS);
        IceToken iceToken = IceToken(iceTokenAddress);
        require(iceToken.balanceOf(msg.sender) >= ENTRANCE_FEE && onIceTime[msg.sender] == 0);

        players.push(msg.sender);
        onIceTime[msg.sender] = now;

        emit PlayerEntered(msg.sender, now);
    }

    function leave() public {
        require(onIceTime[msg.sender] != 0);
        uint duration = now - onIceTime[msg.sender];

        //charge ice time
        IceToken iceToken = IceToken(iceTokenAddress);
        uint iceFee = duration/iceTimePerToken > ENTRANCE_FEE ? duration/iceTimePerToken : ENTRANCE_FEE;
        //charge an extra token if the player was on a bit longer than charged
        //disincentivises players from trying to squeeze out some free ice time
        iceFee = duration % iceTimePerToken > iceTimePerToken / 4 ? iceFee + 1 : iceFee;

        // The actual iceFee chaged may be less than the amount calculated if the
        // user does not have enough tokens
        // TODO: This should be fixed logically
        iceFee = iceToken.consumeTokens(msg.sender, iceFee);

        slfEarnings += iceFee;

        removePlayer(msg.sender);
        onIceTime[msg.sender] = 0;
        emit PlayerLeft(msg.sender, duration, iceFee);
    }

    function removePlayer(address addr) private {
        for(uint i = 0; i < players.length; i++) {
            if(players[i] == addr) {
                if(i != players.length - 1) {
                    players[i] = players[players.length - 1];
                }
                delete players[players.length - 1];
                players.length--;
                return;
            }
        }
    }

    function flood() public {
        uint payout = calcFloodPayout();
        IceToken ice = IceToken(iceTokenAddress);
        ice.transfer(msg.sender, payout);
        slfEarnings = 0;
        emit RinkFlooded(msg.sender, payout);
    }

    function calcFloodPayout() private view returns(uint) {
        uint payout = slfEarnings;
        for(uint i = 0; i < players.length; i++) {
            uint duration = now - onIceTime[players[i]];
            payout += duration/iceTimePerToken > ENTRANCE_FEE ? duration/iceTimePerToken : ENTRANCE_FEE;
        }

        payout = payout/4 > MAX_PAYOUT ? MAX_PAYOUT : payout/4;
        return payout;
    }
}
