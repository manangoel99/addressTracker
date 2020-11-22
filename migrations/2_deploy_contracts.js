const MyStringStore = artifacts.require("MyStringStore");
const Token = artifacts.require("Token")

module.exports = function(deployer) {
  deployer.deploy(MyStringStore);
  deployer.deploy(Token);
};