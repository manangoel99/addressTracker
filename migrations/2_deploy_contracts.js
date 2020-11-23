const MyStringStore = artifacts.require("MyStringStore");
const Token = artifacts.require("Token");
const AddressTracker = artifacts.require("AddressTracker");
module.exports = function(deployer) {
  deployer.deploy(MyStringStore);
  deployer.deploy(Token);
  deployer.deploy(AddressTracker);
};