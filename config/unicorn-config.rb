$default_env = "production"

$dev_processes = 4
$prod_processes = 16

$timeout = 75

$listen = 3000

# Main config for Unicorn
rails_env = ENV['RAILS_ENV']|| $default_env
worker_processes 4
#preload_app true
timeout $timeout
listen $listen

stderr_path "/var/html/dataclouds-3alpha-alpha/log/unicorn.log"
stdout_path "/var/html/dataclouds-3alpha-alpha/log/unicorn.log"

