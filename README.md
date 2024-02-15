# jupyter-deepg-notebook

## Build

```
sudo docker build -t jupyter-deepg-notebook
```

## Run

```
docker run -p 8888:8888 --gpus device=1 -it -v /path/to/folder/:/tf jupyter-deepg-notebook
```
