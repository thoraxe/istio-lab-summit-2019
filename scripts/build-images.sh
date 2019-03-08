#!/usr/bin/env bash

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MYHOME=${MYDIR}/..

RECO_SRC=${MYHOME}/src/recommendation/src/main/java/com/redhat/developer/demos/recommendation/RecommendationVerticle.java

TAG_PREFIX=istio-lab

function fail() {
	git checkout -f ${RECO_SRC}
	echo $1
	exit 1
}

# reset recommendation state
git checkout -f ${RECO_SRC}

for project in customer preference recommendation ; do
	mvn -f ${MYHOME}/src/${project} clean package -DskipTests && \
		docker build -t ${TAG_PREFIX}/${project}:v1 ${MYHOME}/src/${project} || \
		fail "build of $project failed"
done

# recommendation:v2
sed -i.bak 's/recommendation v. from/recommendation v2 from/' ${RECO_SRC}

mvn -f ${MYHOME}/src/recommendation clean package -DskipTests && \
	docker build -t ${TAG_PREFIX}/recommendation:v2 ${MYHOME}/src/recommendation || \
	fail "build of recommendation:v2 failed"

# recommendation:v2d (with delay)
sed -i.bak 's|^//.*this::timeout.*$|router.get("/").handler(this::timeout);|' ${RECO_SRC}

mvn -f ${MYHOME}/src/recommendation clean package -DskipTests && \
	docker build -t ${TAG_PREFIX}/recommendation:v2d ${MYHOME}/src/recommendation || \
	fail "build of recommendation:v2d failed"

# reset file
git checkout -f ${RECO_SRC}

