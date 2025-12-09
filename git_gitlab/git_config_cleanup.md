## Commands to Clean Repo Internals, as Maintanence or Issue Solution

### `git gc` Command


The `git gc` command is used to clean up and optimize the repository by performing several maintenance tasks, such as:

- **Compressing File History**: It compresses and packs loose objects (commits, trees, and blobs) into a more efficient format.
- **Pruning Old Data**: It removes unreachable objects (like old commits that are no longer referenced) that are no longer needed.
- **Optimizing References**: It optimizes references and other internal data structures.

### Basic Usage

```bash
git gc
```

This runs the garbage collection with the default settings.

### Forcing Cleanup

If you want to force a more thorough cleanup, including the removal of more aggressively old and unnecessary files, you can use:

```bash
git gc --aggressive
```

- **`--aggressive`**: This option causes Git to spend more time optimizing the repository, which may result in better performance at the cost of increased processing time.
### Prune Unreachable Objects
While `git gc` handles pruning by default, you can manually prune unreachable objects (like old commits and branches that are no longer referenced) with:

```bash
git prune
```

### Cleaning Up Corrupt or Incomplete Packs

Sometimes, you might encounter issues with corrupt or incomplete pack files. In such cases, you can 
use:

```bash
git fsck --full
```

This command checks the integrity of the repository, looking for any corrupt objects or other issues. Afterward, running `git gc` again can help clean up the problems detected by `git fsck`.

### Example Workflow

Here’s an example workflow to clean up and optimize your repository:

1. **Run Garbage Collection**:
  ```bash
  git gc
  ```
2. **(Optional) Run Aggressive Garbage Collection**:
  ```bash
  git gc --aggressive
  ```
3. **(Optional) Prune Unreachable Objects**:
  ```bash
  git prune
  ```
4. **(Optional) Check for Corrupt Objects**:
  ```bash
  git fsck --full
  ```
5. **Re-run Garbage Collection if Needed**:
  ```bash
  git gc
  ```
### When to Use `git gc`

- **After Deleting a Large Number of Files or Branches**: Running `git gc` helps remove the old data and compress the repository.
- **When You Notice Performance Issues**: If Git operations are slowing down, running `git gc` can help optimize the repository and improve performance.
- **As Part of Regular Maintenance**: Occasionally running `git gc` as part of repository maintenance keeps the repository in good health.