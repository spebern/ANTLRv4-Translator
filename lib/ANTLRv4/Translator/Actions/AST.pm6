use v6;

class ANTLRv4::Translator::Actions::AST {
    method TOP($/) {
        make {
            name  => ~$<name>,
            rules => $<rules>.made,
        }
    }

    method rules($/) {
        make $<ruleSpec>».made;
    }

    method ruleSpec($/) {
        make $<lexerRuleSpec>.made;
    }

    method lexerRuleSpec($/) {
        make {
            name    => ~$<name>,
            content => $<lexerRuleBlock>.made,
        }
    }

    method lexerRuleBlock($/) {
        if $<lexerAltList> {
            make {
                type     => 'alternation',
                contents => $<lexerAltList>.made,
            }
        }
    }

    method lexerAltList($/) {
        make $<lexerAlt>».made;
    }

    method lexerAlt($/) {
        make $<lexerElements>.made;
    }

    method lexerElements($/) {
        make {
            type     => 'concatenation',
            contents => $<lexerElement>».made,
        }
    }

    method lexerElement($/) {
        my Str $modifier = $<ebnfSuffix><STAR> ?? '*' !! $<ebnfSuffix><PLUS> ?? '+' !! '';
        my Bool $greedy  = $<ebnfSuffix><QUESTION> ?? True !! False;

        if $<lexerAtom> {
            make $<lexerAtom>.made;
        }
        elsif $<lexerBlock> {
            make $<lexerBlock>.made;
        }

        $/.made<modifier> = $modifier;
        $/.made<greedy>   = $greedy;
    }

    method lexerBlock($/) {
        make {
            type         => 'capturing group',
            contents     =>  $<lexerAltList>.made,
            complemented => $<NOT> ?? True !! False,
        }
    }

    method lexerAtom($/) {
        if $<notSet> {
            my $notSet = $<notSet>;
            if $notSet<setElement> {
                make $notSet<setElement>.made;
            }
            elsif $notSet<blockSet> {
                make $notSet<blockSet>.made;
            }
            $/.made<complemented> = True;
        }
        elsif $<LEXER_CHAR_SET> {
            make $<LEXER_CHAR_SET>.made;
        }
        elsif $<characterRange> {
            make $<characterRange>.made;
        }
        elsif $<terminal> {
            make $<terminal>.made;
        }
        else {
            make {
                type    => 'regular expression',
                content => $/.Str.trim,
            }
        }
    }

    method LEXER_CHAR_SET($/) {
        make {
            type     => 'character class',
            contents => $/[0]».<LEXER_CHAR_SET_RANGE>».made,
        }
    }

    method LEXER_CHAR_SET_RANGE($/) {
        make ~$/ eq ' ' ?? '\s' !! ~$/;
    }

    method characterRange($/) {
        make {
            type => 'range',
            from => $/<STRING_LITERAL>[0].Str.trim,
            to   => $/<STRING_LITERAL>[1].Str.trim,
        }
    }

    method setElement($/) {
        if $<LEXER_CHAR_SET> {
            make $<LEXER_CHAR_SET>.made;
        }
        else {
            my Str $content = $/.Str.trim;
            if $content eq q{'"'} {
                make {
                    type     => 'character class',
                    contents => [ '"' ],
                }
            }
            else {
                make {
                    type    => $<STRING_LITERAL> ?? 'terminal' !! 'nonterminal',
                    content => $content,
                }
            }
        }
    }

    method blockSet($/) {
        make {
            type     => 'capturing group',
            content  =>  $<setElement>.made,
        }
    }

    method terminal($/) {
        my Str $content = $/.Str.trim;
        given $content {
            # '""' is a escaped quote
            when q{'""'} { $content = q{'\"'}}
            when q{'\r'} { $content = '\r' }
            when q{'\n'} { $content = '\n' }
        }

        make {
            type    => $<STRING_LITERAL> ?? 'terminal' !! 'nonterminal',
            content => $content,
        }
    }
}
