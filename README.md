# git-review

Bare-bones code review with GIT tags.

## Example Workflow for Requesting a Review

Create a topic branch and make some changes to your code.

```sh
git checkout -b topic-a
git commit -a -m "Some changes regarding Topic A."
```

Request a review with an optional comment and review id.

```sh
git review [-a | -m <comment>] -n
```

Or

```sh
git review [-a | -m <comment>] <id> [<ref>]
```

List reviews and replies.

```sh
git review [-l <id>]
```

Reply to a review.

```sh
git review -r [-m <comment>] <id>
```

Close a review.

```sh
git review -c [-a | -m <comment>] <id>
```
