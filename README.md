# docker-analysis-template
An example of using docker to publish a specific analysis, using the `labwaller/base image`. This repo contains all the files necessary to create the Docker image `labwaller/docker-analysis-template`. To build this image locally, one can clone this repo and then execute `docker build -t {image-name} .` within this repo. 

## How to create a custom Docker image for an analysis
When you first conduct the analysis, you will want to launch the `labwaller/base` image and conduct your analysis within the container. Working in the environment you will eventually ship to other users ensures maximum consistency. To do this and still save your data even after the container is killed, you will want to attach a volume to the container. This process mounts a local drive to the file structure in your Docker container. 

```bash
# Locally, create main directory to store everything
mkdir ~/analysis_dir/
cd ~/analysis_dir/

# Create subdirectories
mkdir code/ data/ figures/ report/

# Launch container using lab image and set volume
docker run --rm -dp 8787:8787 -e USER=username -e PASSWORD=password -v ~/analysis_dir/:/home/rstudio/analysis_dir/ labwaller/base:latest
```

The above command mounts the local directory `~/analysis_dir/` and all its contents to the directory `/home/rstudio/analysis_dir/` within the Docker container. You can then login to the RStudio Server session using your chosen username and password at `http://localhost:8787`. You should see the directory structure you specified in your local drive appear in the home working directory of the RStudio session. You can then conduct your analysis as you normally would, and any code or data saved in the folder structure will persist locally even after the container is killed. Once the analysis is finished, you can create a new image specific to this analysis by creating a `Dockerfile` at `~/analysis_dir/Dockerfile` that follows the below format. Essentially, you want to replicate the folder structure you specified in the beginning that you used for the volume, and then copy over all the code and data in your local drives into the appropriate directories of the image.

```bash
FROM labwaller/base:latest

ARG home=/home/rstudio/

RUN cd $home && mkdir -p code/ data/ figures/ report/

COPY code/* ${home}code/
COPY data/* ${home}data/
COPY figures/* ${home}figures/
COPY report/* ${home}report/
```

So at this point, all the code, data, and figures we want to share are all set to go. And we have written a new `Dockerfile` that will create a Docker image that is the same as the one we worked in for our analysis (`labwaller/base`), but now we have copied over the code and data to the Docker image permanently using the `COPY` commands.  All that's left to share it to the world, is to build this new image, and push it to Docker Hub. Previously these files were only accessible by mounting our local drives through the `volume` argument in `docker run`. Once the image containing the files is on Docker Hub, anyone who downloads this image will be able to have access. Tagging and pushing the image can be done as follows.

```bash
docker tag {IMAGE ID} labwaller/{custom-repo-name}:{tag} 
docker push labwaller/{custom-repo-name}:{tag}
```

## Usage
For users of this custom and those that want to replicate the results of the analysis, they will need to first have docker installed. Then from the command line they can just execute the following command to download the [Docker image we pushed to the Docker Hub](https://hub.docker.com/r/labwaller/docker-analysis-template) and launch a container from it.

```bash
docker run --rm -dp 8787:8787 -e USER=username -e PASSWORD=password labwaller/{custom-repo-name}:{tag}
```

Similar to above, the user just needs to login to the RStudio Server session in their browser at `http://localhost:8787`. Everything they need to replicate the analysis that was created should be there.
