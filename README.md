#Introduction
HARP_Opt (**H**orizontal **A**xis **R**otor **P**erformance **Opt**imization) utilizes MATLAB's optimization algorithms and the National Renewable Energy Laboratory's [WT-Perf](http://wind.nrel.gov/designcodes/simulators/wtperf/) blade element momentum (BEM) code to design axial-flow wind and water (i.e. hydrokinetic) turbine rotors.

The code optimizes a rotor's performance for steady and uniform flows (no sheared or yawed flows). A variety of rotor control configurations can be designed using HARP_Opt, including fixed or variable rotor speed and fixed or variable blade pitch configuration and blades with circular or non-circular roots are supported.

HARP_Opt can function as a single- or multiple-objective optimization code. The primary optimization objective is to maximize the turbine's annual energy production (AEP). Annual energy production is calculated using a Rayleigh, Weibull, or user-defined flow distribution. Maximum power is bounded, and maximum power point tracking (MPPT) is a combined objective with AEP. For hydrokinetic turbines, additional constraints are defined such that cavitation will not occur. An additional objective can be activated, in which HARP_Opt performs a structural optimization to minimize the blade mass. For the structural analysis, the blade is modeled as a thin shell of bulk isotropic material, and the blade mass is minimized using a maximum allowable strain as the constraint. Maximizing energy production and minimizing blade mass are conflicting objectives, thus HARP_Opt will identify the set of Pareto optimal solutions. To meet these objectives, HARP_Opt calculates the optimal blade shape (twist, chord, and airfoil/hydrofoil distributions) and optimal control of the rotor speed and blade pitch.

The HARP_Opt project was funded by the US Department of Energy [Water Power Program](http://www1.eere.energy.gov/water/). Code developemnt and testing was performed at the NREL and the University of Tennessee.

#Download
Current Version:
[v3.0.0 (Release Candidate 1)](https://github.com/NREL/HARP_Opt)

Previous Versions:
[v2.0.0](http://wind.nrel.gov/designcodes/simulators/HARP_Opt/)

#Installing and Running HARP_Opt
See the [HARP-Opt GitHub Wiki](https://github.com/NREL/HARP_Opt/wiki/).

#Documentation
Documentation for v3.0.0 is currently under development

#Current Code Maintainers
* [Danny Sale](mailto:dsale@uw.edu) (University of Washington)
* [Michael Lawson](mailto:Michael.Lawson@nrel.gov) (National Renewable Energy Laboratory)

#Project Contributors
* Danny Sale (University of Washington)
* Michael Lawson (National Renewable Energy Laboratory)
* Jason Jonkman (National Renewable Energy Laboratory)
* David Maniaci (Sandia National Laboratories)
* Marshall Buhl (National Renewable Energy Laboratory)
