# Useful command-lines for vcover utility

## Fetching cover XMRs, as STDOUT

The command below, also "greps" out coverage directives, which label starts from `COVER_`.

```
vcover report tests/lvds_ut.ucdb -codeAll -annotate -details -assert -cvg -directive | grep COVER_
```