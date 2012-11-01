#!/bin/sh


./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.101@tcp" -d 1:1 -t tcp_client1_to_oss1
./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.102@tcp" -d 1:1 -t tcp_client1_to_oss2
./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.103@tcp" -d 1:1 -t tcp_client1_to_oss3
./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.104@tcp" -d 1:1 -t tcp_client1_to_oss4

./sc12_test1.sh -c "192.168.0.110@tcp"  -s "192.168.0.101@tcp" -d 1:1 -t tcp_client2_to_oss1
./sc12_test1.sh -c "192.168.0.110@tcp"  -s "192.168.0.102@tcp" -d 1:1 -t tcp_client2_to_oss2
./sc12_test1.sh -c "192.168.0.110@tcp"  -s "192.168.0.103@tcp" -d 1:1 -t tcp_client2_to_oss3
./sc12_test1.sh -c "192.168.0.110@tcp"  -s "192.168.0.104@tcp" -d 1:1 -t tcp_client2_to_oss4

./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.101@tcp" -d 1:1 -t tcp_client1_to_oss1_D
./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.101@tcp 192.168.0.102@tcp" -d 1:2 -t tcp_client1_to_oss2_D
./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.101@tcp 192.168.0.102@tcp 192.168.0.103@tcp" -d 1:3 -t tcp_client1_to_oss3_D
./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.101@tcp 192.168.0.102@tcp 192.168.0.103@tcp 192.168.0.104@tcp" -d 1:4 -t tcp_client1_to_oss4_D

./sc12_test1.sh -c "192.168.0.110@tcp"  -s "192.168.0.101@tcp" -d 1:1 -t tcp_client2_to_oss1_D
./sc12_test1.sh -c "192.168.0.110@tcp"  -s "192.168.0.101@tcp 192.168.0.102@tcp" -d 1:2 -t tcp_client2_to_oss2_D
./sc12_test1.sh -c "192.168.0.110@tcp"  -s "192.168.0.101@tcp 192.168.0.102@tcp 192.168.0.103@tcp" -d 1:3 -t tcp_client2_to_oss3_D
./sc12_test1.sh -c "192.168.0.110@tcp"  -s "192.168.0.101@tcp 192.168.0.102@tcp 192.168.0.103@tcp 192.168.0.104@tcp" -d 1:4 -t tcp_client2_to_oss4_D

#./sc12_test1.sh -c "192.168.0.101@tcp"  -s "192.168.0.102@tcp" -d 1:1 -t tcp_oss1_to_oss2
#./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.101@tcp" -d 1:1 -t tcp_client1_to_oss1
#./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.101@tcp 192.168.0.102@tcp" -d 1:2 -t tcp_client1_to_oss12
#./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.101@tcp 192.168.0.102@tcp 192.168.0.103@tcp" -d 1:3 -t tcp_client1_to_oss123
#./sc12_test1.sh -c "192.168.0.109@tcp"  -s "192.168.0.101@tcp 192.168.0.102@tcp 192.168.0.103@tcp 192.168.0.104@tcp" -d 1:4 -t tcp_client1_to_oss1234

exit

# OSS1 to OSS2
#./sc12_test1.sh -c "192.168.0.101@o2ib"  -s "192.168.0.102@o2ib" -d 1:1 -t one
#./sc12_test1.sh -c "192.168.0.109@o2ib 192.168.0.110@o2ib"  -s "192.168.0.101@o2ib 192.168.0.102@o2ib 192.168.0.103@o2ib 192.168.0.104@o2ib" -d 2:4 -t two
#./sc12_test1.sh -c "192.168.0.101@o2ib"  -s "192.168.0.102@o2ib" -r -n
#./sc12_test1.sh -c "192.168.0.102@tcp"  -s "192.168.0.101@tcp" -r -n 8
