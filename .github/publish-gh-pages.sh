#!/bin/sh

GITHUB_REPOSITORY=$1
GITHUB_ACTOR=$2
REPOSITORY_NAME=$3
GITHUB_TOKEN=$4
GITHUB_SHA=$5

DEPLOYMENT_BRANCH="gh-pages"

if [[ ! -f "website/dist/build.js" ]]
then
    echo "Site not builded. No build.js"
    exit 1
fi

# Go to a specific folder to work
build_dir="website_build"
rm -Rf $build_dir
mkdir -p $build_dir
cd $build_dir

# clone gh-pages
echo "⬇️ clone ${DEPLOYMENT_BRANCH}"
remoteBranch="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git clone -b "${DEPLOYMENT_BRANCH}" --single-branch "${remoteBranch}" "${REPOSITORY_NAME}-${DEPLOYMENT_BRANCH}"
pwd
cd "${REPOSITORY_NAME}-${DEPLOYMENT_BRANCH}"

# remove everything (file will be replaces)
echo "⚙️ remplace files by builded ones"
git rm -rf .

# copy files
source="../../website/"

if [ -d $source/node_modules/ ]; then
    mv $source/node_modules/ ../ # move into $build_dir to skip it
fi
cp -R $source/* .
if [ -d ../node_modules/ ]; then
    mv ../node_modules $source/
fi

# specs
output="Specs" # todo: take from conf file
mkdir -p $output
source="../../$output/"

#echo "copy index file by topics" # if we want to do it by file
#topics=$(yq r ../../.gallery-workflow.yml "topics" | sed "s/- //")
#for topic in $topics
#do
#  echo "🏷  $topic"
#  mkdir -p "$output/$topic"
#  cp "$source$topic/index.json" "$output/$topic/"
  
#  for repo in $source$topic/*
#  do 
#    echo "📦 $repo"
#    mkdir -p $output/$topic/$repo
 #   cp "$source$topic/$repo/info.json" "$output/$topic/$repo/"
    
#  done
#done

cp -R $source ./$output/

# return to clone
echo "🌊 commit for ${GITHUB_SHA}"
git add .
git commit -m "Deploy website version based on ${GITHUB_SHA}"

#git push origin ${DEPLOYMENT_BRANCH}
echo "⬆️ push to ${DEPLOYMENT_BRANCH}"
git push origin
