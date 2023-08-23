# Release procedure

1. Update `changelog.md`
2. Commit and push your changes
3. Tag that commit using the below command (`x`, `y` and `z` are the major, minor and patch versions defined by [Semantic Versioning](https://semver.org/)):
```bash
git tag -a x.y.z && git push --tags
```

