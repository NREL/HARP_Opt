#Introduction
HARP_Opt (**H**orizontal **A**xis **R**otor **P**erformance **Opt**imization) utilizes MATLAB's optimization algorithms and the National Renewable Energy Laboratory's (NREL) [WT-Perf](http://wind.nrel.gov/designcodes/simulators/wtperf/) blade element momentum (BEM) code to design axial-flow wind and water (i.e. hydrokinetic) turbine rotors.

The code optimizes a rotor's performance for steady and uniform flows (no sheared or yawed flows). A variety of rotor control configurations can be designed using HARP_Opt, including fixed or variable rotor speed and fixed or variable blade pitch configuration. Blades with circular or non-circular roots are also supported.

HARP_Opt can function as a single- or multiple-objective optimization code. The primary optimization objective is to maximize the turbine's annual energy production (AEP). Annual energy production is calculated using a Rayleigh, Weibull, or user-defined flow distribution. Maximum power is bounded, and maximum power point tracking (MPPT) is a combined objective with AEP. For hydrokinetic turbines, additional constraints are defined such that cavitation will not occur. An additional objective can be activated, in which HARP_Opt performs a structural optimization to minimize the blade mass. For the structural analysis, the blade is modeled as a thin shell of bulk isotropic material, and the blade mass is minimized using a maximum allowable strain as the constraint. Maximizing energy production and minimizing blade mass are conflicting objectives, thus HARP_Opt will identify the set of Pareto optimal solutions. To meet these objectives, HARP_Opt calculates the optimal blade shape (twist, chord, and airfoil/hydrofoil distributions) and optimal control of the rotor speed and blade pitch.

The HARP_Opt project was funded by the US Department of Energy [Water Power Program](http://www1.eere.energy.gov/water/). Code development and testing was performed at the NREL and the University of Tennessee.

#Download
Current Version:
[v3.0.0 (Release Candidate 1)](https://github.com/NREL/HARP_Opt)

Previous Versions:
[v2.0.0](http://wind.nrel.gov/designcodes/simulators/HARP_Opt/)

#Installing and Running HARP_Opt
See the [HARP-Opt GitHub Wiki](https://github.com/NREL/HARP_Opt/wiki/).

HARP_Opt should work with any modern version of Matlab, or can be compiled
as standalone executable for Windows and Unix.  If you plan to run the compiled
versions, you need to install the Matlab Component Runtime (MCR).  And, if you 
want to re-compile HARP_Opt you will need the Matlab Compiler toolbox.
Here are the corresponding versions of HARP_Opt, Matlab and MCR, and Compiler (see download links for MCR):

| HARP_Opt  | MATLAB Release   | MATLAB  MCR     | MATLAB Compiler  |
| --------- | ---------------- | --------------- | ---------------- |
| 1.0       | R2008b (7.7)     | [7.9](https://nwtc.nrel.gov/MatLab_MCRInstaller)             | 4.9              |
| 2.0       | R2011b (7.13)    | [7.16](https://nwtc.nrel.gov/MatLab_MCRInstaller)            | 4.16             |
| 3.0       | R2013a (8.1)     | [8.1](http://www.mathworks.com/products/compiler/mcr/)             | 4.18.1           |

#Documentation
Documentation for v3.0.0 is currently under development. See the alpha change log which describes
major updates since version 2. [alpha change log](https://github.com/NREL/HARP_Opt/blob/master/Documentation/alpha_change_log.txt)

#Current Code Maintainers
* [Danny Sale](mailto:dsale@uw.edu) (University of Washington)
* [Michael Lawson](mailto:Michael.Lawson@nrel.gov) (National Renewable Energy Laboratory)

#Project Contributors
* Danny Sale (University of Washington)
* Michael Lawson (National Renewable Energy Laboratory)
* Jason Jonkman (National Renewable Energy Laboratory)
* David Maniaci (Sandia National Laboratories)
* Marshall Buhl (National Renewable Energy Laboratory)
