use v6;

unit module ANTLRv4::Translator;
use ANTLRv4::Translator::Grammar;
use ANTLRv4::Translator::Actions::AST;

sub rule($rule --> Str) {
    my Str $translation = join ' ', term($rule<content>);
    return qq{rule $rule<name> { $translation }};
}

sub modify($term, $term-str is copy --> Str) {
    $term-str ~= $term<modifier> if $term<modifier>;
    $term-str ~= '?' if $term<greedy>;
    return $term-str;
}

sub alternation($term --> Str) {
    return join ' | ', map { term($_) }, $term<contents>.flat;
}

sub concatenation($term --> Str) {
    my Str $translation = '';

    # this most likely has some errors in it
    # the idea is to use "%%"
    # value ( ',' value )* should become ( <value>+ %% ',' )
    # this eases the use of the generated grammar
    my Int $i = 0;
    while $i < $term<contents>.elems {
        my $content = $term<contents>[$i];

        if $content<type> eq 'terminal' | 'nonterminal' {
            my Str $content-translation = term($content);

            my $next-content = ++$i < $term<contents>.elems ?? $term<contents>[$i] !! Nil;

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

sub terminal($term --> Str) {
    my Str $translation = $term<complemented> ?? '!' !! '';
    return $translation ~ modify($term, $term<content>);
};

sub nonterminal($term --> Str) {
    my Str $translation = '<';
    $translation ~= '!' if $term<complemented>;
    $translation ~= $term<content> ~ '>';
    return modify($term, $translation);
};

sub range($term --> Str) {
    my Str $translation = '';
    $translation ~= '!' if $term<complemented>;
    $translation ~= qq{$term<from>..$term<to>};
    return modify($term, $translation);
};

sub character-class($term --> Str) {
    my Str $translation = '<';
    $translation ~= '-' if $term<complemented>;
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
    }, $term<contents>.flat;

    $translation ~= ' ]>';

    return modify($term, $translation);
};

sub regular-expression($term --> Str) {
    my Str $translation = '';
    $translation ~= '!' if $term<complemented>;
    $translation ~= $term<content>;
    return modify($term, $translation);
};

sub capturing-group($term --> Str) {
    my Str $translation = '';
    $translation ~= '!' if $term<complemented>;

    my Str $group = term($term<content>);
    
    $translation ~= qq{( $group )};
    return modify($term, $translation);
}

sub term($term --> Str) {
    my Str $translation = '';

    given $term<type> {
        when 'alternation' {
            $translation = alternation($term);
        }
        when 'concatenation' {
            $translation = concatenation($term);
        }
        when 'terminal' {
            $translation = terminal($term);
        }
        when 'nonterminal' {
            $translation = nonterminal($term);
        }
        when 'range' {
            $translation = range($term);
        }
        when 'character class' {
            $translation = character-class($term);
        }
        when 'capturing group' {
            $translation = capturing-group($term);
        }
        when 'regular expression' {
            $translation = regular-expression($term);
        }
        default {
            if $term<type> {
                die "unkown type '$term<type>'";
            }
            else {
                die "missing type";
            }
        }
    }

    return $translation;
}

sub ast($ast --> Str) {
    my Str $rules = '';
    # $rules = join ' ', map { rule($_) }, $ast<rules>.flat;
    $rules = join "\n", map { rule($_) }, $ast<rules>.flat;

    my Str $grammar = qq{grammar $ast<name> { $rules }};

    return $grammar;
}

sub g4-to-perl6(Str $g4, --> Str) is export {
    my $ast = ANTLRv4::Translator::Grammar.new.parse(
       $g4, actions => ANTLRv4::Translator::Actions::AST 
    ).made;
    return ast($ast);
}
