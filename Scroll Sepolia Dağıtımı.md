# Scroll Sepholia Dağıtımı

Bu proje, Scroll Sepolia test ağında basit bir Merkeziyetsiz Otonom Organizasyon (DAO) akıllı sözleşmesinin nasıl oluşturulacağını, dağıtılacağını ve test edileceğini göstermektedir.

## İçindekiler

- [Geliştirme Ortamının Kurulumu](#geliştirme-ortamının-kurulumu)
- [Hardhat Yapılandırması](#hardhat-yapılandırması)
- [.env Dosyasının Oluşturulması](#env-dosyasının-oluşturulması)
- [Sözleşmenin Derlenmesi ve Dağıtılması](#sözleşmenin-derlenmesi-ve-dağıtılması)
- [Sözleşmenin Doğrulanması](#sözleşmenin-doğrulanması)
- [Sözleşmenin Test Edilmesi](#sözleşmenin-test-edilmesi)

## Geliştirme Ortamının Kurulumu

1. Node.js ve npm'in yüklü olduğundan emin olun.

2. Hardhat'i global olarak yükleyin:
`npm install -g hardhat`

3. Yeni bir proje dizini oluşturun ve içine girin:

`mkdir scroll-dao-project`
`cd scroll-dao-project`

4. Hardhat projesini başlatın:
`npx hardhat init`

5. Gerekli bağımlılıkları yükleyin:
`npm install @openzeppelin/contracts dotenv @nomiclabs/hardhat-etherscan`

## Hardhat Yapılandırması

`hardhat.config.js` dosyasını aşağıdaki gibi düzenleyin:

```javascript
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config();

module.exports = {
solidity: "0.8.25",
networks: {
 scrollSepolia: {
   url: process.env.SCROLL_SEPOLIA_RPC_URL,
   accounts: [process.env.PRIVATE_KEY]
 }
},
etherscan: {
 apiKey: process.env.ETHERSCAN_API_KEY
}
};
```
.env  `.env` Dosyasının Oluşturulması
Proje kök dizininde .env dosyası oluşturun ve aşağıdaki bilgileri ekleyin:
```
PRIVATE_KEY=your_wallet_private_key
SCROLL_SEPOLIA_RPC_URL=https://sepolia-rpc.scroll.io/
ETHERSCAN_API_KEY=your_etherscan_api_key
```
# Sözleşmenin Derlenmesi ve Dağıtılması

`scripts/deploy.js` adında bir dağıtım betiği oluşturun:

javascriptCopyconst hre = require("hardhat");
```javascript
async function main() {
  const SimpleDAO = await hre.ethers.getContractFactory("SimpleDAO");
  const simpleDAO = await SimpleDAO.deploy(ethers.utils.parseEther("0.1")); // 0.1 ETH üyelik ücreti


  await simpleDAO.deployed();

  console.log("SimpleDAO deployed to:", simpleDAO.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

# Sözleşmeyi derlemek ve dağıtmak için:
```
Copynpx hardhat compile
npx hardhat run scripts/deploy.js --network scrollSepolia
```
# Sözleşmenin Doğrulanması
Sözleşmeyi Scroll Sepolia Etherscan'de doğrulamak için:
Copynpx hardhat verify --network scrollSepolia DEPLOYED_CONTRACT_ADDRESS "100000000000000000"
# Sözleşmenin Test Edilmesi

Hardhat konsolunu başlatın:
```
Copynpx hardhat console --network scrollSepolia
```

Konsol içinde aşağıdaki komutları çalıştırın:
```javascript
javascriptCopyconst SimpleDAO = await ethers.getContractFactory("SimpleDAO");
const simpleDAO = await SimpleDAO.attach("DEPLOYED_CONTRACT_ADDRESS");

// Üyelik katılımı
await simpleDAO.joinDAO({value: ethers.utils.parseEther("0.1")});

// Teklif oluşturma
await simpleDAO.createProposal("Test Proposal", 86400);

// Oylama
await simpleDAO.vote(0, true);

// Teklif detaylarını alma
const proposalDetails = await simpleDAO.getProposalDetails(0);
console.log(proposalDetails);
```
Bu adımları takip ederek, SimpleDAO sözleşmenizi Scroll Sepolia test ağına başarıyla dağıtabilir, doğrulayabilir ve test edebilirsiniz.
