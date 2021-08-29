pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "./IRiverBox.sol";
import "./IRiverMenCompound.sol";

contract RiverMenPawnPool is OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    event Mint(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, address indexed to, uint256 value);


    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    address public riverMenBox;
    address public riverMenCompound;
    address public devAddress;

    // @dev tokenId => weight
    mapping(uint256 => uint256) rarePawns;
    // @dev placeId => tokenIds
    mapping(uint256 => uint256[]) public approvePawns;

    function initialize(
        address _riverMenBox,
        address _dev,
        uint256[] memory _rarePawnIds,
        uint256[] memory _rarePawnWeights
    ) public initializer {
        __Ownable_init();

        _initRarePawnIds(_rarePawnIds, _rarePawnWeights);
        riverMenBox = _riverMenBox;
        devAddress = _dev;
    }

    /* ========== VIEWS ========== */

    function decimals() public view returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function compound(uint256[] memory tokenIds) public {
        IRiverMenCompound(riverMenCompound).compound(tokenIds);
        _mintBatch(tokenIds);
    }

    function approve(uint256 tokenId) public {
        IERC721Upgradeable(riverMenBox).approve(address(this), tokenId);
        uint16 locationId = IRiverBox(riverMenBox).tokenDetail(tokenId).locationId;
        approvePawns[locationId].push(locationId);
    }

    function cancelApprove(address owner, uint256 tokenId) public {
        IERC721Upgradeable(riverMenBox).approve(owner, tokenId);
        uint16 locationId = IRiverBox(riverMenBox).tokenDetail(tokenId).locationId;
        uint256[] storage pawns = approvePawns[locationId];
        for(uint256 i = 0 ; i< pawns.length; i++) {
            if(tokenId == pawns[i]){
                if(i != (pawns.length -1)){
                    pawns[i] = pawns[pawns.length -1];
                }
            }
            pawns.pop();
        }
    }

    function setRiverMenCompound(address _riverMenCompound) public onlyOwner{
        riverMenCompound = _riverMenCompound;
    }


    /* ========== INTERNAL FUNCTIONS ========== */

    function _initRarePawnIds(uint256[] memory _tokenIds, uint256[] memory _weights) internal {
        require(_tokenIds.length == _weights.length, "RiverMenPawnPool: invalid tokenIds or weights");
        for(uint256 i = 0; i < _tokenIds.length ; i++){
            rarePawns[_tokenIds[i]] = _weights[i];
        }
    }

    function _mintBatch(uint256[] memory tokenIds) internal{
        for(uint256 i = 0 ; i < tokenIds.length; i++){
            address owner = IERC721Upgradeable(riverMenBox).ownerOf(tokenIds[i]);
            uint256 amount = 1;
            if(rarePawns[tokenIds[i]] > 0) {
                amount = amount.mul(rarePawns[tokenIds[i]]);
            }
            _mint(owner, amount);
        }
    }


    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Mint(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Burn(account, address(0), amount);
    }




}
