
# GeneralLogTool

A Perl tool to parse and analyze **GoldenDB** general query logs on **DBProxy (CN)**.

## Usage

```bash
perl generallogtool.pl [OPTIONS] [LOGS...]
```
or
```bash
./generallogtool.pl [OPTIONS] [LOGS...]
```

## Options

| Option        | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `--help`      | Display help text and usage information.                                    |
| `-d`          | Enable debug mode for more verbose output.                                  |
| `-sqlonly`    | Print only the SQL statements from the log.                                 |
| `-t threadid` | Filter general logs by thread ID. Only consider entries that include this string.   |
| `-h hostip`   | Filter general logs by host IP. Only consider entries that include this string.     |
| `-p linkport` | Filter general logs by link port. Only consider entries that include this string.   |
| `-c dialogid` | Filter general logs by client dialog ID. Only consider entries that include this string. |
| `-u uuid`     | Filter general logs by UUID. Only consider entries that include this string.        |
| `-g PATTERN`  | Filter general logs by SQL pattern. Only consider SQL statements that include this string. |

## Example

```bash
perl generallogtool.pl -sqlonly -g "from t1" general_query.log
```

This command will print only the sql which contains pattern "from t1" from the provided general query log file.

## Features

- **Log Parsing**: Extract and filter specific SQL from GoldenDB general logs without worrying about SQL being truncated when using grep to filter.
- **Custom Filters**: Use various filtering options such as thread ID, host IP, link port, dialog ID, UUID, and SQL patterns.


