Author: Rafael Camacho
github: camachodejay
date:   2019 - 07 - 03
current address: Centre for cellular imaging - Göteborgs universitet


Iterates over all aggregate ROIs stored and calculates S and P according
to https://doi.org/10.2976/1.2834817

This program asks for a main directory, which must hold a number of
subfolders containing 'ROIs' in their name. If such folder exist then
it loads the ROIs-tif and calculates the parameters S and P. S is
related to the scattering energy ratio between red and green channels,
and P to the dipole (like) moment of the image between red and green
channel.
