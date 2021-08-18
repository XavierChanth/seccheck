<img src="https://atsign.dev/assets/img/@dev.png?sanitize=true">

### Now for a little internet optimism

# SecondaryCheck README

seccheck (secondaryCheck) is a couple of scripts that check all the secondaries that are running 
on a docker swarm. The check is simple, can openssl connect with the secondary and can the scan verb
be used giving a publicSigning key.

The intent is to find and report via gChat to the swarm operators if any secondaries are found to be problematic.

We welcome contributions - we want pull requests and to hear about issues.

## Who is this for?

This script is for DevOps who run a docker swarm running the @protocol and who want to ensure the well being of the secondaries running on the swarm.



## Why, What, How?

### Why?

Secondaries need to be checked regularly to ensure they can serve requests. Prior to this script running people had to report issues, this script checks regularly and can provide an early resolution to secondaries that either are not responding at all or have an inability to answer a simple scan request.

### What?

The only dependancy required on the machine running the scripts is the installation of expect.
On an ubuntu machine this is pretty simple..

```sudo apt install expect```

Once installed the script can be installed and run either directly or via cron. In either case the account running the script must have docker group permissions.

The only other thing to make sure is that the shell and expect scripts have executable flags set using `chmod 755 seccheck checksecondary.expect`.

### How?

The script makes use of the `docker service ls` command to list all the running services this is then used to derive the running secondaries on the swarm. The port number each secondary is listening on is then passed to a `expect` script and any failures are logged in `/tmp/seccheck`. The resulting number of failing secondaries is passed to gChat via a webhook/curl.

The number of Problematic Secondaries is sent to gChat via a webhook. The webhook URL is needed and instructions on how to do that can be found [here](https://developers.google.com/chat/how-tos/webhooks)





## Maintainers

[@cconstab](https://github.com/cconstab)

Always happy to have contributions via pull requests and issues raised!
