use v6;

unit module ANTLRv4::Translator;
use JSON::Tiny;
use ANTLRv4::Translator::Grammar;
use ANTLRv4::Translator::Actions::AST;

sub rule($ast --> Str) {
    my Str $rule = '';

    my Str $translation = join ' ', term($ast<content>);
    $rule = qq{rule $ast<name> { $translation }};

    $rule ~= json-info($ast, <attribute action returns throws locals options>);

    return $rule;
}

sub modify($ast, $term is copy --> Str) {
    $term ~= $ast<modifier> if $ast<modifier>;
    $term ~= '?' if $ast<greedy>;
    return $term;
}

sub alternation($ast --> Str) {
    return join ' | ', map { term($_) }, $ast<contents>.flat;
}

sub concatenation($ast --> Str) {
    my Str $translation = '';

    # this most likely has some errors in it
    # the idea is to use "%%"
    # value ( ',' value )* should become ( <value>+ %% ',' )
    # this eases the use of the generated grammar
    my Int $i = 0;
    while $i < $ast<contents>.elems {
        my $content = $ast<contents>[$i];

        if $content<type> eq 'terminal' | 'nonterminal' {
            my Str $content-translation = term($content);

            my $next-content = ++$i < $ast<contents>.elems ?? $ast<contents>[$i] !! Nil;

            if $next-content && $next-content<type> eq 'capturing group' {
                if $next-content<content><type> eq 'alternation' {
                    my $alternation = $next-content<content>;

                    if $alternation<contents>.elems == 1
                      && $alternation<contents>[0]<type> eq 'concatenation' {
                        my $concatination          = $alternation<contents>[0];
                        my $last-concatinated-term = $concatination<contents>[ * - 1];

                        if term($last-concatinated-term) eq $content-translation {
                            my Str $deliminator = join ' ', map {
                                term($_)
                            }, $concatination<contents>.flat[ 0 .. * -2];
                            $translation ~= qq{ ( $content-translation+ %% $deliminator )};
                            ++$i;
                            next;
                        }
                    }
                }
            }
            $translation ~= ' ' ~ $content-translation;
        }
        else {
            $translation ~= ' ' ~ term($content);
            ++$i;
        }
    }
    # $translation ~= join ' ', map { term($_) }, $term<contents>.flat;
    return $translation.trim;
};

sub terminal($ast --> Str) {
    my Str $translation = $ast<complemented> ?? '!' !! '';
    return $translation ~ modify($ast, $ast<content>) ~ json-info($ast, <options label commands>);
};

sub nonterminal($ast --> Str) {
    my Str $translation = '<';
    $translation ~= '!' if $ast<complemented>;
    $translation ~= $ast<content> ~ '>';
    return modify($ast, $translation);
};

sub range($ast --> Str) {
    my Str $translation = '';
    $translation ~= '!' if $ast<complemented>;
    $translation ~= qq{$ast<from>..$ast<to>};
    return modify($ast, $translation);
};

sub character-class($ast --> Str) {
    my Str $translation = '<';
    $translation ~= '-' if $ast<complemented>;
    $translation ~= '[ ';

    $translation ~= join ' ', map {
        if /^(.) '-' (.)/ {
            qq{$0 .. $1};
        }
        elsif /^\\u(....) '-' \\u(....)/ {
            qq{\\x[$0] .. \\x[$1]};
        }
        elsif /^\\u(....)/ {
            qq{\\x[$0]};
        }
        elsif /' '/ {
            q{' '};
        }
        elsif /\\\-/ {
            q{-};
        }
        else {
            $_;
        }
    }, $ast<contents>.flat;

    $translation ~= ' ]>';

    return modify($ast, $translation);
};

sub regular-expression($ast --> Str) {
    my Str $translation = '';
    $translation ~= '!' if $ast<complemented>;
    $translation ~= $ast<content>;
    return modify($ast, $translation);
};

sub capturing-group($ast --> Str) {
    my Str $translation = '';
    $translation ~= '!' if $ast<complemented>;

    my Str $group = term($ast<content>);
    
    $translation ~= qq{( $group )};
    return modify($ast, $translation);
}

sub action($ast --> Str) {
    return json-info($ast, (<content>, ));
}

sub term($ast --> Str) {
    my Str $translation = '';

    given $ast<type> {
        when 'alternation' {
            $translation = alternation($ast);
        }
        when 'concatenation' {
            $translation = concatenation($ast);
        }
        when 'terminal' {
            $translation = terminal($ast);
        }
        when 'nonterminal' {
            $translation = nonterminal($ast);
        }
        when 'range' {
            $translation = range($ast);
        }
        when 'character class' {
            $translation = character-class($ast);
        }
        when 'capturing group' {
            $translation = capturing-group($ast);
        }
        when 'regular expression' {
            $translation = regular-expression($ast);
        }
        when 'action' {
            $translation = action($ast);
        }
        default {
            if $ast<type> {
                die "unkown type '$ast<type>'";
            }
            else {
                die "missing type";
            }
        }
    }

    return $translation;
}

sub json-info($ast, @keys --> Str) {
    my %json = |@keys.grep({ $ast{$_} }).map({$_ => $ast{$_}});
    return %json.elems ?? ' #=' ~ to-json(%json) !! '';
}

sub ast($ast --> Str) {
    my Str $rules = '';
    # $rules = join ' ', map { rule($_) }, $ast<rules>.flat;
    $rules = join "\n", map { rule($_) }, $ast<rules>.flat;

    my Str $grammar = qq{grammar $ast<name> { $rules }};
    $grammar ~= json-info($ast, <type options imports tokens actions>);
    return $grammar;
}

sub g4-to-perl6(Str $g4, --> Str) is export {
    my $ast = ANTLRv4::Translator::Grammar.new.parse(
       $g4, actions => ANTLRv4::Translator::Actions::AST 
    ).made;
    return ast($ast);
}
