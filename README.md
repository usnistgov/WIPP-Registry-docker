# WIPP-Registry Docker

This repository contains `docker-compose` files to build and deploy CDCS containers, with custom settings for the [WIPP-Registry project](https://github.com/usnistgov/WIPP-Registry.git).

## Prerequisites

Install [Docker](https://docs.docker.com/engine/install/#server) first, then install [Docker Compose](https://docs.docker.com/compose/install/).


## Build a CDCS image (optional)

WIPP-Registry Docker images are available on DockerHub, but you can build your own images with following instructions:

### 1. Customize the build

Update the values in the `.env` file:

``` bash
$ cd build
$ vim .env
```

Below is the list of environment variables to set and their description.

| Variable | Description |
| ----------- | ----------- |
| PROJECT_NAME          | Name of the CDCS/Django project to build (e.g. wipp-registry) |
| IMAGE_NAME            | Name of the image to build (e.g. wipp-registry) |
| IMAGE_VERSION         | Version of the image to build (e.g. latest, 1.1.0) |
| CDCS_REPO             | URL of the CDCS repository to clone to build the image (e.g. https://github.com/usnistgov/WIPP-Registry.git) |
| BRANCH                | Branch/Tag of the repository to pull to build the image (wipp-registry or wipp-registry-saml for SAML-based authentication) |
| PIP_CONF              | Pip configuration file to use to build the image |
| PYTHON_VERSION        | Version of the Python image to use as a base image for the CDCS image |


### 2. Build the image

``` bash
$ docker-compose build --no-cache
```



## Deploy a CDCS/WIPP-Registry

### 1. Customize the deployment

Update the values in the `.env` file:

``` bash
$ cd deploy
$ vim .env
```
Below is the list of environment variables that can be set and their
description. Commented variables in the `.env` need to be uncommented
and filled.

| Variable | Description |
| ----------- | ----------- |
| PROJECT_NAME          | Name of the CDCS/Django project to deploy (e.g. nmrr) |
| IMAGE_NAME            | Name of the CDCS image to deploy (e.g. wipp/wipp-registry) |
| IMAGE_VERSION         | Version of the CDCS image to deploy (e.g. 1.1.0, 1.1.0-saml) |
| HOSTNAME              | Hostname of the server (e.g. for local deployment, use the machine's IP address xxx.xxx.xxx.xxx) |
| SERVER_URI            | URI of server (e.g. for local deployment, http://xxx.xxx.xxx.xxx) |
| ALLOWED_HOSTS         | Comma-separated list of hosts (e.g. ALLOWED_HOSTS=127.0.0.1,localhost), see [Allowed Hosts](https://docs.djangoproject.com/en/2.2/ref/settings/#allowed-hosts) |
| SERVER_NAME           | Name of the server, used to distinguish instances in federated queries (e.g. {INSTITUTION}-WIPP or {INSTITUTION}-{CUSTOM-WIPP-NAME}) |
| SETTINGS              | Settings file to use during deployment ([more info in the Settings section](#settings))|
| SERVER_CONF           | Mount appropriate nginx file (e.g. default for http, https otherwise. The protocol of the `SERVER_URI` should be updated accordingly) |
| MONGO_PORT            | MongoDB Port (default: 27017) |
| MONGO_ADMIN_USER      | Admin user for MongoDB (should be different from `MONGO_USER`) |
| MONGO_ADMIN_PASS      | Admin password for MongoDB |
| MONGO_USER            | User for MongoDB (should be different from `MONGO_ADMIN_USER`) |
| MONGO_PASS            | User password for MongoDB |
| MONGO_DB              | Name of the Mongo database (e.g. cdcs) |
| POSTGRES_PORT         | Postgres Port (default: 5432) |
| POSTGRES_USER         | User for Postgres |
| POSTGRES_PASS         | User password for Postgres |
| POSTGRES_DB           | Name of the Postgres database (e.g. cdcs) |
| REDIS_PORT            | Redis Port (default: 6379) |
| REDIS_PASS            | Password for Redis |
| DJANGO_SECRET_KEY     | [Secret Key](https://docs.djangoproject.com/en/2.2/howto/deployment/checklist/#secret-key) for Django (should be a "large random value") |
| NGINX_PORT_80         | Expose port 80 on host machine for NGINX |
| NGINX_PORT_443        | Expose port 443 on host machine for NGINX |
| MONGO_VERSION         | Version of the MongoDB image |
| REDIS_VERSION         | Version of the Redis image |
| POSTGRES_VERSION      | Version of the Postgres image |
| NGINX_VERSION         | Version of the NGINX image |
| UWSGI_PROCESSES       | Number of uwsgi processes to start (default 10) |
| MONITORING_SERVER_URI | (optional) URI of an APM server for monitoring |
| SAML_METADATA_CONF_URL| (optional) URI of a SAML metadata configuration |
| SAML_CREATE_USER      | (optional) Determines if a new Django user should be created for new users |
| SAML_ATTRIBUTES_MAP_EMAIL| (optional) Mapping of Django user attributes to SAML2 user attribute - email |
| SAML_ATTRIBUTES_MAP_USERNAME| (optional) Mapping of Django user attributes to SAML2 user attribute - username |
| SAML_ATTRIBUTES_MAP_FIRSTNAME| (optional) Mapping of Django user attributes to SAML2 user attribute - firstname |
| SAML_ATTRIBUTES_MAP_LASTNAME| (optional) Mapping of Django user attributes to SAML2 user attribute - lastname |
| SAML_ASSERTION_URL| (optional) A URL to validate incoming SAML responses against |
| SAML_ENTITY_ID| (optional) The optional entity ID string to be passed in the 'Issuer' element of authn request, if required by the IDP |
| SAML_NAME_ID_FORMAT| (optional) Set to the string 'None', to exclude sending the 'Format' property of the 'NameIDPolicy' element in authn requests. Default value if not specified is 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient' |
| SAML_USE_JWT| (optional) JWT authentication - False |
| SAML_CLIENT_SETTINGS| (optional) Client settings - False |
A few additional environment variables are provided to the CDCS
container. The variables below are computed based on the values of
other variables. If changed, some portions of the `docker-compose.yml`
might need to be updated to stay consistent.

| Variable | Description |
| ----------- | ----------- |
| DJANGO_SETTINGS_MODULE  | [`DJANGO_SETTINGS_MODULE`](https://docs.djangoproject.com/en/2.2/topics/settings/#envvar-DJANGO_SETTINGS_MODULE) (set using the values of `PROJECT_NAME` and `SETTINGS`)  |
| MONGO_HOST | Mongodb hostname (set to `${PROJECT_NAME}_cdcs_mongo`) |
| POSTGRES_HOST | Postgres hostname (set to `${PROJECT_NAME}_cdcs_postgres`) |
| REDIS_HOST | REDIS hostname (set to `${PROJECT_NAME}_cdcs_redis`) |


#### SAML2

Configure SAML2 authentication by providing values for the following environment variables in the `saml2/.env` file.
See `saml2/.env.example` for an example of SAML2 configuration with a Keycloak server.

| Variable | Description |
| ----------- | ----------- |
| ENABLE_SAML2_SSO_AUTH | Enable SAML2 authentication (e.g. `ENABLE_SAML2_SSO_AUTH=True`)|
| SAML_ATTRIBUTE_MAP_DIR | Points to a directory which has the attribute maps in Python modules (see [attribute_map_dir](https://pysaml2.readthedocs.io/en/latest/howto/config.html#attribute-map-dir))|
| SAML_ATTRIBUTES_MAP_IDENTIFIER | SAML attribute map supported name-format (see [attribute_map_dir](https://pysaml2.readthedocs.io/en/latest/howto/config.html#attribute-map-dir)) |
| SAML_ATTRIBUTES_MAP_UID | SAML attribute mapping to uid |
| SAML_ATTRIBUTES_MAP_UID_FIELD | SAML attribute mapping uid field name |
| SAML_ATTRIBUTES_MAP_EMAIL| SAML attribute mapping to email |
| SAML_ATTRIBUTES_MAP_EMAIL_FIELD| SAML attribute mapping email field name |
| SAML_ATTRIBUTES_MAP_CN | SAML attribute mapping to common name |
| SAML_ATTRIBUTES_MAP_CN_FIELD | SAML attribute mapping common name field name |
| SAML_ATTRIBUTES_MAP_SN | SAML attribute mapping to surname |
| SAML_ATTRIBUTES_MAP_SN_FIELD | SAML attribute mapping surname field name |
| SAML_DJANGO_USER_MAIN_ATTRIBUTE | Django field to use to find user and create session (see [user attributes and account linking](https://djangosaml2.readthedocs.io/contents/setup.html#users-attributes-and-account-linking))|
| SAML_USE_NAME_ID_AS_USERNAME | Use SAML2 name id as username (see [user attributes and account linking](https://djangosaml2.readthedocs.io/contents/setup.html#users-attributes-and-account-linking))|
| SAML_CREATE_UNKNOWN_USER | Create user if not found in Django database (see [user attributes and account linking](https://djangosaml2.readthedocs.io/contents/setup.html#users-attributes-and-account-linking))|
| SAML_KEY_FILE | Path to private key (see [key_file](https://pysaml2.readthedocs.io/en/latest/howto/config.html#key-file)) |
| SAML_CERT_FILE | Path to the public key (see [cert_file](https://pysaml2.readthedocs.io/en/latest/howto/config.html#cert-file)) |
| SAML_METADATA_REMOTE_URL | Url to remote SAML metadata file (see [metadata](https://pysaml2.readthedocs.io/en/latest/howto/config.html#metadata))|
| SAML_METADATA_REMOTE_CERT | (Optional) Certificate for the remote (see [metadata](https://pysaml2.readthedocs.io/en/latest/howto/config.html#metadata))|
| SAML_METADATA_LOCAL | Path to local SAML metadata file (see [metadata](https://pysaml2.readthedocs.io/en/latest/howto/config.html#metadata))|
| SAML_XMLSEC_BIN_PATH | Full path to xmlsec1 binary program (see [xmlsec_binary](https://pysaml2.readthedocs.io/en/latest/howto/config.html#xmlsec-binary)) |
| SAML_WANT_RESPONSE_SIGNED | Set to `True` if responses must be signed (see [want_response_signed](https://pysaml2.readthedocs.io/en/latest/howto/config.html#want-response-signed))|
| SAML_WANT_ASSERTIONS_SIGNED | Set to `True` if assertions must be signed  (see [want_assertions_signed](https://pysaml2.readthedocs.io/en/latest/howto/config.html#want-assertions-signed)) |
| SAML_LOGOUT_REQUESTS_SIGNED | Set to `True` if logout requests must be signed  (see [logout_requests_signed](https://pysaml2.readthedocs.io/en/latest/howto/config.html#logout-requests-signed)) |
| SAML_LOGOUT_RESPONSES_SIGNED | Set to `True` if logout responses must be signed  (see [logout_responses_signed](https://pysaml2.readthedocs.io/en/latest/howto/config.html#logout-responses-signed)) |
| SAML_SIGNING_ALGORITHM | Signing algorithm  (see [signing_algorithm](https://pysaml2.readthedocs.io/en/latest/howto/config.html#signing-algorithm)) |
| SAML_DIGEST_ALGORITHM | Digest algorithm  (see [digest_algorithm](https://pysaml2.readthedocs.io/en/latest/howto/config.html#digest-algorithm))|
| CONTACT_PERSON_N | Contact information for person N (see [contact_person](https://pysaml2.readthedocs.io/en/latest/howto/config.html#contact-person))  |
| ORGANIZATION_NAME_N | Organization name N (see [organization](https://pysaml2.readthedocs.io/en/latest/howto/config.html#organization))|
| ORGANIZATION_DISPLAY_NAME_N | Organization display name N (see [organization](https://pysaml2.readthedocs.io/en/latest/howto/config.html#organization))|
| ORGANIZATION_URL_N | Organization url N (see [organization](https://pysaml2.readthedocs.io/en/latest/howto/config.html#organization))|

##### Contact Person and Organization environment variables

Environment variables ending with suffix `_N` are expecting `N` to be a sequence of integers starting at `1`.
For example, if two contact persons need to be added to the SAML configuration, the following variables should be set:
```
CONTACT_PERSON_1=
CONTACT_PERSON_2=
```

1. Contact Person

A contact person environment variable is expecting a comma separated list of values in the following order:
- given name,
- surname,
- company,
- email address,
- type (technical, support, administrative, billing or other).

For example:
```
CONTACT_PERSON_1=Firstname1,Lastname1,Example Co.,contact1@example.com,technical
```

2. Organization

Each section of the SAML organization configuration is stored in a separate environment variable. Each variable is expecting a comma separated pair
composed of:
- label,
- language code.

Below is an example from the Pysaml2 documentation and how to represent it in the CDCS using environment variables.

Example from the [documentation](https://pysaml2.readthedocs.io/en/latest/howto/config.html#organization):
```
"organization": {
    "name": [
        ("Example Company", "en"),
        ("Exempel AB", "se")
    ],
    "display_name": ["Exempel AB"],
    "url": [
        ("http://example.com", "en"),
        ("http://exempel.se", "se"),
    ],
}
```

Equivalent CDCS configuration using environment variables:
```
ORGANIZATION_NAME_1=Example Company,en
ORGANIZATION_NAME_2=Exempel AB,se
ORGANIZATION_DISPLAY_NAME_1=Exempel AB,se
ORGANIZATION_URL_1=http://example.com,en
ORGANIZATION_URL_2=http://exemple.se,se
```

#### Settings

Starting from MDCS/NMRR 2.14, repositories of these two projects will
have settings ready for deployment (not production).

The deployment can be further customized by mounting additional settings
to the deployed containers:
- **Option 1 (default):** Use settings from the image. This option is recommended
if the settings in your image are already well formatted for deployment.
    - set the `SETTINGS` variable to `settings`.
- **Option 2**: Use default settings from the CDCS image and customize
them. Custom settings can be used to override default settings or add additional settngs. For example:
    - Create a `custom_settings.py` file (see `ci_settings.py` as example),
    - Update the `docker-compose.yml` file and uncomment the line that
        mounts the settings:
        ```
        # - ./cdcs/${SETTINGS}.py:/srv/curator/nmrr/${SETTINGS}.py
        ```
    - set the `SETTINGS` variable to `custom_settings`.

The [`DJANGO_SETTINGS_MODULE`](https://docs.djangoproject.com/en/2.2/topics/settings/#envvar-DJANGO_SETTINGS_MODULE)
environment variable can be set to select which settings to use. By
default the `docker-compose` file sets it using the values of
`PROJECT_NAME` and `SETTINGS` variables.

For more information about production deployment of a Django project,
please check the [Deployment Checklist](https://docs.djangoproject.com/en/2.2/howto/deployment/checklist/#deployment-checklist)

### SAML2 authentication

For SAML-based authentication:
- uncomment and set `SAML_*` variables in `.env` file
- change the `IMAGE_VERSION` variable in `.env` file from `wipp/wipp-registry:{version}` to `wipp/wipp-registry:{version}-saml` 
(e.g. `wipp/wipp-registry:1.1.0-saml`)

## 2. Deploy the stack

``` bash
$ docker-compose up -d
```

(Optional) For testing purposes, using the HTTPS protocol, you can then run the following script to generate and copy self signed certificates to the container.
``` bash
$ ./docker_set_ssl.sh
```

## 3. Create a superuser

The superuser is the first user that will be added to the CDCS. This is the
main administrator on the platform. Once it has been created, more users
can be added using the web interface. Wait for the CDCS server to start, then run:

```bash
$ ./docker_createsuperuser.sh ${username} ${password} ${email}
```

## 4. Access

The WIPP Registry is now available at the `SERVER_URI` set at deployment.
Please read important deployment information in the troubleshoot section below.

## 5. Custom XSLT

A custom XSL template for the display of WIPP plugins is provided under `deploy/cdcs/wipp-registry-detail.xsl`.  
The admin dashboard can be used to set this template as the default one in the registry:
- As a admin user, click on "Admin" and "Administration" to access the admin dashboard,
- On the left menu, select "XSLT List" and then click on the button "Upload XSLT",
- Enter the following XSLT name: `wipp-registry-detail.xsl` and choose the file `wipp-registry-detail.xsl` provided in the `deploy/cdcs` folder,
- On the left menu, select "Template List" and click on the "Versions" button of the active template,
- Click on the "XSLT" button of the current template,
- Under "Detail XSLT" choose `wipp-registry-detail.xsl` in the dropdown list and click on the "Save" button.

## 6. Troubleshoot

## Local deployment

**DO NOT** set `HOSTNAME`, `SERVER_URI` and `ALLOWED_HOSTS` to localhost or 127.0.0.1.
Even if the system, starts properly, some features may not work
(e.g. the search page may show an error instead of returning data).
When deploying locally, use the computer's IP address to set those two
variables, and use the same IP address **when accessing the CDCS via a web browser**:
If your machine's IP address is xxx.xxx.xxx.xxx, and the default server configuration was
used to deploy the system, access it by typing http://xxx.xxx.xxx.xxx in the address bar of the browser.

Find the IP of the local machine:
- On Linux and MacOS: `ifconfig`
- On Windows: `ipconfig`

Then update the `.env` file:

```
HOSTNAME=xxx.xxx.xxx.xxx
SERVER_URI=http://xxx.xxx.xxx.xxx
ALLOWED_HOSTS=xxx.xxx.xxx.xxx
```

**NOTE:** For testing purposes, `ALLOWED_HOSTS` can be set to `*`:
```
ALLOWED_HOSTS=*
```

## Production deployment

- Set `SERVER_CONF` to `https`
- Update the file `nginx/https.conf` if necessary
- Add HTTPS configuration to the mounted `settings.py` file
- Have a look at the [deployment checklist](https://docs.djangoproject.com/en/2.2/howto/deployment/checklist/#deployment-checklist)

## Logs

Make sure every component is running properly by checking the logs.
For example, to check the logs of an MDCS instance (`PROJECT_NAME=mdcs`), use the following commands:
```
$ docker logs -f mdcs_cdcs
$ docker logs -f mdcs_cdcs_nginx
$ docker logs -f mdcs_cdcs_mongo
$ docker logs -f mdcs_cdcs_postgres
$ docker logs -f mdcs_cdcs_redis
```

## MongoDB RAM usage


From https://hub.docker.com/_/mongo
> By default Mongo will set the wiredTigerCacheSizeGB to a value
proportional to the host's total memory regardless of memory limits
you may have imposed on the container. In such an instance you will
want to set the cache size to something appropriate, taking into
account any other processes you may be running in the container
which would also utilize memory.

Having multiple mongodb containers on the same machine could be an
issue as each of them will try to use the same amount of RAM
from the host without taking into account the amount used by other
containers. This could lead to the server running out of memory.

### How to fix it?

The amount of RAM used by mongodb can be restricted by adding the
`--wiredTigerCacheSizeGB` option to the mongodb command:

**Example:**
```yml
command: "--auth --wiredTigerCacheSizeGB 8"
```

More information on MongoDB RAM usage can be found in the
[doc](https://docs.mongodb.com/manual/faq/diagnostics/#faq-memory)

## Additional components

Additional components can be added to the CDCS stack by providing `docker-compose.yml` files for those.
Update the `COMPOSE_FILE` variable in the `.env` file to do so. More information can be found in on this option in the
[documentation](https://docs.docker.com/compose/reference/envvars/#compose_file).

### Elasticsearch

Ongoing developments on the CDCS make use of Elasticsearch.
To add Elasticsearch to the CDCS stack, you can do the following:

Update the `.env` file to deploy Elasticsearch:
```
COMPOSE_FILE=docker-compose.yml:elasticsearch/docker-compose.yml
```

Add and fill the following environment variables:

| Variable | Description |
| ----------- | ----------- |
| ELASTIC_VERSION          | Version of the Elasticsearch image (e.g. 7.14.1) |

On linux, you will need to increase the available [virtual memory](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/vm-max-map-count.html).

## Delete the containers and their data

To delete the containers and **all the data** stored in the deployed CDCS system, run:

```
$ docker-compose down -v
```

# Disclaimer

[NIST Disclaimer](https://www.nist.gov/disclaimer)
