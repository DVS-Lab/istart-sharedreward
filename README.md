# ISTART-sharedreward: Shared Reward Task Data and Analyses
This repository contains code related to our in prep project related to shared reward processing (cf. Fareri et al., 2012, JNeurosci), substance use, and reward sensitivity (grant: R03-DA046733; grant report: Sazhin et al., 2020, JPBS). All hypotheses and analysis plans were pre-registered on AsPredicted in fall semester 2019 and data collection commenced on shortly thereafter. Imaging data will be shared via [OpenNeuro][openneuro] when the manuscript is posted on bioRxiv.


## A few prerequisites and recommendations
- Understand BIDS and be comfortable navigating Linux
- Install [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation)
- Install [miniconda or anaconda](https://stackoverflow.com/questions/45421163/anaconda-vs-miniconda)


## Notes on repository organization and files
- Raw DICOMS (an input to heudiconv) are private and only accessible locally (Smith Lab Linux: /data/sourcedata). These files will have already been de-identified and converted to BIDS under a separate repository (DVS-Lab/istart-data)
- Some of the contents of this repository are not tracked (.gitignore) because the files are large and we do not yet have a nice workflow for datalad. These files/folders include parts of `bids` and `derivatives`.
- Tracked folders and their contents:
  - `code`: analysis code
  - `templates`: fsf template files used for FSL analyses
  - `masks`: images used as masks, networks, and seed regions in analyses
  - `derivatives`: derivatives from analysis scripts, but only text files (re-run script to regenerate larger outputs)

## Internal: Keeping up with analyses on an ongoing basis
As we're collecting data, we must analyze it on an ongoing basis for the sake of quality assurance and identifying and correcting potential problems.

### Step 1: Checking your inputs
Before you do anything, you should make sure all your inputs are there. The person managing the preprocessing should have taken care of these steps under the `DVS-Lab/istart-data` repository:
1. Conversion to BIDS, defacing, and MRIQC (prepdata.sh)
1. Preprocessing with [fmriprep][fmriprep] (fmriprep.sh)
1. Creation of confound EVs (MakeConfounds.py)

### Step 2: Updating BIDS sub-<sub>_task-<task>_run-<run>_events.tsv files
Since HeuDiConv can only put in a placeholder for your `sub-<sub>_task-<task>_run-<run>_events.tsv` files, you must convert your behavioral data into BIDS format. Those converted data should live with the other BIDS data. For the project in this repository, here are the steps you'd take:
1. make sure local source data is current:
  - `cd /data/projects/istart`
  - `git pull`
1. go to the correct location: `cd /data/projects/istart-data`
1. open Matlab: `matlab &`
1. open the `run_convertSharedReward2BIDSevents.m` script and edit your subject list
1. run `run_convertSharedReward2BIDSevents.m` from Matlab (report errors on Asana and raise at lab meeting)
1. update GitHub (assuming these were the only changes):
  - `git add .`
  - `git commit -m "replace tsv files for new subjects in task-sharedreward"`
  - `git push`

### Step 3: Creating 3-column files for FSL
1. go to the correct location: `cd /data/projects/istart-sharedreward`
1. update subject list in run_gen3colfiles.sh
1. run script: `bash code/run_gen3colfiles.sh`
1. update GitHub (assuming these were the only changes):
  - `git add .`
  - `git commit -m "add 3-column files for new subjects in task-sharedreward"`
  - `git push`

### Step 4: Running the analyses
1. go to the correct location: `cd /data/projects/istart-sharedreward`
1. update subject lists in run_L1stats.sh and run_L2stats.sh
1. run scripts with nohup (prevents process from hanging up if you close your computer or lose your connection):
  - `nohup bash code/run_L1stats.sh > nohup_L1stats.out &` (wait till this is done before running L2stats.sh)
  - `nohup bash code/run_L2stats.sh > nohup_L2stats.out &`
1. review *.out logs from `nohup`. (if no errors, delete them. if errors, report on Asana and raise at lab meeting)
1. update GitHub (assuming these were the only changes):
  - `git add .`
  - `git commit -m "add L1stats and L2stats for new subjects in task-sharedreward"`
  - `git push`

### To-Do
To simplify and streamline this whole process, we could adjust the run_* scripts to take a text file with a list fo subjects. Then nobody has to edit any scripts. Just update the subject list file... TBD later


## External: Basic commands to reproduce our all of our analyses (under construction)
Note: this section is still under construction. It is intended for individuals outside the lab who might want to reproduce all of our analyses, from preprocessing to group-level stats in FSL. As a working example from a different study, please see https://github.com/DVS-Lab/srndna-trustgame

```
# get code and data (two options for data)
git clone https://github.com/DVS-Lab/istart-sharedreward
cd  istart-sharedreward

rm -rf bids # remove bids subdirectory since it will be replaced below
# can this be made into a sym link?

datalad clone https://github.com/OpenNeuroDatasets/ds003745.git bids
# the bids folder is a datalad dataset
# you can get all of the data with the command below:
datalad get sub-*

# run preprocessing and generate confounds and timing files for analyses
bash code/run_fmriprep.sh
python code/MakeConfounds.py --fmriprepDir="derivatives/fmriprep"
bash code/run_gen3colfiles.sh

# run statistics
bash code/run_L1stats.sh
bash code/run_L2stats.sh
bash code/run_L3stats.sh
```


## Acknowledgments
This work was supported, in part, by grants from the National Institutes of Health (R03-DA046733 to DVS and R15-MH122927 to DSF). DVS was a Research Fellow of the Public Policy Lab at Temple University during the preparation of the manuscript (2019-2020 academic year).

[openneuro]: https://openneuro.org/
[fmriprep]: http://fmriprep.readthedocs.io/en/latest/index.html
