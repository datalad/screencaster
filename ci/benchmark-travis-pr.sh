#!/bin/bash

set -eu

if [ "$TRAVIS_PULL_REQUEST" = "false" ]
then
    echo "I: skipping benchmarks for non-PR branch"
    exit 0
fi

configure_asv () {
    cat << EOF > asv.conf.json
{
    "version": 1,
    "repo": ".",
    "branches": ["HEAD"],
    "environment_type": "virtualenv",
}
EOF
}

run_asv () {
    asv run -E existing --set-commit-hash $(git rev-parse HEAD)
}

pip install asv
asv machine --yes

git tag '__bench_target__'
git rev-parse HEAD __bench_target__
pip install -e .
configure_asv
run_asv

git reset --hard
git checkout origin/master
git rev-parse HEAD __bench_target__
pip install -e .
configure_asv
run_asv

asv compare origin/master __bench_target__
