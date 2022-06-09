// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.9;

import "./onft/ONFT721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


contract VeryLongTown is ONFT721 {
    using Strings for uint256;

    uint public nextMintId;
    uint public maxMintId;

    string baseURI;
    string public baseExtension = ".json";
    uint256 private preCost = 0.01 ether;
    uint256 private publicCost = 0.01 ether;
    uint256 public publicMaxPerTx = 10;
    uint256 constant presaleMaxPerWallet = 10;
    bool public paused = false;
    bool public revealed = false;
    bool public presale = true;
    string public notRevealedUri;

    bytes32 public merkleRoot;

    mapping(address => uint256) private whiteListClaimed;


    /// @notice Constructor for the UniversalONFT
    /// @param _layerZeroEndpoint handles message transmission across chains
    /// @param _startMintId the starting mint number on this chain
    /// @param _endMintId the max number of mints on this chain
    constructor(address _layerZeroEndpoint, uint _startMintId,
    uint _endMintId) ONFT721("VeryLongTown", "VLT", _layerZeroEndpoint) {
        nextMintId = _startMintId;
        maxMintId = _endMintId;
    }

    // public mint
    function publicMint(uint256 _mintAmount) public payable {
        uint256 cost = publicCost * _mintAmount;
        mintCheck(_mintAmount, nextMintId, cost);
        require(!presale, "Public mint is paused while Presale is active.");
        require(
            _mintAmount <= publicMaxPerTx,
            "Mint amount cannot exceed 10 per Tx."
        );

        for (uint256 i = 1; i <= _mintAmount; i++) {
          _safeMint(msg.sender,  nextMintId);
          nextMintId++;
        }
    }

    // catlist mint
    function preMint(uint256 _mintAmount, bytes32[] calldata _merkleProof)
     public payable {
        uint256 cost = preCost * _mintAmount;
        mintCheck(_mintAmount, nextMintId, cost);
        require(presale, "Presale is not active.");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, leaf),
            "Invalid Merkle Proof"
        );

        require(
            whiteListClaimed[msg.sender] + _mintAmount <= presaleMaxPerWallet,
            "Address already claimed max amount"
        );

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, nextMintId );
            whiteListClaimed[msg.sender]++;
            nextMintId++;
        }
    }

    function mintCheck(
        uint256 _mintAmount,
        uint256 supply,
        uint256 cost
    ) private view {
        require(!paused, "Mint is not active.");
        require(_mintAmount > 0, "Mint amount cannot be zero");
        require(
            supply + _mintAmount <= maxMintId,
            "Total supply cannot exceed maxSupply"
        );
        require(msg.value >= cost, "Not enough funds provided for mint");
    }

    function ownerMint(uint256 count) public onlyOwner {

        for (uint256 i = 1; i <= count; i++) {
          _safeMint(msg.sender,  nextMintId+1);
          nextMintId++;
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function setPresale(bool _state) public onlyOwner {
        presale = _state;
    }

    function getCurrentCost() public view returns (uint256) {
        if (presale) {
            return preCost;
        } else {
            return publicCost;
        }
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

        // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }



    function withdraw() external onlyOwner {
        uint256 royalty = address(this).balance;
        Address.sendValue(payable(owner()), royalty);
    }

   /**
     * @notice Set the merkle root for the allow list mint
     */
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

}