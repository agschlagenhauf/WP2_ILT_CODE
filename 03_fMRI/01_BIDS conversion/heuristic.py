"""
Usage:

heudiconv --dicom_dir_template /mnt/f/WP2_DATA/dicoms/01_WP2_fMRI/{subject}/*/*/ --outdir /home/cognition/WP2_DATA/bids --heuristic /home/cognition/codeb01wp2/heuristic.py --subjects 12564 -c dcm2niix -b -g all --minmeta --overwrite

    Run `heudiconv -h` for more help output.

    fmri-prep command
    First command below is usefull for several participants, and for a case of a memory restriction
    fmriprep-docker ~/data/bids/ ~/data/fmriprep-output/ participant --participant-label BS001 BS002 --fs-license-file ~/projects/freesurfer-license.txt --mem-mb 12000 --fs-no-reconall --low-mem
    fmriprep-docker ~/data/bids/ ~/data/fmriprep-output/ participant --participant-label BS001 --fs-license-file ~/docs/freesurfer-license.txt



    fmriprep-docker /mnt/g/SyMoNe_BIDS/rest/ ~/data/fmriprep-output/ participant --participant-label BC012 --fs-license-file ~/docs/freesurfer-license.txt

    copy and tranfer data
    cp -r fmriprep-output /mnt/s/AG/AG-Lernmechanismen/NegSymp/SyMoNe/SyMoNe_fmriPREP/
    """
"sudo mount -t drvfs S: /mnt/s/"

def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes

def infotodict(seqinfo):

    anat_t1w = create_key('sub-{subject}/anat/sub-{subject}_T1w')
    anat_t2w = create_key('sub-{subject}/anat/sub-{subject}_T2w')

    fmap_mag =  create_key('sub-{subject}/fmap/sub-{subject}_magnitude')
    fmap_phase = create_key('sub-{subject}/fmap/sub-{subject}_phasediff')
    # fmap_AP_kelly =  create_key('sub-{subject}/fmap/sub-{subject}_dir-ap_epi')
    # fmap_PA_kelly = create_key('sub-{subject}/fmap/sub-{subject}_dir-pa_epi')

    func_ilt1 = create_key('sub-{subject}/func/sub-{subject}_task-ilt_run-1_bold')
    func_ilt2 = create_key('sub-{subject}/func/sub-{subject}_task-ilt_run-2_bold')

    func_aid = create_key('sub-{subject}/func/sub-{subject}_task-aid_bold')

    info = {
        anat_t1w: [],
        anat_t2w: [],
        fmap_mag: [],
        fmap_phase: [],
        func_ilt1: [],
        func_ilt2: [],
        func_aid: [],
    }

    # Get all series ID of interest
    for s in seqinfo:

       if 'T1wA' in s.protocol_name:
           info[anat_t1w].append(s.series_id)
       elif 't2_tse' in s.protocol_name:
           info[anat_t2w].append(s.series_id)
       elif (s.image_type == ('ORIGINAL', 'PRIMARY', 'M', 'ND')) and '2p4mm' in s.protocol_name:
           info[fmap_mag].append(s.series_id)
       elif (s.image_type == ('ORIGINAL', 'PRIMARY', 'P', 'ND')) and '2p4mm' in s.protocol_name:
           info[fmap_phase].append(s.series_id)
       elif 'ILT_1' in s.protocol_name:
           info[func_ilt1].append(s.series_id)
       elif 'ILT_2' in s.protocol_name:
           info[func_ilt2].append(s.series_id)
       elif 'AID' in s.protocol_name:
           info[func_aid].append(s.series_id)

    return info

    
    """Heuristic evaluator for determining which runs belong where

    allowed template fields - follow python string module:

    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group

    heudiconv -d {subject}/scans/DICOM/*/* -o bids/ -f convertall -s GS001T1 -c none
    heudiconv -d {subject}/scans/DICOM/*/* -o {subject}/scans/ -f bids/code/heuristic_v1.py -s GS001T1 -c dcm2niix -b --minmeta --overwrite

    anat_t1w = create_key('anat/{subject}_T1w')
    func_mid1 = create_key('func/{subject}_task-MID_run-1_bold')
    func_mid2 = create_key('func/{subject}_task-MID_run-2_bold')
    fm_AP = create_key('fmap/{subject}_fieldmap_epi_AP')
    fm_PA = create_key('fmap/{subject}_fieldmap_epi_PA')

    info = {anat_t1w: [], func_mid1: [], func_mid2: [], fm_AP: [], fm_PA: []}

        if ('mprage' in s.protocol_name):
            info[anat_t1w].append(s.series_id)
        if ('MID' in s.protocol_name) and ('1' in s.protocol_name):
            info[func_mid1].append(s.series_id)
        if ('MID' in s.protocol_name) and ('2' in s.protocol_name):
            info[func_mid2].append(s.series_id)
        if ('FieldMap' in s.protocol_name) and ('AP' in s.protocol_name):
            info[fm_AP].append(s.series_id)
        if ('FieldMap' in s.protocol_name) and ('PA' in s.protocol_name):
            info[fm_PA].append(s.series_id)

        The namedtuple `s` contains the following fields:

        * total_files_till_now
        * example_dcm_file
        * series_id
        * dcm_dir_name
        * unspecified2
        * unspecified3
        * dim1
        * dim2
        * dim3
        * dim4
        * TR
        * TE
        * protocol_name
        * is_motion_corrected
        * is_derived
        * patient_id
        * study_description
        * referring_physician_name
        * series_description
        * image_type
    """
