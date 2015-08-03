# Changelog

## 1.1.0

- Added --format option which accepts either a 'text' or 'json' argument. Text format, the default, prints the same as before. The json format pretty-prints a list of objects whith keys source, raw, line and column. Thanks to Danny Kirchmeier for this patch!

## 1.0.3

- Improved support for non-interactive use. The "Paste your minified trace here:" message is only printed if stdin is a terminal. The escape codes to colorize output are only printed if stdout is a terminal. Thanks to Matt Liberty for this patch!

## 1.0.2

- Bug fix; when program exited with an error code it was rerun by pub global activate wrapper script.

## 1.0.1

- Bug fix; pub global activate did not create the binary.

## 1.0.0

- Initial version.
