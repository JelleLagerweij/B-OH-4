#!/bin/bash
runfile=$(expr runMD_D)	# Server where to run
dt=$(expr 1)			# Timestepsize 1fs
Nruneq=$(expr 10000)	# initiation timestep
Nrun1=$(expr 250000)		# dt*Nrun = 0.25 ns of data per run -3 zeros
Nrun2=$(expr 1000000)		# dt*Nrun = 1ns of data per run -3 zeros
Nrun3=$(expr 2500000)		# dt*Nrun = 2.5ns of data per run -3 zeros
Temp=$(expr 298.15)		# Temperature in K
Press=$(expr 1)			# Pressure in atm

N_wat=$(expr 500)		# Number of water molecules
N_salt=$(expr 9)		# Number of Na2BOH4's per 1m solution
n=$(expr 1)				# Number of Na's per salt molecule
m=$(expr 0)				# Concentration file to use


for folder in running
do
	mkdir $folder
	cd $folder

	for i in 5 6 7
	do
		mkdir $i
		cd $i

		# Coppying all needed files to run folder (alphabetical order)
		cp ../../input/$runfile runMD
		cp ../../input/simulation.in .
		cp ../../input/copy_files.sh .
		cp ../../input/forcefield.data .
		cp ../../input/Na.xyz .
		cp ../../input/params.ff .
		cp ../../input/BOH4.xyz .
		cp ../../input/water.xyz .

		# Set simulation_preprocessing.in file values
		randomNumber=$(shuf -i 1-100 -n1)
		sed -i 's/R_VALUE/'$randomNumber'/' simulation.in
		sed -i 's/T_VALUE/'$Temp'/' simulation.in
		sed -i 's/P_VALUE/'$Press'/' simulation.in
		sed -i 's/dt_VALUE/'$dt'/' simulation.in
		sed -i 's/Nrun_eq_VALUE/'$Nruneq'/' simulation.in
		sed -i 's/Nrun1_VALUE/'$Nrun1'/' simulation.in
		sed -i 's/Nrun2_VALUE/'$Nrun2'/' simulation.in
		sed -i 's/Nrun3_VALUE/'$Nrun3'/' simulation.in

		# Set filder location
		sed -i 's/run_FOLDER/'$i'/' copy_files.sh

		# Set runMD variables
		sed -i 's/JOB_NAME/Li2SO4 T is '${Temp%.*}' m is '$m' run '$i'/' runMD
		sed -i 's/INPUT/simulation.in/' runMD

		# Creating config folder
		mkdir config
		mv ./water.xyz config/
		mv ./params.ff config/
		mv ./BOH4.xyz config/
		mv ./Na.xyz config/
		cd config

		# compute total number of Li and SO4
		N_Na=$(($m*$N_salt*$n))
		N_BOH4=$(($m*$N_salt))

		# Create initial configuration using fftool and packmol
		~/software/lammps/la*22/fftool/fftool $N_wat water.xyz $N_Na Na.xyz $N_BOH4 BOH4.xyz -r 50 > /dev/null
		~/software/lammps/la*22/packmol*/packmol < pack.inp > packmol.out
		~/software/lammps/la*22/fftool/fftool $N_wat water.xyz $N_Na Na.xyz $N_BOH4 BOH4.xyz -r 50 -l > /dev/null

		# removing the force data from packmol as I use my own forcefield.data. copy data.lmp remove rest
		rm -f in.lmp
		rm -f *.xyz pa*
		sed -i '12,31d' ./data.lmp
		cp data.lmp ../data.lmp
		cd ..
		rm -r config

		# Commiting run and reporting that
		sbatch runMD
		echo "Runtask commited: T="$Temp", m="$m", run " $i"."
		cd ..
	done
	cd ..
done
cd ..
