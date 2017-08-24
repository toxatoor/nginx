#!/bin/bash

FLAGPATH="/srv/data/repoflags"
REPOPATH="/srv/data/repo"
VALID_REPOS=" $(ls -ld ${REPOPATH}/* | xargs -n1 basename | xargs echo ) "

for flag in ${FLAGPATH}/*
do
	repo=$(basename ${flag})

	if [[ ${VALID_REPOS} == *" ${repo} "* ]]; then
	  /bin/createrepo_c --update ${REPOPATH}/${repo}
	fi

	rm -f ${flag}
done
