# housekeep

Housekeep is a small, interactive maintenance script for Linux that removes old files and unnecessary folders. It reports what it will
discard, and asks for go/no-go at each stage.

## What it does

- Purges files older than a set number of days in selected directories.
- Removes empty folders in those same paths.
- Deletes a short list of known throwaway directories.

## Running the script

```sh
chmod +x hk.sh
./hk.sh
```

## Credits

By Mike Margreve and licensed under MIT. The original source can be found here: https://github.com/margrevm/housekeep.git
