# SPDX-FileCopyrightText: 2021 Shun Sakai
#
# SPDX-License-Identifier: CC0-1.0

# Run default recipe
_default:
    just -l

# Start a server
server:
    hugo server --bind 0.0.0.0 -D -p 8080

# Run the code formatter
fmt:
    npx prettier -w "**.{json,md,yaml,yml}"

# Run the linter
lint:
    uv run rumdl check .

# Run the linter for GitHub Actions workflow files
lint-github-actions:
    actionlint -verbose
