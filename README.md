HARP_Opt v3.0.0 (Release Candidate 1)
========

[HARP_Opt](http://wind.nrel.gov/designcodes/simulators/HARP_Opt/): An optimization tool for wind and water turbines.

## Current Maintainers
* [Danny Sale (University of Washington)](mailto:dsale@uw.edu)
* [Michael Lawson (National Renewable Energy Laboratory)](mailto:Michael.Lawson@nrel.gov)
* [Ye Li (National Renewable Energy Laboratory)](mailto:Ye.Li@nrel.gov)

## User Information
If you came to this page directly without going through the NWTC Information Portal, **we would appreciate if you could [report your user information](http://wind.nrel.gov/designcodes/simulators/HARP_Opt/downloaders/HARP_Opt_github_redirect.html) before cloning the repository**.  We use this information in order to allocate resources for supporting our software, and to notify users of critical updates.

## Prerequisites
**Users:**

* [Matlab Component Runtime v7.09](http://wind.nrel.gov/designcodes/miscellaneous/MatLab_MCRInstaller/)

**Developers:**

* C compiler
* Fortran compiler
* [WT_Perf](http://wind.nrel.gov/designcodes/simulators/wtperf/)
* [NWTC_Library](http://wind.nrel.gov/designcodes/miscellaneous/nwtc_subs/) 
* Matlab (optional toolboxes: Optimization, Global Optimization, Parallel Computing)

## Run Examples

From the Matlab prompt (compatible with Linux, Windows, and Mac), 

    $ HARP_Opt input_filename.inp

or from the Windows command prompt (using the compiled version)

    $ HARP_Opt_windows.exe input_filename.inp
