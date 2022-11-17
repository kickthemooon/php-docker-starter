# PHP - Quick-Start using Docker

This repository serves as php (laravel or symfony) quick-start using docker.

## Requirements

- docker
- docker-compose
- shell (Linux, MacOS, MS WSL2, VM)

## Quick-Start

- run `hlp/init` and follow the wizard

## Other Helper Commands
- `hlp/start` - starts the project using docker-compose - http://localhost
- `hlp/console "{command}"` - show and run console (laravel or symfony) commands
- `hlp/logs "{service}"` - e.g. `hlp/logs fpm`
- `hlp/status` - show docker-composer services by status
- `hlp/exec "{service}" "{command}"` - run a command in a service e.g. `hlp/exec fpm bash`
- `hlp/test "{filter}"` - run phpunit tests e.g. `hlp/test "ExampleTest::testSeomthing"`
- `hlp/build` - build the docker image e.g. `hlp/build "app/php-fpm:develop"`
- `hlp/restart` - restart docker-compose
- `hlp/stop` - stop docker-compose
- `hlp/composer ` - manage dependencies

## Manage & Install Dependencies

Like all php projects, this one also manages dependencies with composer.

### Install 

You can review `app/composer.json` for the dependency versions and install them using the helper script:  
```
hlp/composer install
```

For other dependency tasks (upgrade, add etc.) you can refer to the [composer documentation](https://getcomposer.org/doc/01-basic-usage.md)

## PHP Configuration

You can look and adjust the php configuration under `config/php.ini` and the fpm pool configuration under `config/www.conf`

## Nginx Configuration

You can look and adjust the nginx configuration under `nginx/nginx.conf` and `nginx/default.conf`

## Running Tests

As mentioned above, you can run tests using the helper `hlp/test "{filter}"`. The filter has the following format if you want the highest specificity:  
```
hlp/test "Namespace\\Path\\ClassName::testMethod"
```
Slash (/) and backslash (\) are converted to double backslash so you can also run:  
```
hlp/test "Namespace/Path/ClassName::testMethod"
# or
hlp/test "Namespace\Path\ClassName::testMethod"
```
Alternatively you filter with lower specificity:  
```
hlp/test "Path/ClassName"
# or
hlp/test "ClassName::testMethod"
# or
hlp/test "ClassName"
```
And if you want to work with phpunit directly you can use `hlp/phpunit`.  

What I also like to do, when doing TDD or refactoring, is to use `watch`. I pick a test class and run the tests continuously while writing my code, so I continuously see the state of my test without having to run it manually everytime I change something.
```
watch --color "$(pwd)/test 'Example\ExampleTest'"
```

## Debugging

Since this is a php project the debugger is, you guessed it, XDebug. It is installed but disabled by default in the docker image. To enable it we mount the configuration file (`./xdebug/xdebug.ini`) into the php-fpm services (fpm and test) in the `docker-compose.yaml` file.

To configure XDebug in PHPStorm follow these steps:  

1. Add the server to `File | Settings | Languages & Frameworks | PHP | Servers`

![phpstorm-server](https://i.imgur.com/Q38EyWt.jpg "phpstorm server")

The server name comes from the `./nginx/default.conf` `server_name`

2. Add the "XDebug Helper" extension to chrome

![xdebug-helper](https://i.imgur.com/6t2yfZ7.png "xdebug helper")

3. Check debugging settings in phpstorm and start listening for 

![xdebug-settings](https://i.imgur.com/BgtGGKd.png "xdebug settings")

![xdebug-listening](https://i.imgur.com/T0tqLgo.png "xdebug listening")

## Dockerfile

The Dockerfile used for running php-fpm comes with a few preinstalled utilities like:  
- Composer
- XDebug
- Imagick
- GD
- and many other ...
You are welcome to review the Dockerfile and adjust it to your needs

## Other Documentation

Laravel - For more about Laravel please refer to [its documentation](https://laravel.com/docs/9.x)  
Symfony - For more about symfony please refer to [its documentation](https://symfony.com/doc/current/index.html)  
Composer - For more about composer please refer to [its documentation](https://getcomposer.org/doc/)  
PHPUnit - For more about phpunit please refer to [its documentation](https://phpunit.readthedocs.io/en/9.5/)  
Docker - For more about docker please refer to [its documentation](https://docs.docker.com/)  
Nginx - For more about nginx please refer to [its documentation](https://nginx.org/en/docs/)  