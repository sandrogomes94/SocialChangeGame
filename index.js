var fs = require('fs');
const { Harmony } = require('@harmony-js/core');
const { BN } = require('@harmony-js/crypto');
const { ChainID, ChainType } = require('@harmony-js/utils');
const {	toWei, } = require('@harmony-js/utils');

window.addEventListener('DOMContentLoaded', (async() => {

const hmy =  new Harmony(
  'https://api.s0.b.hmny.io',
  {
    chainType: ChainType.Harmony,
    chainId: ChainID.HmyTestnet,
  },
);

const initializeContract = async ()=>{
    window.contract = fs.readFileSync(__dirname + '/SocialChangeGame.json', 'utf8');
    window.contract = JSON.parse(window.contract);
    const abi = window.contract.abi;
    const contractAddress = window.contract.networks['2'].address;
    const contractInstance = hmy.contracts.createContract(abi,contractAddress);
    return contractInstance;
}

window.contract = await initializeContract();

btn_claim = document.querySelector(".claim");
btn_claim.addEventListener("click", claim);
btn_join = document.querySelector(".join");
btn_join.addEventListener("click", join);

async function connect(){
    window.account = await onewallet.getAccount();
    console.log(window.account);
}

async function claim(){
    window.contract.wallet.signTransaction = async (tx)=>{
        tx.from = window.account.address;
        const signTx = await signTransaction(tx);
        console.log(signTx);
        return signTx;
    }
    const result = await window.contract.methods.claim().call();
    console.log(result.toString());
}

async function addMoney() {
    window.contract.wallet.signTransaction = async (tx)=>{
        tx.from = window.account.address;
        const signTx = await signTransaction(tx);
        console.log(signTx);
        return signTx;
    }
    let one = new BN('100');
    let options = {
		gasPrice: 1000000000,
		gasLimit: 210000,
		value: toWei(one, hmy.utils.Units.one),
    };    
    let increment = await window.contract.methods.join().send(options);
    console.log(increment);
}

async function signTransaction(txn) {
    return onewallet.signTransaction(txn);
}

}));