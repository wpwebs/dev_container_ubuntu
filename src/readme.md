### Create a Dev Container Project with multiple services using docker-compose.yml then open it in VSCode

_The development environment will install Jupyter Notebook and Oh My Zsh with plugins, theme with customize Zsh prompt_

### Usage: 
```sh
# Start project and open the code container in VSCode:
./start_devcontainer.sh [Project Name] [Environment]
"environment: development | dev | production | prod"

# Stopping the Services:
project_name=webapp
docker-compose -p $project_name -f .devcontainer/docker-compose.yml down

```
**Example:**
```sh
# Build and Open the project container in VSCode - development environment 
./start_devcontainer.sh
./start_devcontainer.sh development
./start_devcontainer.sh WebApp dev

# Build and Open the project container in VSCode - development environment 
./start_devcontainer.sh WebApp production
./start_devcontainer.sh WebApp prod

```

```sh
# Project Directory Structure
project/
├── start_devcontainer.sh
├── .gitignore
├── .devcontainer/
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── docker-compose.yml
├── .dot_files/
│   └── .p10k.zsh
├── .ssh/
│   ├──  ssh_key
│   └── ssh_key.pub
└── src/
    ├── __init__.py
    ├── requirements.txt
    ├── entrypoint.sh
    ├── main.py
    └── ... (other source files)

# Preparing ssh_key file
mkdir -p .ssh
op read "op://dev/id_henry/public key" > .ssh/ssh_key.pub && chmod 644 .ssh/ssh_key.pub
op read "op://dev/id_henry/private key" > .ssh/ssh_key && chmod 600 .ssh/ssh_key
```


### Some debug commands:

```sh
# define project name
project=fastapi
# build image - production environment (default)
docker build --build-arg ENVIRONMENT=production -f .devcontainer/Dockerfile -t $project-image .
docker build -f .devcontainer/Dockerfile  -t $project-image .
# build image - development environment 
docker build --target development --build-arg ENVIRONMENT=development -f .devcontainer/Dockerfile -t $project-image .
docker build --target development --build-arg ENVIRONMENT=dev -f .devcontainer/Dockerfile -t $project-image .

# run docker
docker run -d --name $project -p 80:80 -v $(pwd):/code $project-image

# debug
docker run --name $project -p 80:80 -v $(pwd):/code $project-image
docker run --name $project -p 80:80 $project-image
# remove docker
docker rm $project -f  

docker image list
docker image rm $project-image

docker run --name $project -it --entrypoint /bin/zsh $project-image

docker exec -it $project /bin/zsh

# delete all Docker images with <none> as their name (also known as dangling images)
docker image prune -f

# Clean up dangling images and stopped containers
echo "Cleaning up unused Docker resources..."
docker system prune -f


dockercompose_file=".devcontainer/docker-compose.yml"
environment=production
docker compose -f $dockercompose_file up  --build-arg ENVIRONMENT=$environment

docker compose -f $dockercompose_file build --build-arg ENVIRONMENT=$environment
```

### Other commands for cleaning up

```sh
docker rm container_name
docker image rm image_name
docker system prune
docker images prune

# Check folder size:
du -sh *
```