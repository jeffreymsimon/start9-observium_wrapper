# start9-observium_wrapper
start9-observium_wrapper


## Setup

* [Install Docker](https://docs.docker.com/engine/install/ubuntu/)
* Enable `buildx`
  ```
  docker buildx install
  docker buildx create --use
  ```

## Build Image
```
make image SVN_USERNAME=<username> SVN_PASSWORD=<password>
```

## Build Image Tar
```
make image.tar SVN_USERNAME=<username> SVN_PASSWORD=<password>
```
