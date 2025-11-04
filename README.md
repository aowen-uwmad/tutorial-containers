# CHTC Tutorial: Containers

This repository contains the materials for a CHTC tutorial.

* The [main branch](https://github.com/CHTC/tutorial-containers/tree/main) is for a general audience.
* The [HISTORY.md file](https://github.com/CHTC/tutorial-containers/blob/main/HISTORY.md) contains a list of the other versions of this material.

You are currently viewing the `nov2025` branch for the training to be given on Nov. 5, 2025.
Corresponding slides are available here: [go.wisc.edu/2pixo7](https://go.wisc.edu/2pixo7).

## Files

### `version.sh`

The `version.sh` script is a short shell script that reports the 
version of the operating system and then the version of any 
command that is passed to it as an argument. For example:

```
$ ./version.sh python3

Detected operating system:
    Ubuntu 22.04.1 LTS

$ python3 --version | head -n 1
Python 3.10.6

```

This script is used as the central core to the training regardless 
of the system being used.

### Files for the HTC system

If using the HTC system, use the files in the `htc` directory:

```
$ tree htc/
htc/
├── container.sub
├── interactive.sub
├── logs/
└── regular.sub

1 directory, 3 files
```

The `logs` directory is deliberately empty.

### Files for the HPC system

If using the HPC system, use the files in the `hpc` directory:

```
$ tree hpc/
hpc/
├── container.sbatch
├── interactive.sh
└── regular.sbatch

0 directories, 3 files
```

## Instructions

All participants should follow these instructions, but use the
command(s) for their system when noted.

These instructions assume that you already have access to one of the
systems. 
You can [request a CHTC account here](https://chtc.cs.wisc.edu/uw-research-computing/form)
to get access to one of these systems.
Note that it can take 1-3 business days to get an account,
assuming that your research group is already using CHTC.

## Quickstart demo

First, a quick demonstration of what a container does.
Watch and listen to the instructor as they perform the demonstration.

## Log in and setup

Log in to the system you wish to use for the container training.
For instructions on logging in to CHTC systems, see the 
[Log in to CHTC](https://chtc.cs.wisc.edu/uw-research-computing/connecting)
guide.

Once logged in, run the following command to clone this repository:

```
git clone https://github.com/CHTC/tutorial-containers.git
```

Move into the directory appropriate for your system:

**HTC**

```
cd tutorial-containers/htc/
```

**HPC**

```
cd tutorial-containers/hpc/
```

## Submit regular job

You will use the `version.sh` script to explore the software environment
of a regular job on your preferred system.

To start, open the `regular` file for your preferred system
(`.sub` for HTC, `.sbatch` for HPC).

Examine the contents of the file to understand the job details.
The argument `python3` has been provided for you.
If you want to see the versions of other commands, add them after
`python3` using a space to separate each item of the list.

When ready, submit the job using the command for the system you are logged into.

**HTC**

```
condor_submit regular.sub
```

**HPC**

```
sbatch regular.sbatch
```

The submitted job should run and complete within a couple of minutes.
Once completed, examine the contents of `regular.out`.

* What was the operating system where the job ran?
* What was the version of `python3`?
* If you added other commands to check: did they exist and, if so, what were their versions?

> Note: Because of the simplicity of the `version.sh` script, the output
> for the HPC system will be duplicated by the number of tasks requested.

## Submit container job

You will now follow a similar process to submit a job that uses a container.
For this job, you'll be using the `container` file for your system 
(`.sub` for HTC, `.sbatch` for HPC).

Compare the contents of the `regular` and `container` job files.
What has changed?

If you added other commands as arguments besides `python3` to the `regular` file,
repeat the process to add them to the `container` file.

> *HTC ONLY*: Consider changing the container address from `python:3.13` to
  the address of some other container available on [DockerHub](hub.docker.com).

When ready, submit the `container` job. 

**HTC**

```
condor_submit container.sub
```

**HPC**

```
sbatch container.sbatch
```

Again, the job should run and complete within a couple of minutes.
Once completed, examine the contents of `container.out`.

* What was the operating system where the job ran?
* What was the version of `python3`?
* If you added other commands to check: did they exist and, if so, what were their versions?

And

* How does the output of the `container` job compare to the output of the `regular` job?

## Building your own Apptainer container

Next, you'll build a simple container using Apptainer.

Building a container can be an intensive process, like any software installation,
so first you need to start an interactive session on the system.

**HTC**

```
condor_submit -i interactive.sub
```

**HPC**

```
srun --mpi=pmix -n4 -N1 -t 240 -p int --pty bash
```

> *HPC ONLY*: You can use the provided `interactive.sh` script to start the
> interactive session. Using this script may be more convenient than remembering
> the above command.
> 
> ```
> ./interactive.sh
> ```

Once the interactive session has started, create a file called
`container.def` with the following contents:

```
Bootstrap: docker
From: python:3.13

%post
    chmod 777 /tmp
    apt update -y
    apt install -y nano vim

    python3 -m pip install cowsay
```

This file is the "definition" file for how Apptainer should 
construct the container.

* The first two lines tell Apptainer to use the `python:3.13` 
  container that is already published on DockerHub.

* The lines under the `%post` section are the commands that 
  Apptainer should use to install additional software.
  (This section takes normal shell commands as instructions.)

* First, install `nano` and `vim`, so we can edit files from
  inside the container. (Because the container is based on 
  Debian, we use the `apt` command to do this.)

* Second, install the `cowsay` Python package using `pip`.
  (`python3 -m pip` is the recommend way to use `pip` on Linux.)

Now, still in the interactive job, run the following command:

```
apptainer build container.sif container.def
```

* The first argument of this command is desired name of the container image file.
  For historic reasons, Apptainer uses the `.sif` extension to indicate an
  Apptainer image file.

* The second argument of this command is the name of the definition file that
  you wrote, in this case, `container.def`.

As the command runs, you'll see a variety of information printed to the screen.

1. First will be information about Apptainer downloading the Docker container 
   from DockerHub.

2. Then, the `apt` commands run, first updating its package list, then
   installing the desired packages.

3. Next, there will be the usual `pip install` output for installing the `cowsay` package,
   which comes from Apptainer executing the commands in the `%post` section.

3. Finally, assuming no errors, Apptainer will create a single standalone file
   (the `.sif` file).

If everything works correctly, once the command completes there should be a new
`container.sif` file in your current directory.

## Testing the container

While still in the interactive job (and assuming there is a `container.sif` file),
run the following command:

**HTC**

```
apptainer shell -e container.sif
```

**HPC**

```
apptainer shell --bind $PWD/../ -e container.sif
```

You'll see your prompt change from `[yourNetID@hostname ~]$ ` to `Apptainer> `.
That means when you run a command, you will be using the operating system and
software that is inside of the container image.

You should be able to run the following command:

**HTC**

```
./version.sh python3
```

**HPC**

```
../version.sh python3
```

To test that the `cowsay` package is installed, run the following command:

```
python3 -c 'import cowsay; cowsay.cow("Hello, my name is Cow!")'
```

You should see the following message:

```
  ______________________
| Hello, my name is Cow! |
  ======================
                      \
                       \
                         ^__^
                         (oo)\_______
                         (__)\       )\/\
                             ||----w |
                             ||     ||
```

To test that `nano` or `vim` were installed, you can run the corresponding
command. You can also check the versions or help text; typically such 
commands only run successfully if the program is successfully installed.

```
nano --version
nano --help
```

```
vim --version
vim --help
```

When you are done testing the container, exit the container shell by entering

```bash
exit
```

The `Apptainer> ` prompt should disappear.

## Relocating the container image

Container image files can be large, so it is best to store them where you
normally store large software files.

**HTC**

The `/staging` system is the home for `.sif` files on the HTC system.

Move the `container.sif` file into your staging directory:

```
mv container.sif /staging/YOUR_NETID/
```

If you do not have a staging directory, you can skip this step, and
the file will be returned to your directory on the access point.
BUT before using the container at scale, you need to first place the
container in a staging directory;
[request a staging directory here](https://chtc.cs.wisc.edu/uw-research-computing/quota-request).

**HPC**

The `/home` filesystem is the home for `.sif` files on the HPC system.

Move the `container.sif` file into your home directory:

```
mv container.sif ~/
```

## Wrap up

**Remember to exit your interactive job!**

Now that you've built a container, you can use a similar procedure as
we did in the beginning to use it in your calculation.

We have quite a few guides about using containers on our website, and
they should get you most of the way to creating a container with your
software and using it in your large scale jobs.

**Apptainer guides**

* Use, build containers on **HTC**: [https://chtc.cs.wisc.edu/uw-research-computing/apptainer-htc](https://chtc.cs.wisc.edu/uw-research-computing/apptainer-htc)
* Use, build containers on **HPC**: [https://chtc.cs.wisc.edu/uw-research-computing/apptainer-hpc](https://chtc.cs.wisc.edu/uw-research-computing/apptainer-hpc)
* Convert Docker container to Apptainer: [https://chtc.cs.wisc.edu/uw-research-computing/htc-docker-to-apptainer](https://chtc.cs.wisc.edu/uw-research-computing/htc-docker-to-apptainer)
* Detailed guide to Apptainer definition files: [https://chtc.cs.wisc.edu/uw-research-computing/apptainer-build](https://chtc.cs.wisc.edu/uw-research-computing/apptainer-build)
* Example of an advanced Apptainer definition file: [https://chtc.cs.wisc.edu/uw-research-computing/apptainer-htc-advanced-example](https://chtc.cs.wisc.edu/uw-research-computing/apptainer-htc-advanced-example)

**Docker guides**

* Use Docker container on HTC: [https://chtc.cs.wisc.edu/uw-research-computing/docker-jobs](https://chtc.cs.wisc.edu/uw-research-computing/docker-jobs)
* Build a Docker container locally: [https://chtc.cs.wisc.edu/uw-research-computing/docker-build](https://chtc.cs.wisc.edu/uw-research-computing/docker-build)
* Test a Docker container locally: [https://chtc.cs.wisc.edu/uw-research-computing/docker-test](https://chtc.cs.wisc.edu/uw-research-computing/docker-test)

**Recipes**

* CHTC Recipes GitHub: [https://github.com/CHTC/recipes](https://github.com/CHTC/recipes)

See also our "Quickstart" software guides: [https://chtc.cs.wisc.edu/uw-research-computing/software-overview-htc#quickstart](https://chtc.cs.wisc.edu/uw-research-computing/software-overview-htc#quickstart)

## Advanced container build

The example definition file used for demonstrating how to build a container
is somewhat minimal. What if you need to "manually" install something?
What does that look like?

Here is a definition file that demonstrates a more advanced container build.
It's good practice to include comments for better reproducibility in the future,
for when something needs to be changed.

For more information on the parts of the definition file, see the detailed guide to Apptainer definition files:
[https://chtc.cs.wisc.edu/uw-research-computing/apptainer-build](https://chtc.cs.wisc.edu/uw-research-computing/apptainer-build)

```bash
Bootstrap: docker
From: python:3.13

%post
    # Debian/Ubuntu specific for installing packages
    chmod 777 /tmp
    export DEBIAN_FRONTEND=noninteractive
    apt update -y
    apt install -y \
        git \
        golang \
        nano \
        vim

    python3 -m pip install requests numpy

    # Generally recommended to put user-installed programs into the /opt directory.
    mkdir -p /opt/
    cd /opt

    ##########################
    # Installing "GNU Units" #
    ##########################

    # https://www.gnu.org/software/units/

    # Creating a build directory for easy cleanup
    mkdir units-build
    cd units-build

    # Downloading the source code, per instructions on their website.
    wget -4 https://mirror.us-midwest-1.nexcess.net/gnu/units/units-2.24.tar.gz

    # Extracting source code; creates directory "units-2.24"
    tar -xzf units-2.24.tar.gz
    cd units-2.24

    # "configure, make, make install" is a common installation pattern for Linux
    # For full instructions, you'll need to download the source code and look at the
    #  "INSTALL" file included in it.

    # Here, we specify the location ("prefix") where the final program should be installed.
    # This step also detects if the system has the necessary dependencies to install it.
    ./configure --prefix=/opt/units

    # This compiles the program using the information from the configure step
    make

    # This copies the minimal set of files required for the program to run
    #  over to the "prefix" location.
    make install

    # Move out of the build directory
    cd /

    # Remove the build directory to reduce size of container image
    rm -rf /opt/units-build/

    #################################
    # Installing rclone from source #
    #################################

    # Following instructions from https://rclone.org/install/#source

    # **In practice**, should instead follow the instructions for installing on Linux:
    # https://rclone.org/install/#linux
    # Also, you shouldn't use rclone inside of 10+ HTC jobs!!!
    # Better to download all at once to /staging..

    # Create build directory
    mkdir -p /opt/rclone-build
    cd /opt/rclone-build

    # Download source code using git
    git clone https://github.com/rclone/rclone.git
    cd rclone

    # Install using the go language. The first part tells it where to install
    # the executable file.
    GOBIN="/opt/rclone/bin" go install ./

    # Clean up build directory
    cd /
    rm -rf /opt/rclone-build

%environment
    # This tells the launched container where to look for shell commands.
    # Multiple locations should be provided at the same time, colon-separated.
    export PATH=/opt/rclone/bin:/opt/units/bin:$PATH
```

Try to avoid putting *everything* into one container, unless it is required to run
the main program. Container image files can get large, which can cause issues on 
the HTC system. In general, you want to only put things in the container necessary
to run the primary task of the container. 

There will be a lot of output generated during the `apptainer build` step for
the above container.
You may find it useful to record that output to a file for easier reading if
you encounter an error during the build. 
You can do this, and still get the live output, using the following command:

```bash
apptainer build container.sif container.def 2>&1 | tee build.log
```

The `tee` commmand will simultaneously print the output messages and save them to
the `build.log` file during the build.

## Install MPI

It is possible to install MPI in a container like any other program.
However, whether it will be functional depends on how you try to use the container.

If you are using the container to run a job **on at most 1 node at a time**, then 
you shouldn't have any issues. Use your "normal" installation instructions in the
definition file to install the MPI.

If you are using the container to run a job **on 2 or more nodes at a time**
(only possible on the HPC system), then the MPI needs to be configured to work with 
our hardware! This is a lot more complicated than it sounds.
We do have a [recipe for multi-node MPI containers](https://github.com/CHTC/recipes/tree/main/workflows-hpc/multi-node-container),
but given the complexity, we recommend that you work with the facilitation team to
get your software deployed.

