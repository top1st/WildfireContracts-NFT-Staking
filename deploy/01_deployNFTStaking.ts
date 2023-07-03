import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const tag = 'BondfireNFTStaking'
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  // code here
  const {deployments: {deploy, read}, getNamedAccounts} = hre
  const {deployer} = await getNamedAccounts()

  const deployed = await deploy("BondfireNFTStaking", {
    from: deployer,
    contract: "BondfireNFTStaking",
    proxy: {
      proxyContract: 'UUPS',
      execute: {
        init: {
          methodName: "initialize",
          args: []
        }
      },
    }
  })

  console.log(deployed.implementation, deployed.address)
};
export default func;