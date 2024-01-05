module.exports = async ({ getNamedAccounts, deployments, network, ethers }) => {
  if (network.tags.production) {
    const { deployer } = await getNamedAccounts();
    const { deploy, execute } = deployments;

    const stakingToken = process.env.LP_TOKEN_ADDRESS;
    const rewardToken = process.env.REWARD_TOKEN_ADDRESS;
    const adminWallet = process.env.ADMIN_WALLET_ADDRESS;
    const rewardsDuration = 432000; // 5 วัน
    await deploy("Staking", {
      args: [rewardToken, stakingToken, rewardsDuration, adminWallet],
      from: deployer,
      log: true,
    });

  }
};
module.exports.tags = ["Staking"];

