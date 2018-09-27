# Vagrant Tools

> Provides a vagrant image loaded with the tools required to deploy and run a Cloud Foundry instance from this repo

## Prerequistes

- `Virtualbox`
- `Vagrant`

## To use

```
cd <path-to-repo>/tools/vagrant
vagrant up
```

Once you have a vm running, you can connect to it with

```
vagrant ssh
```

The vm mounts the main repo folder as a shared folder under `/src`