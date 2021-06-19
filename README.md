# rifdock-recipes
Conda recipes for rifdock.

## Building
There are two phases of builds that are required: building conda packages and a docker image.
First, build the conda packages for rifdock and its rosetta dependency with the following commands:
```bash
./docker_build.sh rosetta_omp [CONDA CHANNEL PATH] [GITHUB TOKEN FILE]
./docker_build.sh rifdock [CONDA CHANNEL PATH] [GITHUB TOKEN FILE]
```

Those packages do not need to built again unless there is a compelling upstream update that we'd like to use.
That being said, as our workflow evolves, we may wish to capture that in our container by including additional scripts or tools.
To build an image with rifdock installed via conda, use the following command:
```bash
./create_rifdock_image.sh [CONDA CHANNEL PATH]
```

## Using
Move the exported image to your work machine, and load the image with the following command
```bash
docker load < rifdock.latest.tar
```
then you can get an interactive session in the container with
```bash
docker run -it rifdock:latest bin/bash
```

or run a rif command directly
```bash
docker run \
           -v [RIF INPUT DIR]:/home/conda/rif:rw,z \
           -e HOST_USER_ID=$(id -u) \
           rifdock:latest \
           /bin/bash -c "cd /home/conda/rif && rifgen @rifgen.flags"
```
where the `RIF INPUT DIR` and the precise command (in quotes) should be adjusted based on your usecase.
