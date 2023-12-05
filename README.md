# JPDB Stats

[![Update JPDB Stats](https://github.com/jhunschejones/jpdb_stats/actions/workflows/update_jpdb_stats.yml/badge.svg)](https://github.com/jhunschejones/jpdb_stats/actions/workflows/update_jpdb_stats.yml)

### Overview
This project holds a small collection of scripts that parse out my jpdb.io reviews data and help calculate my daily study minutes and a list of leech cards.

Special thanks to `@bijak` for his help consulting on the logic for estimating the number of minutes spent reviewing per day 🫶🏻✨

### Usage
The `./bin/run` script coordinates all the moving parts of this tool, downloading the `reviews.json` from jpdb.io, counting leech cards, transforming the review data into a list total study minutes per day, then logging the script session out of jpdb.io.

NOTE: The script will attempt to use the 1Password CLI to safely gather credentials for the web request to jpdb.io made in `./bin/download-jpdb-reviews`. You may also chose to set the environment values for `JPDB_USERNAME` and `JPDB_PASSWORD` if you don't have 1Password or don't want to mess with configuring it's CLI, and the script will read those instead.

The `data/` directory in this repo is currently relied on by these projects:
- https://github.com/jhunschejones/Immersion-Stats
- https://github.com/jhunschejones/Chrome-According-To-Josh/tree/main/jpdb-leeches

To trigger the GitHub action which runs this script, run `gh workflow run update_jpdb_stats.yml` from the root of this directory.

### Testing
`./bin/test` will run some unit tests and a simple integration test of the script, overwriting the local `./data/` files with new values if there are differences in the script output. Depending on what you are changing, this can help verify whether your changes are working as intended when ran against your real-world reviews data 👍🏻
