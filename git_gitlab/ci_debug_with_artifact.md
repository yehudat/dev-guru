## Capturing the Compile Log in GitLab CI

To capture the compile log and identify errors in the GitLab CI pipeline, redirect the output to a log file and save it as an artifact.

### GitLab CI debug with artifacts Example

```yaml
py_unittest:
  stage: test
  script:
    - ./status.sh vlog -suppress 2897 -warning 2971 -incr -sv -work tb_lib -f tb_utils/files.txt -f files.txt > compile.log 2>&1
  artifacts:
    paths:
      - compile.log
  after_script:
    - cat compile.log
```
### Explanation of code

- **Run the Script**: The script section runs `status.sh` and redirects both stdout and stderr to `compile.log`.
- **Artifacts**: The artifacts section specifies `compile.log` to be saved as an artifact, allowing you to download and inspect it after the job completes.
- **After Script**: The after_script section prints the contents of `compile.log` to the console output for easier debugging.

