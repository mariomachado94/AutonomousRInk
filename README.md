# AutonomousRink
An Autonomous Hockey Rink proof of concept. A Truffle project built for Ethereum

The idea in this project was to create a two token system for a Rink contract. RinkCoin and IceToken would both be
ERC20 complient, but they would be treated differently by the Rink contract. The RinkCoin contract would define
ownership of the hockey rink, where as IceToken would be used for payment of ice time by skaters.

Rink.sol accepts payment of tokens upon enterence, and pays out maintainers of the ice in tokens.
