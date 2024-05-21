import os
import glob
import json

subjectsPath = os.path.join('/fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/bids_2/', 'sub-*')
subjects = glob.glob(subjectsPath)

for subject in subjects:

	fmapsPath = os.path.join(subject, 'fmap', '*.json')
	fmaps = glob.glob(fmapsPath)
	funcsPath = os.path.join(subject, 'func', '*.nii.gz')
	funcs = glob.glob(funcsPath)

	#substring to be removed from absolute path of functional files
	pathToRemove = subject + '/'
	funcs = list(map(lambda x: x.replace(pathToRemove, ''), funcs))
	for fmap in fmaps:
		with open(fmap, 'r') as data_file:
			fmap_json = json.load(data_file)
		fmap_json['IntendedFor'] = funcs

		with open(fmap, 'w') as data_file:
			fmap_json = json.dump(fmap_json, data_file, indent=4)
