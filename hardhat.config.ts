import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { PRIVATE_KEY, API_URL } from "./secret.json";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  defaultNetwork: "sepolia",
  networks: {
    sepolia: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: "4MDUTRZSE2I8SJ435RVFWBMY76IC9E6XVY"
  }
};

export default config;
