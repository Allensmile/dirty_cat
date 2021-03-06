#!/bin/bash
# This script is meant to be called in the "deploy" step defined in 
# circle.yml. See https://circleci.com/docs/ for more details.
# The behavior of the script is controlled by environment variable defined
# in the circle.yml in the top level folder of the project.

set -e

USERNAME="dirty-cat-ci";

DOC_REPO="dirty-cat.github.io"
GENERATED_DOC_DIR=$1

if [[ -z "$GENERATED_DOC_DIR" ]]; then
    echo "Need to pass directory of the generated doc as argument"
    echo "Usage: $0 <generated_doc_dir>"
    exit 1
fi

# Absolute path needed because we use cd further down in this script
GENERATED_DOC_DIR=$(readlink -f $GENERATED_DOC_DIR)

if [ "$CIRCLE_BRANCH" = "master" ]
then
    dir=dev
else
    # Strip off .X
    dir="${CIRCLE_BRANCH::-2}"
fi

MSG="Pushing the docs to $dir/ for branch: $CIRCLE_BRANCH, commit $CIRCLE_SHA1"

cd $HOME
if [ ! -d $DOC_REPO ];
#then git clone --depth 1 --no-checkout "git@github.com:dirty-cat/"$DOC_REPO".git";
then git clone "git@github.com:dirty-cat/"$DOC_REPO".git";
fi
cd $DOC_REPO
#git config core.sparseCheckout true
#echo $dir > .git/info/sparse-checkout
git checkout $CIRCLE_BRANCH
git reset --hard origin/$CIRCLE_BRANCH
git rm -rf $dir/ && rm -rf $dir/
cp -R $GENERATED_DOC_DIR $dir
git config user.email "gael.varoquaux+dirty_cat@gmail.com"
git config user.name $USERNAME
git config push.default matching
git add -f $dir/
git commit -m "$MSG" $dir
git push
echo $MSG 
