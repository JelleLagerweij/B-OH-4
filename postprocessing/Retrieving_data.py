# -*- coding: utf-8 -*-
"""
Created on Wed Feb 15 14:29:42 2023

@author: Jelle
"""

import OCTP_postprocess_CLASS as octp

loc = '../stored/'

t = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 3, 5, 6, 7, 8, 9, 10, 12.5, 15,
     17.5, 20]

time = [0]*len(t)
for i in range(len(t)):
    time[i] = str(t[i]) + 'ns'

# for i in range(len(t)):
i = 18
folder = loc+time[i]  # Path to the main folder

f_runs = ['1', '3', '4']  # All internal runs
groups = ['wat', 'Li', 'S']

# Load the class
mixture = octp.PP_OCTP(folder, f_runs, groups, plotting=True)

# Change the file names
mixture.filenames(Diff_Onsag='onsagercoefficient.dat',
                  T_conduc='thermconductivity.dat')

mixture.changefit(Minc=12, Mmax=15)
mixture.pressure(mov_ave=100)
mixture.tot_energy(mov_ave=100)
mixture.pot_energy(mov_ave=100)
mixture.density()
mixture.molarity('S')
mixture.molality('S', 'wat', 18.01528)
mixture.viscosity()
# mixture.thermal_conductivity()
mixture.self_diffusivity(YH_correction=True, box_size_check=True)
mixture.onsager_coeff(box_size_check=True)

mixture.store(location='', name=time[i] + '.csv')
