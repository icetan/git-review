# git-review

Bare-bones code review with GIT tags.

## Example Workflow for Requesting a Review

*Create a topic branch and make some changes to your code*

```sh
git checkout -b topic-a
git commit -a -m "Some changes regarding Topic A."
```

*Request a review with an optional comment*

```sh
git review -r [-a | -m <comment>]
```

*Check for replies*

```sh
git review [id]
```
