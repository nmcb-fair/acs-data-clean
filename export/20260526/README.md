# ACS Export 20260526

Generated on 2026-05-26 13:46:42 CEST by `process_acs.R`.

This folder contains cleaned NMCB ACS data for one export run. Each cleaned file is paired with the matching header template from `header/`.

## Completion Rule

For NMCB, a participant row is treated as **complete** when both of these columns are non-empty:

- `O_34_time_t`
- `O_34_type`

These columns belong to the mouse-type task near the end of the battery. If either value is missing, the row is counted as incomplete even though earlier tasks may contain data.

## Summary

- Exported participant rows: **259**
- Complete rows: **247**
- Incomplete rows: **12**
- Raw rows filtered out before export: **6**
- Token filter: **`nmcb`**
- Checkpoint deletions logged: **5**
- Generalized-rule mismatches logged: **0**

## Rows By Battery File

| File | Exported rows | Complete | Incomplete |
| --- | ---: | ---: | ---: |
| acs-nmcb-1.csv | 49 | 48 | 1 |
| acs-nmcb-2.csv | 45 | 43 | 2 |
| acs-nmcb-3.csv | 45 | 42 | 3 |
| acs-nmcb-4.csv | 39 | 36 | 3 |
| acs-nmcb-5.csv | 41 | 40 | 1 |
| acs-nmcb-6.csv | 40 | 38 | 2 |
| **Total** | **259** | **247** | **12** |

## Incomplete Tokens

- **acs-nmcb-1.csv**: nmcb00316ZsA9
- **acs-nmcb-2.csv**: nmcb0028hgtz2, nmcb0034OfSpu
- **acs-nmcb-3.csv**: nmcb0002zaFBW, nmcb0042M4hk3, nmcb02588iGwP
- **acs-nmcb-4.csv**: nmcb0016T7H8R, nmcb0251UfSb5, nmcb0276Us1zw
- **acs-nmcb-5.csv**: nmcb02558ALiR
- **acs-nmcb-6.csv**: nmcb00569j3Kz, nmcb0256ioTVv

## How The Raw Data Was Cleaned

1. Raw ACS CSV files from `raw/` were read without headers.
2. Only rows whose token starts with the configured prefix were kept. For NMCB, test rows such as `marysetest` are excluded by default.
3. Each raw file was matched to its numbered header template, for example `raw/acs-nmcb-2.csv` with `header/nmcb-acs-header-2.csv`.
4. Packed questionnaire values such as `1|Question text|0` were split into separate columns.
5. Values were aligned to the template using checkpoint markers such as `message`, `video`, `digitspan`, `corsi`, and `mousetype`.
6. When extra or shifted tokens were found, the script searched ahead for the expected checkpoint and logged deleted tokens.
7. Cleaned CSV files and log files were written to this dated export folder.

For full project documentation, see the repository README at the project root.

## Files In This Folder

- `acs-nmcb-1.csv` through `acs-nmcb-6.csv`: cleaned data with headers.
- `deleted_cells_log.csv`: tokens removed during checkpoint correction.
- `generalized_rule_misalignment_log.csv`: remaining value mismatches against generalized checkpoint rules. Missing later tasks are usually not listed because they often mean the participant stopped early.

## Notes

- Each battery file is exported separately. A participant appears in only one of the six files.
- Do not treat incomplete rows as finished sessions.
- Do not share raw tokens or participant answers outside approved secure workflows.

