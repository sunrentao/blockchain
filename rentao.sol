// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract RENTAO is ERC20, Ownable, Pausable{

    mapping (address => bool) private white_lists;
    mapping (address => bool) private pool_address;
    mapping (address => bool) private claimed;
    
    IERC20 test_token_contract;

    constructor() ERC20("RENTAO", "RNT") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());
    }

    function modify_white_list(address _address, bool _value) public onlyOwner {
        white_lists[_address] = _value;
    }

    function modify_pool_address(address _address, bool _value) public onlyOwner {
        pool_address[_address] = _value;
    }

    function set_test_token_contract(address _address) external onlyOwner {
        test_token_contract = IERC20(_address);
    }

    modifier transferable(address _sender, address _receiver) {
        require(
            !pool_address[_sender] || white_lists[_receiver]
            );
        _;
    }

    modifier claimable(address _account) {
        require(
            !claimed[_account]
            );
        _;
    }

    function claim() public claimable(_msgSender()) returns (bool) {
        uint256 test_token_value;
        test_token_value = test_token_contract.balanceOf(_msgSender());
        claimed[_msgSender()] = true;
        _transfer(owner(), _msgSender(), test_token_value);
        return true;
    }

    function transfer(address to, uint256 amount) public override transferable(msg.sender, to) returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function check_pool_address(address _address) public view returns(bool){
        return (pool_address[_address]);
    }

    function check_white_lists(address _address) public view returns(bool){
        return (white_lists[_address]);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}

