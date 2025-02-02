# Parser::FIT maintainance information

## Releasing

1) Bump version in `./lib/Parser/FIT.pm`
1) Run `perl Makefile.PL`
1) Run `make test`
1) Update `Changes` file
1) Create version bump/changes commit `git commit -m "Bump version to X.YY"`
1) Tag current release `git tag -a -m "Version X.YY" X.YY`
1) Push commits/tags `git push --atomic origin X.YY`
1) Run `make dist`
1) Upload `Parser-Fit-X.YY.tar.gz` to [PAUSE](https://pause.perl.org/)