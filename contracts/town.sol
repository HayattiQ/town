// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "./onft/extension/UniversalONFT721.sol";

/// @title A LayerZero UniversalONFT example
/// @notice You can use this to mint ONFT and send nftIds across chain.
///  Each contract deployed to a chain should carefully set a `_startMintIndex` and a `_maxMint`
///  value to set a range of allowed mintable nftIds (so that no two chains can mint the same id!)
contract town is UniversalONFT721 {
    constructor(address _layerZeroEndpoint, uint _startMintId, uint _endMintId) UniversalONFT721("ExampleUniversalONFT721", "ONFT721", _layerZeroEndpoint, _startMintId, _endMintId) {}
}
