#!/usr/bin/bash
args=($@)
rm out.txt >> /dev/null
if ! which ffuf > /dev/null || ! which jq > /dev/null || ! which nmap > /dev/null || ! which hashcat > /dev/null; then
   echo -e "Some packages not found! Install? (y/n) \c"
   read
   if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ] 
then
      sudo apt install ffuf jq nmap hashcat hashcat-nvidia -y >> /dev/null && exit 0
elif [ "$REPLY" = "n" ] || [ "$REPLY" = "" ]
	then
	exit 0
   fi
fi
if [[ $1 = "--help" ]] || [[ $1 = "-h" ]] || [[ $1 = "" ]]
then
echo "pohek (URL without https) (Path to the ffuf wordlist) or --i or --install for installing to /usr/bin; --hashcat for the hashcat mode (hashcat hash id) (path for hash) (path for wordlist)" && exit 0
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
if [[$1 !=  "--hashcat" ]]
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