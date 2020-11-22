pragma solidity ^0.6.0;

// Import and then rename the OpenZeppelin contract stubs for ERC20 and ERC721 contract
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
// import {ERC721Token as StandardERC721} from "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "./contracts/token/ERC20/ERC20.sol";

// contract ERC20Token is ERC20 {
//     string public override name;
//     string public override symbol;
//     uint8 public override decimals;

//     constructor(string memory _name, string memory _symbol, uint8 _decimals) public {
//         name = _name;
//         symbol = _symbol;
//         decimals = _decimals;
//     }
// }

// contract ERC721Token is StandardERC721 {
//     constructor(string _name, string _symbol)
//     public
//     StandardERC721(_name, _symbol)
//     {
//     }
// }

contract Token {
    /* @dev Creates a new ERC20Token with the given name, symbol and number of decimals.
        Logs an event with the address of the token and its parameters
    */
    ERC20 token;
    constructor() public {
        ERC20 T = new ERC20("HOHO", "HOHO");
        token = T;
    }

    function getToken() public returns (ERC20) {
        return token;
    }
    // function newERC20(string memory _name, string memory _symbol, uint8 _decimals) public {
    //     emit ERC20Created(new ERC20Token(_name, _symbol, _decimals), _name, _symbol, _decimals);
    // }

    /* @dev Creates a new ERC721Token with the given name and symbol.            
        Logs an event with the address of the token and its parameters               
    */
    // function newERC721(string _name, string _symbol) public {
    //     emit ERC721Created(new ERC721Token(_name, _symbol), _name, _symbol);
    // }

    // event ERC20Created(ERC20Token indexed tokenAddress, string indexed name, string indexed symbol, uint8 decimals);
    // event ERC721Created(ERC721Token tokenAddress, string name, string symbol);
}