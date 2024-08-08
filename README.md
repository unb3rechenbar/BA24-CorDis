# BA24-CorDis
Code Base to the bachelor's thesis "Studies of ERM Models with Correlated Disorder". It holds the code to simulate the ERM models with correlated disorder using Born approximation, as well as the final version of the thesis. It corresponds to the print version of the thesis, which is available at the University of Constance. Its reference is:

```
    BA2024-StudiesOfERMmodelswithcorrelateddisorder Final.pdf
```

## Table of Contents
1. [Structure](#structure)
2. [Usage](#usage)
3. [Dependencies](#dependencies)
4. [Corrections](#corrections)


### Structure
The main contents of the thesis are held in:
```
    Bachelorarbeit/Inhalt/Sektionen
```
It contains the text files for each section of the thesis and uses references to several other folders. I assume the folder titles to be self-explanatory. Numerical results are stored in:
```
    Bachelorarbeit/Inhalt/Numerik
```
Hereby `Cor-S-SOS-Comp` contains results for the Heaviside approach presented in section 4, `Cor-S-exp-SOS-Comp` stores the respective exponential approach. Since a cruical mistake has been done in the simulation, the _corrected_ results have the attribute `*Cor*` in their name. They both contain numerical results for $k\mapsto S(k) = 1.0$ and $k\mapsto S(k) = 1.0 + \mathcal{F}(g - 1)(k)$. The naming convention is as follows:
```
    DENSITY - GRID SIZE - MAX k - SPRING FUNCTION APPROACH .csv
```
There are logs provided which contain information about the computation time and the parameters used for the `Simulation/runsim.sh` script, as well as norm values for every iteration of the fixed point solver.  