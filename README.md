![Alvis](alvis_logo.svg)
# Batch Connect - Alvis OnDemand VNC

Interactive App Plugin for launching a VNC Server at [Alvis OnDemand](https://portal.c3se.chalmers.se).

## Prerequisites

## Install
The app itself is pretty much self-contained and should only need to be placed
as e.g. `/var/www/ood/apps/sys/bc_alvis_vnc`.

```
$ cd /var/www/ood/apps/sys/
$ git clone https://github.com/c3se/bc_alvis_vnc.git
```

## Customizations
You can customize how VNC server is started by overriding configuration in
`~/portal/vnc/bc_alvis_vnc.env`.

## Debugging
Logs gets written to `$HOME/.local/share/bc_alvis_vnc/`.
