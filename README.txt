These scripts were used in Kabulska et al., 2024 (Human Brain Mapping)

Last change: 09.08.2023 ZK

To run all the analysis, you additionally need the CoSMoMVPA toolbox (https://www.cosmomvpa.org/)

****************************************
# Reliability map:
1-AnalysisCode (scripts from Tarhan & Konkle, 2020. DOI: 10.1016/j.neuroimage.2019.116350)

****************************************
# RSA (Figures 1 and 2)
1. A1_runAll.m -> it runs:
	1. A2_runRSA.m
	2. A3_separateMaps.m
	HERE DO SMOOTHING (runManySMOOTHING.sh)
	3. A4_RSA_MonteCarloCorr.m

****************************************
# Winner-takes-all (Figure 3)
Run WinnerTakesAll/winnerTakesAll.m
The script summarizeActionHierarchy_ZK.m is based on the script from Tarhan, de Freitas and Konkle, 2021. https://doi.org/10.1016/j.neuropsychologia.2021.108048. See https://osf.io/d5j3h/ 

****************************************
# VIF
compute_VIF.m

****************************************
# Correlations between Resnet50 layers and V1 (in case needed)
Run Correlations/correlationDNNsROIs.m








