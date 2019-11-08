#!/usr/bin/env bash
#
# Copyright (C) 2016 DANS - Data Archiving and Networked Services (info@dans.knaw.nl)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Helper script to perform a deposit using the Maven project.
#
#

PROGRAM=$1
COL_IRI=$2
USER=$3
PASSWORD=$4
JARFILE=$(ls -1 target/*SNAPSHOT.jar)

if (( $# < 5 )); then
 echo "Usage: ./run.sh <program> <COL-IRI> <user> <password> [<chunksize>] <bag>..."
 echo "Where:"
 echo "<program> = one of Simple,Continued,SequenceSimple,SequenceContinued"
 echo "<COL-IRI> = the collection IRI to post to"
 echo "<user> = EASY user account"
 echo "<password> = password for <user>"
 echo "<chunksize> = size in byte of each chunk (only for the Continued variants)"
 echo "<bag> = one bag directory or zip file to send or multiple (only for Sequence variants)"
 exit
fi


if [[ "$PROGRAM" =~ ^.*Continued$ ]]; then
    CHUNKSIZE=$5
    BAGDIRS=${@:6}
else
    CHUNKSIZE=""
    BAGDIRS=${@:5}
fi

mvn dependency:copy-dependencies
java -cp "target/dependency/*:$JARFILE" "nl.knaw.dans.easy.sword2examples.${PROGRAM}Deposit" $COL_IRI $USER $PASSWORD $CHUNKSIZE $BAGDIRS

