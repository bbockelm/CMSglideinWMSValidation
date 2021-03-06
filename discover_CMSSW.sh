#!/bin/sh

glidein_config="$1"

# Look for CMSSW in CVMFS, then the older places:

if [ -f "$CVMFS/cms.cern.ch/cmsset_default.sh" ]; then
   echo "Found CMS SW in $CVMFS/cms.cern.ch" 1>&2
   source "$CVMFS/cms.cern.ch/cmsset_default.sh"
elif [ -f "/cvmfs/cms.cern.ch/cmsset_default.sh" ]; then
   echo "Found CMS SW in /cvmfs/cms.cern.ch" 1>&2
   source "/cvmfs/cms.cern.ch/cmsset_default.sh"
elif [ -f "$VO_CMS_SW_DIR/cmsset_default.sh" ]; then
   echo "Found CMS SW in $VO_CMS_SW_DIR" 1>&2
   source "$VO_CMS_SW_DIR/cmsset_default.sh"
elif [ -f "$OSG_APP/cmssoft/cms/cmsset_default.sh" ]; then
   echo "Found CMS SW in $OSG_APP/cmssoft/cms" 1>&2
   source "$OSG_APP/cmssoft/cms/cmsset_default.sh"
else
   echo "cmsset_default.sh not found!\n" 1>&2
   echo "Looked in $CVMFS/cms.cern.ch/cmsset_default.sh" 1>&2
   echo "and /cvmfs/cms.cern.ch/cmsset_default.sh" 1>&2
   echo "and $VO_CMS_SW_DIR/cmsset_default.sh" 1>&2
   echo "and $OSG_APP/cmssoft/cms/cmsset_default.sh" 1>&2
   exit 1
fi

archs=`grep '^CMS_SCRAM_ARCHES ' $glidein_config | awk '{print $2}'`
if [ -z "$archs" ]; then
  archs="slc6_amd64_gcc481"
fi
echo "Looking for CMS SW on $archs" 1>&2

tmpname=$PWD/installed_cms_software_tmp_$$.tmp
for arch in $archs
do
   echo "Analyzing $arch" 1>&2
   export SCRAM_ARCH=$arch
   scramv1 list -c CMSSW | grep CMSSW | awk '{print $2}' | sort | uniq | grep ^CMSSW >> $tmpname
done

# Format the CMSSW list

sw_list=`cat $tmpname | awk '{if (length(a)!=0) {a=a "," $0} else {a=$0}}END{print a}'`

if [ -z "$sw_list" ]; then
  echo "No CMS SW found!" 1>&2
  exit 1
fi
echo "CMS SW list found and not empty" 1>&2

# Export the data - DISABLED to save ClassAd space

#echo "############ CMS software ##############" >> "$glidein_config"
#echo "GLIDEIN_CMSSW_LIST $sw_list" >> "$glidein_config"
#echo "########## end CMS software ############" >> "$glidein_config"

# One has to tell the condor_startup to publish the data
#condor_vars_file=`grep -i "^CONDOR_VARS_FILE " $glidein_config | awk '{print $2}'`
#echo "############ CMS software ##############" >> "$condor_vars_file"
#echo "GLIDEIN_CMSSW_LIST S - + Y Y +" >> "$condor_vars_file"
#echo "########## end CMS software ############" >> "$condor_vars_file"

exit 0
