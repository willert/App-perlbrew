#!/bin/bash

eval "$(perlbrew init-in-bash)"
# source $HOME/perl5/perlbrew/etc/bashrc

wanted_perl_installation="perl-5.8.8@perlbrew"

perlbrew use ${wanted_perl_installation}

if [ $? -eq 0 ]; then
   echo "--- Using ${wanted_perl_installation} for building."
else
   echo "!!! Fail to use ${wanted_perl_installation} for building. Please prepare it first."
fi

cd `dirname $0`

fatpack_path=`which fatpack`

if [ ! -f $fatpack_path ]; then
    echo "!!! fatpack is missing"
    exit 2
else
    echo "--- Found fatpack at $fatpack_path"
fi

rm -rf lib/App
mkdir -p lib/App

./update-fatlib.pl

if [[ -z "$PERLBREW_PERLSTRIP" ]]; then
    PERLBREW_PERLSTRIP=1
fi

if type perlstrip >/dev/null 2>&1; then
    if [[ $PERLBREW_PERLSTRIP -eq 1 ]]; then
        perlstrip -s -o lib/App/perlbrew.pm ../lib/App/perlbrew.pm
    else
        cp ../lib/App/perlbrew.pm lib/App/perlbrew.pm
        echo "... not perlstiripping"
    fi
else
    cp ../lib/App/perlbrew.pm lib/App/perlbrew.pm
    echo "--- perlstrip is not installed. The fatpacked executable will be really big."
fi

export PERL5LIB="lib":$PERL5LIB

cat - <<"EOF" > perlbrew
#!/usr/bin/perl

BEGIN { use Config; @INC = @Config{qw(privlibexp archlibexp sitelibexp sitearchexp)} };

EOF

(fatpack file; cat ../bin/perlbrew) >> perlbrew

chmod +x perlbrew
mv ./perlbrew ../

echo "+++ DONE: './perlbrew' is built."
exit 0;
