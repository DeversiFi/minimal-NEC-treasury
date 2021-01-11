pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface BurnableToken {
    function burnAndRetrieve(uint256 _tokensToBurn) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function totalSupply() external view returns (uint256);
}

contract NectarTreasury is Ownable{
    using SafeMath for uint256;

    address necAddress;

    constructor(address _token) public {
        necAddress = _token;
    }

    receive() external payable { }

    function necToken() public view returns (BurnableToken) {
        return BurnableToken(necAddress);
    }

    function calculateEthPerNec(uint256 necAmount) public view returns (uint256) {
        return treasurySize().mul(necAmount).div(necToken().totalSupply());
    }

    function treasurySize() public view returns (uint256) {
        return address(this).balance;
    }

    function burnTokensAndClaimeShareOfTreasury(uint256 necAmount) external {
        require(
            necToken().transferFrom(msg.sender, address(this), necAmount),
            "NEC transferFrom failed"
        );
        uint ethToSend = calculateEthPerNec(necAmount);
        require(ethToSend > 0, "No ether to pay out");
        necToken().burnAndRetrieve(necAmount);
        msg.sender.transfer(ethToSend);
    }

    function transferTreasuryFundsToDAO(uint256 ethAmount) onlyOwner public {
        payable(owner()).transfer(ethAmount);
    }
}
