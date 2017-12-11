#!/bin/bash
#curl -H "Content-Type: application/json" -X POST -d '["height"]' http://localhost:8081/
#curl -H "Content-Type: application/json" -d '["mining_data"]' http://localhost:8081/

MiningData=$(curl -H "Content-Type: application/json" -d '["mining_data"]' http://localhost:8081/)

#echo $MiningData | sed -r 's/\[\"ok\",\[-6,\"//' | sed -r 's/\"//g' | sed -r 's/\]//g'

a=$(echo $MiningData | sed -r 's/\[\"ok\",\[-6,\"//' | sed -r 's/\"//g' | sed -r 's/\]//g')
first=$(echo $a | sed -r 's/,/\n/' | sed -r '2d')
second=$(echo $a | sed -r 's/,/\n/' | sed -r '1d')

echo $b
echo "first is "
echo $first
echo "second is "
echo $second

