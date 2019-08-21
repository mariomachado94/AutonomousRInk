// var EIP20Interface = artifacts.require("tokens/eip/EIP20Interface.sol");
// var EIP20 = artifacts.require("tokens/eip20/EIP20.sol");
// var IceToken = artifacts.require("./IceToken.sol");
// var RinkCoin = artifacts.require("./RinkCoin");
var Rink = artifacts.require("./Rink.sol");


module.exports = function(deployer) {
  // deployer.deploy(EIP20, {overwrite: false}).then(function() {
  //   return deployer.deploy(EIP20, IceToken.address);
  // });
  // deployer.deploy(EIP20Interface);
  // deployer.link(EIP20Interface, EIP20);
  // deployer.deploy(EIP20);
  // deployer.link(EIP20, IceToken);
  // deployer.deploy(IceToken);
  // deployer.link(EIP20, Rink);
  // deployer.link(IceToken, Rink);
  deployer.deploy(Rink);
};
