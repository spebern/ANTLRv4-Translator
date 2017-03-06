use v6;
use Test;
use ANTLRv4::Translator::Grammar;

plan 57;

my $parser = ANTLRv4::Translator::Grammar.new;

for dir 't/g4-grammars' -> $grammar-file {
    ok $parser.parsefile($grammar-file), $grammar-file.Str;
}
