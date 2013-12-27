# HARP_Opt wishlist #

#### HARP_Opt v3.0.0 (this will be the first GitHub Tag) ####

* __[documentation]__ make sure GitHub account is setup properly for easier collaborative development. Suggest according to [Vincent Driessen's git branching model](http://nvie.com/posts/a-successful-git-branching-model/)

* __[refactor]__ take one more pass through the source code and combine functions into a single file where appropriate

* __[bug]__ remove any unintended debug messages printed to the console, including for parallel runs. Parallel runs may require an alternate method for console output?

* __[bug]__ single objective optimization does not yet produce the plots in outputFun_custom.m

* __[documentation]__ unify built-in documentation inside the input files (some files may have slightly different descriptions of the input parameters)

* __[feature]__ add some error checking on the user inputs.  Matlab has __ASSERT statements__ that would be best suited for this

* __[bug]__ when compiled, the Multi-Objective Genetic Algorithm gives some errors...
	it works fine in the non-compiled version though.  This error appears when
	changing 'SelectionFcn' to anything other than @selectionuniform, try compiling in a different version of Matlab? suggest r2013b or pre-R2011b

* __[feature]__ fix the horrible thickness distributions (prone to large curvature which is bad)
this problem can be fixed by careful user inputs, but we need a more foolproof way:
 * define the dimensional thickness by Bezier/Akima curve first, derive the non-dim thickness afterwards...this should fix the problem nicely and provide better structural designs

* __[feature]__ add Akima curves for easier/better handling of constraints, and will allow users to import existing blade designs into HARP_Opt (as initial seeds)

* __[feature]__ allow seeding of the initial point in the initial population (do this like in CoBlade v1.30+)

* __[documentation]__ compile a FAQ list from email and forum archives...post to GitHub wiki/issues

* __[feature]__ fully coupled to Co-Blade after move Co-Blade v2.0.0 to GitHub	

* __[feature]__ add NREL 5MW example and Sandia 100MW (or other more important reference models?)

* __[feature]__ add most recent collection of airfoil data (force coefficients and coordinates)

#### **FUTURE WORK HARP_Opt v3+** ####

* __[feature]__ add option to use [CCBlade](https://github.com/NREL-WISDEM/CCBlade) instead of WT_Perf.  This should be much faster and more robust. ;-)

* __[feature]__add highlights from thesis Julio Xavier Vianna Neto "WIND TURBINE BLADE GEOMETRY DESIGN BASED ON MULTI-OBJECTIVE OPTIMIZATION USING METAHEURISTICS"

* __[feature]__ make an simple GUI, use uigetfile() to select input file(s) or to write default example files.  pyTurbSim has a good example of something similar.

* __[feature]__ option to save figure to image files rather than draw a window (or can save figure histories to later create movies or GIFS)

* __[feature]__ add framework for multiple objectives via multiplicative or additive penalty factors (inda like in Co-Blade v2.0.0+)

* __[feature]__ similar to CoBlade GMREC version, allow stochastic variation of aerodynamic design variables

* __[documentation]__ focus on quick easy to read documentation, rather than long winded users guide that nobody will ever ready anyways.  Maybe use some kind of system to automatically create documentation and UML type diagrams, options include:
    Doxygen (see many examples on File Exchange)
    m2html (http://www.artefact.tk/software/matlab/m2html/) in combination with GraphViz (http://www.graphviz.org/)