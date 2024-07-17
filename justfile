# SPDX-FileCopyrightText: 2021 Shun Sakai
#
# SPDX-License-Identifier: CC0-1.0

alias all := default

# Run default recipe
default: server

# Start a server
@server:
    hugo server --bind 0.0.0.0 -D -p 8080

# Run the code formatter
@fmt:
    npx prettier -w content

# Run the linter
@lint:
    npx markdownlint content

# Run the linter for GitHub Actions workflow files
@lint-github-actions:
    actionlint -verbose
