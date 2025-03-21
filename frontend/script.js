const contractAddress = "0x90de4B0d408f33c184E4E411D7b04F12D483e76C"; 
const abi = [];  // Add ABI here when needed

let web3;
let contract;
let userAccount = null;

async function connectMetaMask() {
    if (window.ethereum) {
        try {
            // Request account access
            const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
            let userAccount = accounts[0];

            // Display wallet address
            document.getElementById("walletAddress").innerText = `Connected: ${userAccount}`;
            
            console.log("Wallet Connected:", userAccount);
        } catch (error) {
            console.error("Error connecting to MetaMask:", error);
        }
    } else {
        alert("MetaMask not detected! Please install MetaMask.");
    }
}



async function mintNFT() {
    if (!userAccount) return alert("Connect MetaMask first!");
    
    const tokenURI = document.getElementById("tokenURI").value;
    await contract.methods.mintNFT(tokenURI).send({ from: userAccount });
    alert("NFT Minted!");
}

async function listNFT() {
    if (!userAccount) return alert("Connect MetaMask first!");

    const tokenId = document.getElementById("tokenIdList").value;
    const price = web3.utils.toWei(document.getElementById("nftPrice").value, "ether");
    await contract.methods.listNFT(tokenId, price).send({ from: userAccount });
    alert("NFT Listed for Sale!");
}

async function buyNFT() {
    if (!userAccount) return alert("Connect MetaMask first!");

    const tokenId = document.getElementById("tokenIdBuy").value;
    const price = await contract.methods.tokenPrices(tokenId).call();
    await contract.methods.buyNFT(tokenId).send({ from: userAccount, value: price });
    alert("NFT Purchased!");
}
