use v6;

class ANTLRv4::Translator::Actions::AST {
    method TOP($/) {
        make {
            name  => ~$<name>,
            rules => $<ruleSpec>».made,
        }
    }

    method ruleSpec($/) {
        make $<parserRuleSpec>.made || $<lexerRuleSpec>.made;
    }

    method lexerRuleSpec($/) {
        make {
            name    => ~$<name>,
            content => $<lexerAltList>.made,
        }
    }

    method parserRuleSpec($/) {
        make {
            name    => ~$<name>,
            content => $<parserAltList>.made,
        }
    }

    method lexerAltList($/) {
        make {
            type     => 'alternation',
            contents => $<lexerAlt>».made.flat;
        }
    }

    method parserAltList($/) {
        make {
            type     => 'alternation',
            contents => $<parserAlt>».made,
        }
    }

    method lexerAlt($/) {
        make $<lexerElement>».made;
    }

    method parserAlt($/) {
        make $<parserElement>.made;
    }

    method blockAltList($/) {
        make {
            type     => 'alternation',
            contents => $<parserElement>».made,
        }
    }

    method parserElement($/) {
        make {
            type     => 'concatenation',
            contents => $<element>».made,
        }
    }

    method element($/) {
        my Str $modifier = $<ebnfSuffix><MODIFIER>        ?? ~$<ebnfSuffix><MODIFIER>
                        !! $<ebnf><ebnfSuffix><MODIFIER>  ?? ~$<ebnf><ebnfSuffix><MODIFIER> !! '';
        my Bool $greedy  = $<ebnfSuffix><GREED>       ?? True
                        !! $<ebnf><ebnfSuffix><GREED> ?? True !! False;

        if $<atom> {
            make $<atom>.made;
        }
        elsif $<ebnf><block> {
            make $<ebnf><block>.made;
        }

        $/.made<modifier> = $modifier;
        $/.made<greedy>   = $greedy;
    }

    method atom($/) {
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

    method lexerElement($/) {
        my Str $modifier = $<ebnfSuffix><MODIFIER> ?? ~$<ebnfSuffix><MODIFIER> !! ''; 
        my Bool $greedy  = $<ebnfSuffix><GREED> ?? True !! False;

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
            content      =>  $<lexerAltList>.made,
            complemented => $<NOT> ?? True !! False,
        }
    }

    method block($/) {
        make {
            type         => 'capturing group',
            content      =>  $<blockAltList>.made,
            complemented => $<NOT> ?? True !! False,
        }
    }

    method lexerAtom($/) {
        if $<LEXER_CHAR_SET> {
            make $<LEXER_CHAR_SET>.made;
        }
        elsif $<terminal> {
            make $<terminal>.made;
        }
        elsif $<range> {
            make $<range>.made;
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

    method range($/) {
        make {
            type => 'range',
            from => ~$/<from>,
            to   => ~$/<to>,
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
                    type    => $<terminal><STRING_LITERAL> ?? 'terminal' !! 'nonterminal',
                    content => $content,
                }
            }
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
