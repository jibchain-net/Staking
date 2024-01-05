module.exports = async ({ getNamedAccounts, deployments }) => {
  if (network.tags.production) {
    const { deployer } = await getNamedAccounts();
    const { deploy } = deployments;
    await deploy("MockRW", {
      contract: "MockRW",
      args: [],
      from: deployer,
      log: true,
    });    
    await deploy("MockST", {
      contract: "MockST",
      args: [],
      from: deployer,
      log: true,
    });    
  }
};
module.exports.tags = ["MockERC20"];
