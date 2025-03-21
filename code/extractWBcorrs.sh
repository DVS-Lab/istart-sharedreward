#!/bin/bash

BASEDIR="/ZPOOL/data/projects/istart-mel/updated_rsa/derivatives/fsl"
OUTDIR="/ZPOOL/data/projects/istart-sharedreward/derivatives"

subjects=(1001 1006 1009 1010 1012 1013 1015 1016 1019 1021 1242 1243 1244 1248 1249 1251 1255 1276 1286 1294 1301 1302 1303 3116 3122 3125 3140 3143 3166 3167 3170 3173 3176 3189 3190 3200 3206 3212 3220)

pairs=(
"SR_stranger_vs_SR_computer L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope25.feat/stats/zstat1 L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope24.feat/stats/zstat1"
"SR_stranger_vs_SD L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope25.feat/stats/zstat1 L1_task-socialdoors_model-1_type-act_run-1_sm-6.feat/stats/zstat4"
"SR_stranger_vs_D L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope25.feat/stats/zstat1 L1_task-doors_model-1_type-act_run-1_sm-6.feat/stats/zstat4"
"SR_computer_vs_SD L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope24.feat/stats/zstat1 L1_task-socialdoors_model-1_type-act_run-1_sm-6.feat/stats/zstat4"
"SR_computer_vs_D L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope24.feat/stats/zstat1 L1_task-doors_model-1_type-act_run-1_sm-6.feat/stats/zstat4"
"SD_vs_D L1_task-socialdoors_model-1_type-act_run-1_sm-6.feat/stats/zstat4 L1_task-doors_model-1_type-act_run-1_sm-6.feat/stats/zstat4"
"SR_comp_pun_vs_D_loss L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope1.feat/stats/zstat1 L1_task-doors_model-1_type-act_run-1_sm-6.feat/stats/zstat2"
"SR_comp_rew_vs_D_win L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope2.feat/stats/zstat1 L1_task-doors_model-1_type-act_run-1_sm-6.feat/stats/zstat1"
"SR_str_pun_vs_SD_loss L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope5.feat/stats/zstat1 L1_task-socialdoors_model-1_type-act_run-1_sm-6.feat/stats/zstat2"
"SR_str_rew_vs_SD_win L2_task-sharedreward_model-2_type-act_sm-6.gfeat/cope6.feat/stats/zstat1 L1_task-socialdoors_model-1_type-act_run-1_sm-6.feat/stats/zstat1"
"SD_win_vs_D_win L1_task-socialdoors_model-1_type-act_run-1_sm-6.feat/stats/zstat1 L1_task-doors_model-1_type-act_run-1_sm-6.feat/stats/zstat1"
)

# Step 1: Create group mask from first subject and first pair
first_img=$(echo "${pairs[0]}" | awk '{print $2}')
fslmaths "${BASEDIR}/sub-${subjects[0]}/${first_img}.nii.gz" -abs -bin "${BASEDIR}/group_mask.nii.gz"

for subj in "${subjects[@]}"; do
  for pair in "${pairs[@]}"; do
    img1=$(echo "$pair" | awk '{print $2}')
    img2=$(echo "$pair" | awk '{print $3}')
    for img in "$img1" "$img2"; do
      fslmaths "${BASEDIR}/sub-${subj}/${img}.nii.gz" -abs -bin -mul "${BASEDIR}/group_mask.nii.gz" "${BASEDIR}/group_mask.nii.gz"
    done
  done
done

# Step 2: Write CSV header
(IFS=,; echo "subject,${pairs[*]%% *}") > "${OUTDIR}/correlations.csv"

# Step 3: Compute fslcc correlations
for subj in "${subjects[@]}"; do
  echo "Processing subject ${subj}..."
  line="${subj}"
  for pair in "${pairs[@]}"; do
    img1=$(echo "$pair" | awk '{print $2}')
    img2=$(echo "$pair" | awk '{print $3}')
    f1="${BASEDIR}/sub-${subj}/${img1}.nii.gz"
    f2="${BASEDIR}/sub-${subj}/${img2}.nii.gz"
    r=$(fslcc -t -1 -m "${BASEDIR}/group_mask.nii.gz" "$f1" "$f2" | awk '{print $3}')
    line+=",${r}"
  done
  echo "$line" >> "${OUTDIR}/correlations.csv"
done
