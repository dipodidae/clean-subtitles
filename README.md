
# Clean Subtitles

Remove advertisements and spam from `.srt` subtitle files automatically.

## Features

- Scans folders for `.srt` files and removes common advertisement lines.
- Supports batch cleaning or single-file cleaning.
- Customizable folder list and easy to extend with new ad patterns.
- Colorful, user-friendly terminal output.

## Quick Start

1. **Configure Folders**
	- Open `run.sh` in a text editor.
	- Edit the `FOLDERS` array to include the paths to your media folders:
	  ```bash
	  FOLDERS=(
			"/path/to/tv"
			"/path/to/movies"
	  )
	  ```

2. **Run the Cleaner**
	```bash
	./run.sh
	```
	- The script will scan all folders, clean subtitle files, and print a summary.

## Clean a Single Subtitle File

You can also clean a single `.srt` file directly:

```bash
python3 remove-advertisements-from-subtitle-file.py /path/to/subtitle.srt
```

## How It Works

- The Python script scans each subtitle block for known ad patterns and removes them.
- Block numbers are automatically renumbered.
- The Bash script (`run.sh`) automates scanning and cleaning for multiple folders.

## Requirements

- Python 3
- Bash (for batch mode)

## Customization

- To add or change ad patterns, edit the `advertisementPatterns` list in `remove-advertisements-from-subtitle-file.py`.

## License

MIT License. See [LICENSE](LICENSE) for details.
