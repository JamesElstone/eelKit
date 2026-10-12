# Legacy Unicode compatibility data

`uca4-primary.json` contains the nonzero primary weights for individual BMP
characters from Unicode's `allkeys-4.0.0.txt`, keyed by decimal code point.
Source: https://www.unicode.org/Public/UCA/4.0.0/allkeys-4.0.0.txt
The Unicode license is included in `LICENSE.txt`.

eelKit's MySQL/MariaDB schema uses `utf8mb4_unicode_ci`, which predates modern
ICU collations. Using current ICU sorting directly would change identity
uniqueness and ordering. The compatibility implementation uses fixed Unicode 4
weights, the servers' implicit-weight rules, their eight-element expansion
limit (U+FDFA is implicit), supplementary weight `FFFD`, and PAD SPACE equality.
It deliberately does not normalize text before weighting: that would change
the older servers' treatment of combining sequences.

LIKE compares individual characters with the same weights and supports `%`,
`_`, and escape characters. Unlike equality, it does not expand one input
character into multiple pattern characters and does not ignore trailing spaces.
Token/hash columns retain binary comparisons.

`tools/php/testDatabaseBackends.php` verifies every BMP scalar's weights against
the real server and checks supplementary characters, comparisons, and wildcard
searches. Run that gate before changing this data or compatibility code.
