infilename=$1
outfilename=$2
binsize=$3

chro=1
seg=1
while [ $chro -le 18 ]
do
	plink -bfile $infilename --chr $chro --make-bed --out ${outfilename}_chro$chro
	L=$(tail -n 1 ${outfilename}_chro$chro.bim | cut -f 4)
	beg=1
	end=$binsize
	while [ $beg -le $L ]
	do
		plink -bfile ${outfilename}_chro$chro --chr $chro --from-bp $beg --to-bp $end --make-bed --out ${outfilename}_seg$seg
		beg=$[$beg+$binsize]
		end=$[$end+$binsize]
		seg=$[$seg+1]
	done
	rm ${outfilename}_chro$chro.*
	chro=$[$chro+1]
done
echo $seg
