#!/bin/bash

# This is a script that converts the raw data file of Illumina sequencer, to the ENA format. 
# In case of P.E.M.A. the ENA format was used as a template.
# All sample files that are going to be used in running P.E.M.A., they need to be in the ENA format.


directory=${1}

# set the directoryPath the proper way no matter how the path was given by the user
if [ ${directory:1} == "/" ]
then
	directoryPath=$directory
else
	cd $directory
	directoryPath=$(pwd)
fi


if [ ${directoryPath: -1} == "/" ]
then
	directoryPath=${directoryPath::-1}
fi

cd $directoryPath

# decompress the initial raw data that the sequencer returned
for file in ./*
do
	gunzip "$file"
done



# convert them in the ENA format
let counter=-1
let giveName=0

for sample in ./*
do
    ((counter+=1))
    echo counter = $counter
    let test=$counter%2
    echo test = $test

    if [ "$test" -eq "0" ]
    then
        ((giveName+=1))
    fi                              # i added this counter

    echo giveName = $giveName

	sampleName=${sample##*/}            # i added a "#"
	sampleId=${sampleName%%_*}
	newName="ERR0000"$giveName           # i inserted this variable 
    echo $sample
	if [ ${sample: -7}=="1.fastq" ]
	then
		
        # i muted the line below, and i replaced it with the same but this time we call the files and the sequences with the newName variable. In addition, in the next command I also put "newName" where it used to be "sampleId"
		#sed "s/^@M0.*/@$sampleId\./g" $sampleName > $directoryPath/"half_${sampleId}_1.fastq"	
		sed "s/^@M0.*/@$newName\./g" $sampleName > $directoryPath/"half_${sampleName}_1.fastq"	
		awk 'BEGIN{b = 1; c = 1} {if (NR % 4 == 1) {print $0 b++ " "c++"/1"} else print $0}' half_"${sampleName}"\_1.fastq  > $directoryPath/ena_"${newName}"\_1.fastq 
		
	fi
	
	if [ ${sample: -7}=="2.fastq" ]
	then
		
		#sed "s/^@M0.*/@$sampleId\./g" $sampleName > $directoryPath/"half_${sampleId}_2.fastq"
		sed "s/^@M0.*/@$newName\./g" $sampleName > $directoryPath/"half_${newName}_2.fastq"
		awk 'BEGIN{b = 1; c = 1} {if (NR % 4 == 1) {print $0 b++ " "c++"/2"} else print $0}' half_"${newName}"\_2.fastq  > $directoryPath/ena_"${newName}"\_2.fastq
		
	fi
done



# remove some temp files created and move the converted files to a new folder
rm half_*
mkdir rawDataInEnaFormat
mv ena_* rawDataInEnaFormat
cd rawDataInEnaFormat

# give the initial samples names to the converted files and compress them
for filename in ./*; do mv "./$filename" "./$(echo "$filename" | sed -e 's/ena_//g')";  done
gzip *

# compress the initial files
cd $directoryPath
gzip *.fastq
