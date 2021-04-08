#!/usr/bin/bash
args=($@)
rm out.txt 2> /dev/null
if ! which ffuf > /dev/null || ! which jq > /dev/null || ! which nmap > /dev/null || ! which hashcat > /dev/null || ! which git > /dev/null; then
   echo -e "Some packages not found! Install? (y/n) \c"
   read
   if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ] 
then
      sudo apt install ffuf jq nmap hashcat hashcat-nvidia git -y >> /dev/null && exit 0
elif [ "$REPLY" = "n" ] || [ "$REPLY" = "" ]
	then
	exit 0
   fi
fi
if [[ $1 = "--help" ]] || [[ $1 = "-h" ]] || [[ $1 = "" ]]
then
echo "pohek (URL without https) (Path to the ffuf wordlist)"
echo  "--i or --install for installing to /usr/bin"
echo "--hashcat for the hashcat mode (hashcat hash id) (path for hash) (path for wordlist)"
echo "-d for downloading dictionaries into the current directory"
echo "--m8 for installing and compiling checkm8" && exit 0
elif [[ $1 = "-i" ]] || [[ $1 = "--install" ]]
then
if which /usr/bin/pohek > /dev/null
then
echo "pohek is installed!" && exit 1
fi
sudo cp pohek.* /usr/bin/pohek && sudo chmod 777 /usr/bin/pohek && exit 0
fi
if [[ $1 = "--hashcat" ]]
then
echo "hashcat mode!"
hashcat -m $2 -a 0 --quiet -o out-hash.txt -w 4 -O $3 $4
echo "hashcat done"
exit 0
fi
if [[ $1 = "-d" ]]
then
mkdir dicks
curl -L -s -o dicks/rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
curl -L -s -o dicks/large.txt https://raw.githubusercontent.com/avada-z/pohek/main/large.txt
curl -L -s -o dicks/small-test-only.txt https://raw.githubusercontent.com/avada-z/pohek/main/small.txt
exit 0
fi
if [[ $1 = "--m8" ]]
then
if [ ! -f /usr/bin/checkm8 ] > /dev/null
then
git clone https://github.com/pgarba/King.git .king
sudo apt install libusb-1.0-0-dev libusb-1.0-0 cmake -y
cd .king && mkdir build && cd build && cmake ../ && make
cp king /usr/bin/checkm8 && chmod 777 /usr/bin/checkm8
rm -rf .king
exit 0
else
echo "checkm8 is installed!"
exit 1
fi
fi
if [[ $1 !=  "--hashcat" ]]
then
nmap -O -sV $1 > out1.txt
echo "nmap done"
ffuf -u https://$1/FUZZ -w $2 -o $1.json $1.html -of json html -sf true -mc 200,403 >> /dev/null
echo "ffuf done"
for output in $(jq -r ".results[].input[]" $1.json);do echo $output > dirdar-$1.txt ;done
echo "ffuf output filtered"
dirdar -only-ok -wl dirdar-$1.txt -single https://$1/ > out3.txt
echo "dirdar done"
cat out1.txt out2.txt out3.txt out-hash.txt 1> out.txt
fi
rm out1.txt out2.txt out3.txt dirdar-$1.txt > /dev/null