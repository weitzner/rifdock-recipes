FROM continuumio/miniconda3

# Set an encoding to make things work smoothly.
ENV LANG en_US.UTF-8

# Run common commands
COPY scripts/run_commands_rifdock /opt/docker/bin/run_commands
RUN /opt/docker/bin/run_commands

# Add a file for users to source to activate the `conda`
# environment `root` and the devtoolset compiler. Also
# add a file that wraps that for use with the `ENTRYPOINT`.
COPY scripts/entrypoint_source /opt/docker/bin/entrypoint_source
COPY scripts/entrypoint /opt/docker/bin/entrypoint

# If you have a patchdock license and want to copy it over, put the directory
# in the linux-anvil directory, name it "PatchDock" and uncomment the line below
# COPY PatchDock /usr/local/bin

# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `root` and the devtoolset compiler.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]
