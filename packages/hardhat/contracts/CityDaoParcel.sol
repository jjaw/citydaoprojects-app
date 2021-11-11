pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; //learn more: https://docs.openzeppelin.com/contracts/3.x/erc721

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

contract CityDaoParcel is ERC721, Ownable {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  mapping(uint256 => bool) private _plotIdToSoldStatus;
  mapping(uint256 => uint) private _plotIdToPrice;

  // The owner of an NFT with the given plot ID holds a lifetime lease of the land plot designated in the plotMetadata found at the plotMetadataUri.
  // The plots are meant for conservation purposes only and must be kept in their current state unless specified in another CityDAO contract.
  // The owner of a plot NFT will also be granted one governance vote in proposals involving the communal land designated in the communalLandMetadata found at the communalLandMetadataUri.
  uint256[] private _plotIds = new uint256[](0);

  // The plot metadata marks the bounding area of each plot. 
  // The plot metadata's order matches the order of the plot ids array. 
  // For example, the first plot metadata is for the first plot id in the array.
  string private plotMetadataUri;
  string private parcelMetadataUri;

  // The communal land metadata marks the bounding area of the communal land.
  // This land is owned by CityDAO LLC and is to be governed by the holders of the plot NFTs minted in this contract.
  string private communalLandMetadataUri;

  constructor() public ERC721("CityDaoParcel", "YCB") {
    _setBaseURI("https://ipfs.io/ipfs/");
    _tokenIds.increment(); // reserve 0 for "no plot" id
  }

  function listPlot(uint256 price) public onlyOwner returns (uint256) {
    uint256 plotId = _tokenIds.current();
    _tokenIds.increment();
    _plotIdToPrice[plotId] = price;
    _plotIdToSoldStatus[plotId] = false;
    _plotIds.push(plotId);

    return plotId;
  }

  function setParcelMetadata(string memory uri) public onlyOwner {
    parcelMetadataUri = uri;
  }

  function setPlotsMetadata(string memory uri) public onlyOwner {
    plotMetadataUri = uri;
  }

  function getParcelMetadataUri() public view returns (string memory) {
    return parcelMetadataUri;
  }

  function getPlotsMetadataUri() public view returns (string memory) {
    return plotMetadataUri;
  }

  function setCommunalLandMetadata(string memory uri) public onlyOwner {
    communalLandMetadataUri = uri;
  }
  function getCommunalLandMetadataUri() public view returns (string memory) {
    return communalLandMetadataUri;
  }

  function buyPlot(uint256 plotId)
      payable
      public
      returns (uint256)
  {
      require(!isSold(plotId), "This plot has already been sold!");
      uint256 _price = _plotIdToPrice[plotId];
      require(msg.value == _price, "You must pay the price of the plot!");

      _safeMint(msg.sender, plotId);

      delete _plotIdToPrice[plotId];
      _plotIdToSoldStatus[plotId] = true;

      return plotId;
  }

  function isSold(uint256 plotId) public view returns (bool) {
    return _plotIdToSoldStatus[plotId];
  }

  function getPrice(uint256 plotId) public view returns (uint) {
    return _plotIdToPrice[plotId];
  }

  function getPlotIds() public view returns (uint256[] memory) {
    return _plotIds;
  }

  function getOwners() public view returns (address[] memory) {
    address[] memory _owners = new address[](_plotIds.length);
    for (uint i = 0; i < _plotIds.length; i++) {
      uint256 _plotId = _plotIds[i];
      if (isSold(_plotId)) {
        _owners[i] = ownerOf(_plotIds[i]);
      } else {
        _owners[i] = address(0);
      }
    }
    return _owners;
  }

  function getAllPrices() public view returns (uint256[] memory) {
    uint256[] memory ret = new uint256[](_plotIds.length);
    for (uint i = 0; i < _plotIds.length; i++) {
        ret[i] = _plotIdToPrice[_plotIds[i]];
    }
    return ret;
  }

  function getAllSoldStatus() public view returns (bool[] memory) {
    bool[] memory ret = new bool[](_plotIds.length);
    for (uint i = 0; i < _plotIds.length; i++) {
        ret[i] = _plotIdToSoldStatus[_plotIds[i]];
    }
    return ret;
  }
}
