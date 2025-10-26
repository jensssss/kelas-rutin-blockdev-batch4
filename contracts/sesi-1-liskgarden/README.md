# 🌿 LiskGarden - Smart Contract Game

This is a smart contract for a simple farming simulation game. The core of the code is to manage the lifecycle of a plant: planting, watering, growing, and harvesting.

## 🕹️ How to Play

The game mechanics are simple:

1.  **Plant:** You pay **0.001 ETH** to call `plantSeed()` and plant 1 new seed.
2.  **Grow:** Your plant grows in 4 stages: `SEED` -> `SPROUT` -> `GROWING` -> `BLOOMING`. Each stage takes **1 minute**.
3.  **Water:** The plant **loses 2% water every 30 seconds**. You must call `waterPlant()` to water it (refilling water to 100%).
4.  **Death:** If the plant's water level reaches **0%**, the plant becomes `isDead = true` and cannot be harvested.
5.  **Harvest:** Once the plant reaches the `BLOOMING` stage (after 3 minutes) and is still alive, you can call `harvestPlant()`.
6.  **Profit:** You will receive a **0.003 ETH** reward upon a successful harvest.

## 🚀 Quick Test Guide (Remix)

1.  **Deploy** the `LiskGarden.sol` contract to the Lisk Sepolia Testnet.
2.  **‼️ IMPORTANT: FUND THE CONTRACT!**
    * Send some ETH (e.g., **0.01 ETH**) from your MetaMask wallet to the **contract address** you just deployed. This is required so the contract has funds to pay the harvest reward.
3.  **Plant a Seed:**
    * Fill in `0.001` in the `VALUE` box and select `ether`.
    * Call `plantSeed()`.
    * You will get `plantId: 1`.
4.  **Harvest:**
    * Wait for **3 full minutes**.
    * Call `harvestPlant(1)`.
    * Your transaction will succeed, and your wallet balance will increase by 0.003 ETH.

## 📖 Function Explanations

Here is what each main function in the contract does:

### Main Game Functions

* `plantSeed()`: (Payable) Pay 0.001 ETH to create a new plant (new ID, set `stage` to `SEED`, `waterLevel` to 100).
* `waterPlant(uint256 plantId)`: Refills the plant's `waterLevel` (by ID) back to 100% and resets the `lastWatered` timer.
* `harvestPlant(uint256 plantId)`: (Payable Out) Checks if the plant (by ID) is ready for harvest. If yes (`BLOOMING` and not dead), it sends 0.003 ETH to your wallet and removes the plant (`exists = false`).
* `updatePlantStage(uint256 plantId)`: A public function to check how long the plant has been planted and then update its growth `stage` (SEED -> SPROUT, etc.).

### Helper (View) Functions

* `calculateWaterLevel(uint256 plantId)`: (View) A read-only function to calculate the plant's current water level in real-time based on when it was last watered.
* `getPlant(uint256 plantId)`: (View) Fetches all data for a single plant (including its latest `waterLevel`).
* `getUserPlants(address user)`: (View) Shows all plant IDs owned by a specific address.

### Admin Function

* `withdraw()`: (Owner Only) Only the contract owner can call this to withdraw all remaining ETH balance from the contract.