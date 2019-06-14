easy-sword2-dans-examples
=========================

The examples in this project show how to implement a client in Java that interacts with the EASY SWORD2 Deposit service at DANS. 

Introduction
--------------------

Depositing in EASY via the SWORD v2.0 protocol is basically a two-phase process:

* Submitting a deposit for ingest.
* Tracking the state of the deposit as it goes through the ingest-flow, until it reaches ARCHIVED status.

The following diagram details this a bit further.

![SWORD diagram](https://easy.dans.knaw.nl/doc/img/sword2.png)

1. Client creates a deposit package.
2. Client sends deposit package to SWORD2 Service, getting back a URL to track the deposit's state.
3. SWORD Service unzips and validates deposit.
4. EASY Ingest Flow performs checks and transformations and creates a dataset in Archival Storage.
5. EASY Ingest Flow reports back success or failure to SWORD Service.

3-5. During this time the Client periodically checks the deposit state through the URL received in step 2.
If the final state of `ARCHIVED` is reached, the process is concluded successfully. Other outcomes may be `INVALID` (the package did not meet the requirements of the SWORD service) or `REJECTED` (the package did not meet the requirements of the EASY Ingest Flow).
In case the server encountered an unknown error `FAILED` will be returned.

Getting started
---------------

The following is a step-by-step instruction on how to run these examples using the DANS
acceptance test server at https://act.easy.dans.knaw.nl/. 

1. From your account manager at DANS request access to the acceptance test server. The account manager will provide the information necessary to connect.
2. Create an EASY account via https://act.easy.dans.knaw.nl/ui/register.
3. From your account manager at DANS request the account to be enabled for SWORD deposits.
4. From your account manager at DANS inquire which flow (see next section) the account is configured for.

### Flow types

The SWORD service will automatically select a flow for the data when a deposit is submitted.
The flow that is selected depends on the agreement between the depositor organization and DANS.
The flow configured for your account will be one of the following:

* `Agreement` - The datasets will be disseminated by DANS. DANS will mint DOIs for the datasets.
* `NoAccess` - The files are not to be disseminated by DANS. The depositor organization must mint DOIs for the datasets.

### Preparing the dataset
To upload a dataset it must be properly formatted.
Some example bags can be found in the [resources directory], as well as the specifications the bags must follow.
A dataset can be created by performing the following steps:

1. run `mkdir my-bag; mkdir my-bag/data; mkdir my-bag/metadata; bagit baginplace my-bag` to create the bag
2. place files in the `my-bag/data` directory
3. create the `my-bag/metadata/dataset.xml` and `my-bag/metadata/files.xml` add the appropriate metadata
4. update the the `my-bag/bag-info.txt` to include the Created date: `Created: yyyy-mm-ddThh:mm:ss.000+00:00`
5. update the checksums with `bagit makecomplete my-bag my-bag --payloadmanifestalgorithm SHA1`
6. verify that the bag is valid according to Bagit with `bagit verifyvalid my-bag`

Running The Examples
--------------------

The examples take one or more directories as input parameters.
These directories should be in the format specified by BagIt.
The code copies each directory to the `target`-folder of the project, zips it and sends it to the specified SWORDv2 service.
The copying step has been built in because in some examples the bag must be modified before it is sent.

#### Output analysis

In the introduction the SWORD2 ingest process is described in 5 stages, the response messages give some indication how far along the process is. The output will take the following form, starting with the part of the response representing step 2.

	SUCCESS. Deposit receipt follows:
	<entry xmlns="http://www.w3.org/2005/Atom"><generator uri="http://www.swordapp.org/" version="2.0" /><id>https://act.easy.dans.knaw.nl/sword2/container/a5bb644a-78a3-47ae-907a-0bdf162a0cd4</id><link href="https://act.easy.dans.knaw.nl/sword2/container/a5bb644a-78a3-47ae-907a-0bdf162a0cd4" rel="edit" /><link href="https://act.easy.dans.knaw.nl/sword2/container/a5bb644a-78a3-47ae-907a-0bdf162a0cd4" rel="http://purl.org/net/sword/terms/add" /><link href="https://act.easy.dans.knaw.nl/sword2/media/a5bb644a-78a3-47ae-907a-0bdf162a0cd4" rel="edit-media" /><packaging xmlns="http://purl.org/net/sword/terms/">http://purl.org/net/sword/package/BagIt</packaging><link href="https://act.easy.dans.knaw.nl/sword2/statement/a5bb644a-78a3-47ae-907a-0bdf162a0cd4" rel="http://purl.org/net/sword/terms/statement" type="application/atom+xml; type=feed" /><treatment xmlns="http://purl.org/net/sword/terms/">[1] unpacking [2] verifying integrity [3] storing persistently</treatment><verboseDescription xmlns="http://purl.org/net/sword/terms/">received successfully: bag.zip; MD5: 494dd614e36edf5c929403ed7625b157</verboseDescription></entry>
	Retrieving Statement IRI (Stat-IRI) from deposit receipt ...
	Stat-IRI = https://act.easy.dans.knaw.nl/sword2/statement/a5bb644a-78a3-47ae-907a-0bdf162a0cd4

As the deposit is being processed by the server the client polls the Stat-IRI to track the status of the deposit. During this stage steps 3 and 4 are performed. 
	
	Start polling Stat-IRI for the current status of the deposit, waiting 10 seconds before every request ...
	Checking deposit status ... SUBMITTED
	Checking deposit status ... SUBMITTED
	Checking deposit status ... SUBMITTED
	Checking deposit status ... SUBMITTED

The 5th and final step of the process is represented by the following response messaging.

	Checking deposit status ... ARCHIVED
	SUCCESS.
	Deposit has been archived at: <urn:uuid:a5bb644a-78a3-47ae-907a-0bdf162a0cd4>.  With DOI: [10.17026/test-Lwgy-zrn-jfyy]. Dataset landing page will be located at: <https://act.easy.dans.knaw.nl/ui/datasets/id/easy-dataset:24>.
	Complete statement follows:
	<feed xmlns="http://www.w3.org/2005/Atom"><id>https://act.easy.dans.knaw.nl/sword2/statement/a5bb644a-78a3-47ae-907a-0bdf162a0cd4</id><link href="https://act.easy.dans.knaw.nl/sword2/statement/a5bb644a-78a3-47ae-907a-0bdf162a0cd4" rel="self" /><title type="text">Deposit a5bb644a-78a3-47ae-907a-0bdf162a0cd4</title><author><name>DANS-EASY</name></author><updated>2019-05-23T14:51:15.356Z</updated><category term="ARCHIVED" scheme="http://purl.org/net/sword/terms/state" label="State">http://act.easy.dans.knaw.nl/ui/datasets/id/easy-dataset:24</category><entry><content type="multipart/related" src="urn:uuid:a5bb644a-78a3-47ae-907a-0bdf162a0cd4" /><id>urn:uuid:a5bb644a-78a3-47ae-907a-0bdf162a0cd4</id><title type="text">Resource urn:uuid:a5bb644a-78a3-47ae-907a-0bdf162a0cd4</title><summary type="text">Resource Part</summary><updated>2019-05-23T14:51:22.342Z</updated><link href="https://doi.org/10.5072/dans-Lwgy-zrn-jfyy" rel="self" /></entry></feed>

### Deposit Packaging

The easy-sword2 service requires deposits to be sent as zipped bags (see [BagIt]).
The EASY archive adds some extra requirements.
These are documented on the [EASY SWORDv2 deposit documentation page] and [DANS BagIt Profile].
A command line tool called [xmllint] can be used to validate xml files locally.

[EASY SWORDv2 deposit documentation page]: https://easy.dans.knaw.nl/doc/sword2.html
[BagIt]: https://datatracker.ietf.org/doc/draft-kunze-bagit
[DANS BagIt Profile]: https://github.com/DANS-KNAW/dans-bagit-profile/blob/master/versions/0.0.0.md
[xmllint]: http://xmlsoft.org/xmllint.html

### Example Bags

Examples of bags which meet the specifications of the SWORD depositing interface can be found in the [resources directory]. These bags are categorized by the flow which they are designed for.
The primary difference between the no-access flow and the other flows is that the no-access flow requires a DOI to be present in the metadata.xml.

[resources directory]: https://github.com/DANS-KNAW/easy-sword2-dans-examples/tree/master/src/main/resources

### Example Java Classes

This project contains 5 [Java example classes] which can be used as a guide to writing a custom client to deposit datasets using the SWORD2 protocol. 
These classes can be broken down into the following types: 

1. Common.java; contains elements which are used by all the other classes. This would include parsing, zipping and sending of files. 
2. SimpleDeposit.java; sends a zipped dataset in a single chunk and reports on the status.   
3. ContinuedDeposit.java; sends a zipped bag in chunks of configurable size and reports on the status.
4. SequenceSimpleDeposit.java; calls the SimpleDeposit class multiple times to send multiple bags belonging to a sequence. 
5. SequenceContinuedDeposit.java; calls the ContinuedDeposit class multiple times to send multiple bags belonging to a sequence. 

[Java Example classes]: https://github.com/DANS-KNAW/easy-sword2-dans-examples/tree/master/src/main/java/nl/knaw/dans/easy/sword2examples

#### Run script

The project directory contains a `run.sh` script that can be used to invoke the java classes. An example command to submit a deposit would be:

	mvn clean install # Only necessary if the code was not previously built.
	./run.sh Simple https://act.easy.dans.knaw.nl/sword2/collection/1 myuser mypassword bag
	./run.sh Continued https://act.easy.dans.knaw.nl/sword2/collection/1 myuser mypassword chunksize bag
	./run.sh SequenceSimple https://act.easy.dans.knaw.nl/sword2/collection/1 myuser mypassword bag1 bag2 bag3
	./run.sh SequenceContinued https://act.easy.dans.knaw.nl/sword2/collection/1 myuser mypassword chunksize bag1 bag2 bag3
