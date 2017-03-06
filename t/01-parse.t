use v6;
use Test;
use ANTLRv4::Translator::Grammar;

plan 57;

for dir 't/g4-grammars' -> $grammar-file {
    ok $parser.parsefile($grammar-file), $grammar-file.Str ~ "size: " ~ $grammar-file.slurp.chars;
}
