echo "Clearing deployed contracts"
rm ./build/contracts/* ./build/contracts/.* 
rmdir ./build/contracts/

echo "Clearing dapp client config"
file= ./src/dapp/config.json

if [ -f "$file" ] ; then
    rm "$file"
fi


echo "Clearning server config"
file= ./src/server/config.json

if [ -f "$file" ] ; then
    rm "$file"
fi
