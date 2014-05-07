# git-review

Bare-bones code review with GIT tags.

## Installation

Run this in your terminal:

```sh
(cd /usr/local/bin && curl -#SLOf https://raw.github.com/icetan/git-review/master/git-review && chmod +x git-review)
```

NOTE: To change the installation path change `/usr/local/bin` to any other
directory which is in your `$PATH`.

## Usage

Request a review with an optional comment.

```sh
git review [-a | -m <comment>] -i [<ref>]
```

Or specify a review id and omitting `-i`.

```sh
git review [-a | -m <comment>] <id> [<ref>]
```

List reviews and replies. `-n` will list annotations or if not available the
associated commit message.

```sh
git review [-n] [-l <id>]
```

Reply to a review.

```sh
git review -r [-a | -m <comment>] <id> [<ref>]
```

Close a review.

```sh
git review -c [-a | -m <comment>] <id> [<ref>]
```

## Example review request workflow

Create a topic branch and make some changes to your code:

```sh
git checkout -b topic-a
git commit -a -m "Some changes regarding Topic A."
```

Submit a review request for that branch:

```sh
git review -i
```

This will create a new `review-x` tag that is pushed to the remote repo, `x`
will be a unique review id.

Alternatively set a review name:

```sh
git review topic-a
```

## Example code review workflow

Check to see if any reviews are pending:

```sh
git review -n
```

Select a review of interest and show a diff between the tagged commit and the
`master` branch. Let's say you want to review number `36`.

The GIT tag name is the review number with `review-` in front of it.

```sh
git diff master...review-36
```

Reply with comments about the code:

```sh
git review -r -m"Needs moar pasta." 36
```

Wait for a reply or a new commit and repeat the last step until you are
satisfied with the fixes.

Now you can close the review to hide it from the pending list. An optional
comment can be submitted with `-m`.

```sh
git review -c 36
```
