
# deploy-render

I find myself using Render.com for lightweight POC development projects. I develop and test these locally, pushing to github along the way. I don't want to auto-commit every change to production in Render.com, and I don't want to complicate things across multiple small projects with a branching strategy, CD, etc.

So, here we are.

I built this small script because I got tired of staring at the Render dashboard waiting for a deploy to finish.

`deploy-render` starts a deploy using the Render API, waits for the deployment to complete, shows a simple progress spinner in the terminal, and plays a sound when it finishes. The goal is simple: start the deploy, go do something else, and let your computer tell you when it's done.

## Features

- Triggers a Render deploy from the command line
- Uses an Environment Variable for the Render.com Service ID, so it's easily overwritten when working on multiple projects.
- Shows a live spinner and deployment status
- Uses a single clean status line instead of log spam
- Plays a sound when the deploy finishes
- Works from anywhere in the terminal

## Requirements

- macOS (uses `afplay` for sound)
- `curl`
- `jq`
- A Render API key
- Your Render service ID

Install `jq` if you don't already have it:

```
brew install jq
```

## Setup

Add your Render credentials to your `.zshrc`:

```
export RENDER_API_KEY="your_render_api_key"
export RENDER_SERVICE_ID="your_service_id"
```

Reload your shell:

```
source ~/.zshrc
```

Make the script executable:

```
chmod +x deploy-render.sh
```

Optional: create an alias so you can run it from anywhere:

```
alias deploy-render="$HOME/deploy-render.sh"
```

## Usage

Start a deploy:

```
deploy-render
```

The script will:

1. Trigger a deployment
2. Show a live progress indicator
3. Wait until the deploy completes
4. Play a sound when finished

## Why I made this

Waiting for deployments is one of those small annoyances that adds up during development. I wanted something simple that would let me, or an Agent trigger a deploy and walk away from the terminal without constantly checking Render.

This script solves that problem with about 50 lines of shell and a little bit of terminal polish.
