# TCI - Tikal Jenkins-based CI solution

![tci](images/tci-server.png)

### ***TCI - Tikal Jenkins-based CI solution***
Powered by **[Tikal Knowledge](http://www.tikalk.com)** and the community.
<hr/>

With this repository, you can establish <img src="images/tci-server.png" width="80" height="80"> **tci-server** - for loading a well-established Jenkins server.

In order to establish a <img src="/images/tci-server.png" width="60" height="60"> **tci-server**, follow the below instructions on the server you want to host it:

1. Make sure you have the following commands installed: **git**, **docker** & **docker-compose**.
1. clone this repository (https://github.com/TikalCI/tci-server.git) to a local folder and cd to it.
1. Run _**./tci.sh init**_ to see that the path to the SSH private key file is correct and to set all values.
1. Run _**./tci.sh start**_ to load the server. 
1. The first load will take at least 10 minutes, so please wait until the prompt is back.
1. Once the load is over, browse to [http://localhost:8080](http://localhost:8080) and login with admin/admin credentials.

Once the server is up, you can modify it (e.g. add LDAP configuration, add seed jobs, add credentials and much more) following the instructions as in [tci-bloody-jenkins](https://github.com/TikalCI/tci-bloody-jenkins) and all files in the 'customization' folder.

The _**./tci.sh**_ script have the following actions: **start**, **stop**, **restart**, **info**, **init**, **upgrade**, **status**, **apply**, **version**.

The loaded server is already configured to work with [<img src="images/tci-library.png" width="60" height="60"> tci-library](https://github.com/TikalCI/tci-library) so you can start working with it and<br/>use [<img src="images/tci-pipelines.png" width="60" height="60"> tci-pipelines](https://github.com/TikalCI/tci-pipelines) as a reference as well.

If you want to participate in the TCI project as an active contributor, please refer to [<img src="images/tci-dev.png" width="60" height="60"> tci-dev-env](https://github.com/TikalCI/tci-dev-env).

