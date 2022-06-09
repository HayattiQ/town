const CHAIN_ID = require("../constants/chainIds.json")

module.exports = async function (taskArgs, hre) {
    const signers = await ethers.getSigners()
    const owner = signers[0]
    const dstChainId = CHAIN_ID[taskArgs.targetNetwork]
    const tokenId = taskArgs.tokenId
    const exampleUniversalONFT = await ethers.getContract("VeryLongTown")
    console.log(`[source] exampleUniversalONFT.address: ${exampleUniversalONFT.address}`)

    let adapterParams = ethers.utils.solidityPack(["uint16", "uint256"], [1, 200000]) // default adapterParams example

    try {
        let tx = await (
            await exampleUniversalONFT.sendFrom(
                owner.address,
                dstChainId,
                owner.address,
                tokenId,
                owner.address,
                ethers.constants.AddressZero,
                adapterParams,
                {
                    value: ethers.utils.parseEther("1")
                }
            )
        ).wait()
        console.log(`✅ [${hre.network.name}] send(${dstChainId}, ${tokenId})`)
        console.log(` tx: ${tx.transactionHash}`)
    } catch (e) {

            console.log(e)

    }
}
