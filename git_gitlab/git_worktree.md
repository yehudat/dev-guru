# Git Worktree

The feature allows to define an unmanaged directory, as managed. It helps in merging the generated changes
(for instance, a ZIP sent by a careless developer) into your existing dev branch without losing history,
without overwriting unrelated files, and without creating a nightmare merge.

## Step 1: Extract the ZIP into a temporary directory

```bash
mkdir /tmp/dir_with_feature
unzip dir_with_feature.zip -d /tmp/dir_with_feature
```

## Step 2: Add that temporary directory as a Git worktree

```bash
git worktree add /tmp/dir_with_feature zipped_feature
cd /tmp/dir_with_feature
git add .
git commit -m "Import new-feature updates from the ZIP"
```

## Step 3: Switch back to your dev branch

```bash
git checkout local_dev_branch
```

## Step 4: Merge the update branch into dev

Use a recursive merge with patience (best for big structural diffs):

```bash
git merge zipped_feature --strategy-option=patience
```

If you expect conflicts, use:

```bash
git merge zipped_feature -X ours
```

## Step 5: Review conflicts, solve and commit

```bash
git add .
git commit
```

## Step 6: Delete the temporary worktree

```bash
git worktree remove /tmp/svlang_update_branch
rm -rf /tmp/svlang_update
```

