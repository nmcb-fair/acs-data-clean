# ACS Data Clean Pipeline

This project prepares ACS raw CSV files by assigning the official ACS header, correcting shifted rows with checkpoint rules, and exporting cleaned files for downstream processing.

## What This Pipeline Does

The script `acs_add_header_export.Rmd` performs the following steps:

1. Reads header definitions from `header/ACS_header.csv`
2. Reads all raw files from `raw/`
3. Expands pipe-packed triplets like `1|Question text|0` into separate fields
4. Aligns each row to ACS headers
5. Uses checkpoint correction to fix row shifts (deletes misaligned tokens until expected checkpoint values are found)
6. Writes cleaned files to `export/`
7. Writes deleted-token audit log to `export/deleted_cells_log.csv`

## Folder Structure

- `raw/` - input ACS CSV files without headers
- `header/ACS_header.csv` - target header row
- `acs_add_header_export.Rmd` - main processing pipeline
- `export/` - cleaned output files and deletion log

## How To Run

From the project root:

```bash
Rscript -e "rmarkdown::render('acs_add_header_export.Rmd', quiet = TRUE)"
```

## Output Files

- `export/acs-nmcb-*.csv` - cleaned, header-aligned files
- `export/deleted_cells_log.csv` - every checkpoint-driven deletion
  - `file`: source file name
  - `row`: row index in source file
  - `header`: checkpoint header being enforced
  - `expected_value`: required value for that checkpoint
  - `deleted_count`: number of tokens removed
  - `deleted_content`: removed token content joined by ` || `

## Checkpoint Logic

When a checkpoint exists for a header:

- If current token matches expected value: keep it
- If not: scan forward until expected value is found
- Delete all intervening tokens, log them, then continue
- If expected value is not found in the remaining row: leave field empty and log the failed checkpoint

## Generalized Rules

These are applied when no explicit header-specific checkpoint is defined:

- `*_mouse` -> `mouse`
- `*_wordlist` -> `wordslist`
- `*video_element*` -> `video`
- `*_HANDEDNESS` -> `handedness`
- `*_MOUSETYPE` -> `mousetype`
- `*typetest_element*` -> `typetest`
- `*clickskills_element*` -> `clickskills`
- `*dragskills_element*` -> `dragskills`
- `*digitspan_element*` -> `digitspan`
- `*_DIGITS_FW_DEMO` -> `forward-demo`
- `*_DIGITS_FW` -> `forward`
- `*_DIGITS_BW_DEMO` -> `reverse-demo`
- `*_DIGITS_BW` -> `reverse`
- `*_questionnaire<nr>` -> `questionnaire`
- `*_questionnaire_ntli<nr>` -> `questionnaire-ntli`

## Explicit Checkpoints

In addition to generalized rules, explicit checkpoint mappings are defined in `checkpoint_map` in `acs_add_header_export.Rmd`.

Priority order:

1. Explicit checkpoint map
2. Generalized rules

So explicit rules always override generalized pattern rules.

## Notes

- The first column header may include a BOM marker (`O_testbattery`), which is expected for some UTF-8 CSV workflows.
- If you add new tasks later (type conversion, recoding, QA checks), append them in the placeholder chunk at the bottom of `acs_add_header_export.Rmd`.
