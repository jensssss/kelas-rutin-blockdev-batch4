// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LiskGarden {

    // ============================================
    // BAGIAN 1: ENUM & STRUCT
    // ============================================
    
    // Enum untuk 4 stage pertumbuhan
    enum GrowthStage { SEED, SPROUT, GROWING, BLOOMING }

    // Struct untuk data tanaman
    struct Plant {
        uint256 id;
        address owner;
        GrowthStage stage;
        uint256 plantedDate;
        uint256 lastWatered;
        uint8 waterLevel;
        bool exists;
        bool isDead;
    }

    // ============================================
    // BAGIAN 2: STATE VARIABLES
    // ============================================
    
    // Mapping plantId ke Plant
    mapping(uint256 => Plant) public plants;

    // Mapping address ke array plantId (track tanaman user)
    mapping(address => uint256[]) public userPlants;

    // Counter untuk ID tanaman baru
    uint256 public plantCounter;

    // Address owner contract
    address public owner;


    // ============================================
    // BAGIAN 3: CONSTANTS (Game Parameters)
    // ============================================
    
    // Harga tanam = 0.001 ether
    uint256 public constant PLANT_PRICE = 0.001 ether;

    // Reward panen = 0.003 ether
    uint256 public constant HARVEST_REWARD = 0.003 ether;

    // Durasi per stage = 1 menit
    uint256 public constant STAGE_DURATION = 1 minutes;

    // Waktu deplesi air = 30 detik
    uint256 public constant WATER_DEPLETION_TIME = 30 seconds;

    // Rate deplesi = 2 (2% setiap interval)
    uint8 public constant WATER_DEPLETION_RATE = 2;


    // ============================================
    // BAGIAN 4: EVENTS
    // ============================================
    
    event PlantSeeded(address indexed owner, uint256 indexed plantId);
    event PlantWatered(uint256 indexed plantId, uint8 newWaterLevel);
    event PlantHarvested(uint256 indexed plantId, address indexed owner, uint256 reward);
    event StageAdvanced(uint256 indexed plantId, GrowthStage newStage);
    event PlantDied(uint256 indexed plantId);


    // ============================================
    // BAGIAN 5: CONSTRUCTOR
    // ============================================
    
    constructor() {
        owner = msg.sender;
    }

    // ============================================
    // BAGIAN 6: PLANT SEED (Fungsi Utama #1)
    // ============================================
    
    function plantSeed() external payable returns (uint256) {
        // 1. require msg.value >= PLANT_PRICE
        require(msg.value >= PLANT_PRICE, "ETH tidak cukup untuk menanam");

        // 2. Increment plantCounter
        plantCounter++;
        uint256 newPlantId = plantCounter;

        // 3. Buat Plant baru dengan struct
        Plant memory newPlant = Plant({
            id: newPlantId,
            owner: msg.sender,
            stage: GrowthStage.SEED,
            plantedDate: block.timestamp,
            lastWatered: block.timestamp,
            waterLevel: 100,
            exists: true,
            isDead: false
        });

        // 4. Simpan ke mapping plants
        plants[newPlantId] = newPlant;

        // 5. Push plantId ke userPlants
        userPlants[msg.sender].push(newPlantId);

        // 6. Emit PlantSeeded
        emit PlantSeeded(msg.sender, newPlantId);

        // 7. Return plantId
        return newPlantId;
    }

    // ============================================
    // BAGIAN 7: WATER SYSTEM (3 Fungsi)
    // ============================================


    function calculateWaterLevel(uint256 plantId) public view returns (uint8) {
        // 1. Ambil plant dari storage
        Plant memory plant = plants[plantId];

        // 2. Jika !exists atau isDead, return 0
        if (!plant.exists || plant.isDead) {
            return 0;
        }

        // 3. Hitung timeSinceWatered = block.timestamp - lastWatered
        uint256 timeSinceWatered = block.timestamp - plant.lastWatered;

        // 4. Hitung depletionIntervals = timeSinceWatered / WATER_DEPLETION_TIME
        uint256 depletionIntervals = timeSinceWatered / WATER_DEPLETION_TIME;

        // 5. Hitung waterLost = depletionIntervals * WATER_DEPLETION_RATE
        uint256 waterLost = depletionIntervals * WATER_DEPLETION_RATE;

        // 6. Jika waterLost >= waterLevel, return 0
        if (waterLost >= plant.waterLevel) {
            return 0;
        }

        // 7. Return waterLevel - waterLost
        return plant.waterLevel - uint8(waterLost);
    }

    function updateWaterLevel(uint256 plantId) internal {
        // 1. Ambil plant dari storage
        Plant storage plant = plants[plantId];
        
        // 2. Hitung currentWater dengan calculateWaterLevel
        uint8 currentWater = calculateWaterLevel(plantId);

        // 3. Update plant.waterLevel
        plant.waterLevel = currentWater;

        // 4. Jika currentWater == 0 && !isDead, set isDead = true dan emit PlantDied
        if (currentWater == 0 && !plant.isDead) {
            plant.isDead = true;
            emit PlantDied(plantId);
        }
    }

    function waterPlant(uint256 plantId) external {
        // 1. require exists
        // 2. require owner == msg.sender
        // 3. require !isDead
        // Ambil dari storage untuk modifikasi
        Plant storage plant = plants[plantId];
        require(plant.exists, "Tanaman tidak ada");
        require(plant.owner == msg.sender, "Anda bukan pemilik tanaman ini");
        require(!plant.isDead, "Tanaman sudah mati");

        // 4. Set waterLevel = 100
        plant.waterLevel = 100;

        // 5. Set lastWatered = block.timestamp
        plant.lastWatered = block.timestamp;

        // 6. Emit PlantWatered
        emit PlantWatered(plantId, plant.waterLevel);
        
        // 7. Call updatePlantStage
        updatePlantStage(plantId);
    }

    // ============================================
    // BAGIAN 8: STAGE & HARVEST (2 Fungsi)
    // ============================================

    function updatePlantStage(uint256 plantId) public {
        // 1. require exists
        Plant storage plant = plants[plantId];
        require(plant.exists, "Tanaman tidak ada");

        // 2. Call updateWaterLevel
        updateWaterLevel(plantId);

        // 3. Jika isDead, return
        if (plant.isDead) {
            return;
        }

        // 4. Hitung timeSincePlanted
        uint256 timeSincePlanted = block.timestamp - plant.plantedDate;

        // 5. Simpan oldStage
        GrowthStage oldStage = plant.stage;

        // 6. Update stage berdasarkan waktu (3 if statements)
        if (timeSincePlanted >= STAGE_DURATION * 3) { // 3 menit
            plant.stage = GrowthStage.BLOOMING;
        } else if (timeSincePlanted >= STAGE_DURATION * 2) { // 2 menit
            plant.stage = GrowthStage.GROWING;
        } else if (timeSincePlanted >= STAGE_DURATION) { // 1 menit
            plant.stage = GrowthStage.SPROUT;
        }
        // Jika kurang dari 1 menit, tetap SEED (default)

        // 7. Jika stage berubah, emit StageAdvanced
        if (plant.stage != oldStage) {
            emit StageAdvanced(plantId, plant.stage);
        }
    }

    function harvestPlant(uint256 plantId) external {
        // 1. require exists
        Plant storage plant = plants[plantId];
        require(plant.exists, "Tanaman tidak ada");

        // 2. require owner
        require(plant.owner == msg.sender, "Anda bukan pemilik tanaman ini");

        // 3. require !isDead
        require(!plant.isDead, "Tanaman sudah mati");

        // 4. Call updatePlantStage
        updatePlantStage(plantId);

        // 5. require stage == BLOOMING
        require(plant.stage == GrowthStage.BLOOMING, "Tanaman belum siap panen");

        // 6. Set exists = false
        plant.exists = false;

        // 7. Emit PlantHarvested
        emit PlantHarvested(plantId, plant.owner, HARVEST_REWARD);

        // 8. Transfer HARVEST_REWARD dengan .call
        (bool success, ) = msg.sender.call{value: HARVEST_REWARD}("");
        
        // 9. require success
        require(success, "Transfer reward gagal");
    }

    // ============================================
    // HELPER FUNCTIONS (Sudah Lengkap)
    // ============================================


    function getPlant(uint256 plantId) external view returns (Plant memory) {
        Plant memory plant = plants[plantId];
        // Selalu hitung level air terbaru saat dilihat
        plant.waterLevel = calculateWaterLevel(plantId);
        return plant;
    }

    function getUserPlants(address user) external view returns (uint256[] memory) {
        return userPlants[user];
    }


    function withdraw() external {
        require(msg.sender == owner, "Bukan owner");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer gagal");
    }

    receive() external payable {}
}