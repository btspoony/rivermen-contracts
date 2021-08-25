pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

contract RiverMenPawnPool is OwnableUpgradeable, ERC20Upgradeable {

    address public riverMenBox;
    address public riverMenCompound;
    bool public transferPause;

    function initialize(
        address _riverMenBox,
        string memory _name,
        string memory _symbol
    ) public initializer {
        __Ownable_init();
        __ERC20_init(_name, _symbol);

        transferPause = true;
        riverMenBox = _riverMenBox;
    }

    function setRiverMenCompound(address _riverMenCompound) public onlyOwner{
        riverMenCompound = _riverMenCompound;
    }

    function approve(uint256 tokenId) public {
        IERC721Upgradeable(riverMenBox).approve(address(this), tokenId);
    }

//    function compound(uint256[] memory tokenIds) public {
//
//    }

    /**
   * @dev See {IERC20-transfer}.
   *
   * Requirements:
   * - `transferPause` is false
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!transferPause, "ERC20: transfer pause");
        return super.transfer(recipient, amount);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     * - `transferPause` is false
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(!transferPause, "ERC20: transfer pause");
        return super.transferFrom(sender, recipient, amount);
    }
}
