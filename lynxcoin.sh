#!/bin/bash

# Set variables
REPO_URL="https://github.com/lynxgeeknyc/lynxcoin.git"
NEW_NAME="LynxCoin"
TOTAL_SUPPLY=10000000000
INITIAL_BLOCK_REWARD=50
INITIAL_DIFFICULTY="0x1d00ffff"

# Update system and install dependencies
sudo apt-get update
sudo apt-get install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 libssl-dev libevent-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev libboost-thread-dev

# Clone the Bitcoin repository
git clone $REPO_URL $NEW_NAME
cd $NEW_NAME

# Rename to LynxCoin
find . -type f -exec sed -i 's/Bitcoin/LynxCoin/g' {} +
find . -type f -exec sed -i 's/bitcoin/lynxcoin/g' {} +
mv src/bitcoind.cpp src/lynxcoind.cpp
mv src/bitcoin-cli.cpp src/lynxcoin-cli.cpp

# Modify total supply and block reward
sed -i "s/21000000/$TOTAL_SUPPLY/g" src/amount.h
sed -i "s/50 \* COIN/$INITIAL_BLOCK_REWARD \* COIN/g" src/validation.cpp

# Modify initial difficulty
sed -i "s/0x1d00ffff/$INITIAL_DIFFICULTY/g" src/pow.cpp

# Build the source code
./autogen.sh
./configure
make
sudo make install

# Initial configuration
mkdir -p ~/.lynxcoin
cat <<EOF > ~/.lynxcoin/lynxcoin.conf
server=1
listen=1
daemon=1
rpcuser=user
rpcpassword=password
gen=1
difficulty=1
EOF

# Start LynxCoin daemon
lynxcoind -daemon

echo "$NEW_NAME has been set up with the following configurations:"
echo "Total Supply: $TOTAL_SUPPLY"
echo "Initial Block Reward: $INITIAL_BLOCK_REWARD"
echo "Initial Difficulty: $INITIAL_DIFFICULTY"
echo "Configuration file created at ~/.lynxcoin/lynxcoin.conf"

# Print completion message
echo "LynxCoin setup is complete. You can check the logs in ~/.lynxcoin/debug.log"
