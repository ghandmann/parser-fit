requires 'ExtUtils::MakeMaker' => '6.17';

on 'test' => sub {
    requires 'Test::Exception', '0.43';
};

on 'develop' => sub {
    requires 'Text::CSV', '2.01';
    requires 'Devel::Cover', '0.31';
    requires 'Devel::Cover::Report::Coveralls', '0.31';
};