const MyStringStore = artifacts.require("MyStringStore");
const Token = artifacts.require("Token");
const Address = artifacts.require("Address");
module.exports = function(deployer) {
  deployer.deploy(MyStringStore);
  deployer.deploy(Token);
  deployer.deploy(Address);
};