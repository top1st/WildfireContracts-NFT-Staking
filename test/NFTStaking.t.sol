import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../contracts/BondfireNFTStaking.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IFire is IERC20 {
    function excludeFromFees(address w, bool excluded) external;
}

contract NFTStakingTest is Test {
    BondfireNFTStaking nftStaking;

    address holder = 0xf05EeB9b7267F85c777b2D92EA6eF0105Ae47886;
    address deployer = makeAddr("deployer");
    address fireOwner = 0x46e0a59667393A6C213200d47B9Fb5b6660C8762;

    uint nftId = 1;

    IFire public constant fire =
        IFire(0xC2F7F1f93104eE64b192ED61c9872AcDbbD9D45D);
    IERC20 public constant btc =
        IERC20(0xb17D901469B9208B17d916112988A3FeD19b5cA1);
    IERC721 public constant nft =
        IERC721(0x18E84B96ac3c584Ec5ae2fc4731248aa7dE554b7);

    IBondfireStake public constant fireStake =
        IBondfireStake(0xefC7429973c2bf2d40E2589C4DE06D1F42255832);

    function setUp() public {
        vm.startPrank(deployer);
        
        nftStaking = new BondfireNFTStaking();
        vm.stopPrank();
        vm.startPrank(fireOwner);
        fire.excludeFromFees(address(nftStaking), true);
        vm.stopPrank();
    }

    function _registerPosition(address from, uint positionId) internal {
        vm.startPrank(from);
        nft.approve(address(nftStaking), positionId);
        nftStaking.registerPosition(positionId);
        vm.stopPrank();
    }

    function _addFunds(uint amount) internal {
        vm.startPrank(deployer);
        deal(address(btc), deployer, amount);
        btc.approve(address(nftStaking), amount);
        nftStaking.addFunds(amount);
        vm.stopPrank();
    }

    function _deposit(address from, uint amount) internal {
        vm.startPrank(from);
        fire.approve(address(nftStaking), amount);
        nftStaking.deposit(amount);
        vm.stopPrank();
    }

    function _claim(address from) internal returns (uint reward) {
        vm.startPrank(from);
        reward = nftStaking.claim();
        vm.stopPrank();
    }

    function _withdrawAll(address from) internal {
        vm.startPrank(from);
        nftStaking.withdrawAll();
        vm.stopPrank();
    }

    function _emergencyWithdraw(address from) internal {
        vm.startPrank(from);
        nftStaking.emergencyWithdraw();
        vm.stopPrank();
    }

     function _closePosition(address from) internal {
        vm.startPrank(from);
        nftStaking.closePosition();
        vm.stopPrank();
    }

    function testNFTStaking() public {
        _registerPosition(holder, nftId);
        assertEq(nft.ownerOf(nftId), address(nftStaking));
        _addFunds(10 ether);
        _deposit(holder, 100 ether);
        _addFunds(10 ether);
        assertEq(nftStaking.claimable(holder), 20 ether);
        _withdrawAll(holder);
        assertEq(btc.balanceOf(holder), 20 ether);
        // assertEq(_claim(holder), 20 ether);
        skip(36000 days);
        _closePosition(holder);
        assertEq(nft.ownerOf(nftId), holder);

    }
}
