#!/bin/bash
# test suite entry point for nesono automatic tests.

# the recipients for the report(s)
RECIPIENTS="server-admin"

# source the modules configuration file
. ~/.autotestmodules
# source the platform configuration file
. ~/.autotestplatform

# set environment variable to avoid false positives in valgrind
export GLIBCXX_FORCE_NEW=1

# get number of modules and the index of the last module
NUMMODS=${#CHECKOUTCMD[*]}

# prepare temp directory
rm -rf   $TMPSRCDIR
mkdir -p $TMPSRCDIR
cd       $TMPSRCDIR

# inner loop to test one demo application
function test_demo_app()
{
  # assign parameter 1 to be our application under test
  demoapp=$1
  outdir=$2

  # tell user, what we are doing
  echo "testing $demoapp"

  # make target dir
  TARGETDIR=$OUTROOT/$outdir
  mkdir -p $TARGETDIR

  # specify the output file
  OUTPUTFILE=$TARGETDIR/${demoapp}_${TIMESTAMP}.txt

  # check if outputfile can be written
  if [ $? != 0 ]; then
    echo "could not open $OUTPUTFILE for writing" | tee -a $TMPMAILFILE
    return
  fi

  if [ -x $BINDIR/$demoapp ]; then
#    if [ -n "$KILLER_TIMER" ]; then
#      # start the killing timer
#      $KILLER_TIMER 600 600 $demoapp &
#    fi

    # invoke the demoapp - assuming there is only one directory below ../bin
    $BINDIR/$demoapp > $OUTPUTFILE 2>&1

    # check return value
    if [ $? == 0 ]; then
      BINHEADER="$demoapp succeeded "
    else
      BINHEADER="$demoapp failed "
    fi

    if [ -n "$PROFPREFIX" -a -n "$PROFREPORT" ]; then
#      if [ -n "$KILLER_TIMER" ]; then
#        # start the killing timer
#        $KILLER_TIMER 600 600 $demoapp    &
#      fi

      # append samples line to bin header
      BINHEADER="$BINHEADER samples: "

      # run oprofile on demoapp
      $PROFPREFIX $BINDIR/$demoapp

      # append oprofile report to debug file
      echo -e "\n\nPROFILER OUTPUT\n" | tee -a $OUTPUTFILE
      $PROFREPORT $BINDIR/$demoapp | tee -a $OUTPUTFILE 2>&1

      # get total number of samples
      TOTALSAMPLES=`$GETTOTALSAMPLESCMD $OUTPUTFILE`
    else
      BINHEADER="$BINHEADER :: no profiler available! "
    fi

    if [ -n "$MEMCHECKER" ]; then
#      if [ -n "$KILLER_TIMER" ]; then
#        # start the killing timer
#        $KILLER_TIMER 600 600 $demoapp    &
#      fi
      # run demoapp in valgrind
      echo -e "\n\nMEMCHECKER OUTPUT\n" | tee -a $OUTPUTFILE
      $MEMCHECKER $BINDIR/$demoapp 2>&1 | tee -a $OUTPUTFILE

      # default is leak free
      LEAKING=" leak free :-)"
      # check for LEAK SUMMARY - only occuring in case of possibly or definately lost memory
      HASLEAKSECTION=`$LEAKSECTION $OUTPUTFILE`
      if [ -n "$HASLEAKSECTION" ]; then
        DEFINATELYLOST=`$DEFLOST $OUTPUTFILE`
        if [ "x$DEFINATELYLOST" != "x0" ]; then
          LEAKING=" *HAS LEAK* :-( :-( :-("
        else
          POSSIBLYLOST=`$POSSLOST $OUTPUTFILE`
          if [ "x$POSSIBLYLOST" != "x0" ]; then
            LEAKING=" possible LEAK :-( :-("
          fi
        fi
      fi
    else
      LEAKING=":: no memchecker available :-|"
    fi

    # write the header line to mail file
    echo "$BINHEADER $TOTALSAMPLES $LEAKING" | tee -a $TMPMAILFILE

    # add link to debug output to mailer
    echo "$URLPREFIX/$SYSTEMNAME/${outdir}/${demoapp}_${TIMESTAMP}.txt" | tee -a $TMPMAILFILE
  else
    echo "$demoapp *NOT COMPILED* :-( :-( :-(" | tee -a $TMPMAILFILE
  fi

  echo "" | tee -a $TMPMAILFILE
}

# outer loop to test one module specified in ~/.autotestmodules $1 is the current iterator
function test_module()
{
  # get current parameter
  index=$1

  # write mail header
  echo -e "Testing results for ${MODULEDIR[index]}:\n" > $TMPMAILFILE

  # add link to main module directory to mailer
  echo -e "find additional information (build-output/checkout-output) here:" | tee -a $TMPMAILFILE
  echo -e "$URLPREFIX/$SYSTEMNAME/${MODULEDIR[index]}\n\n"                     | tee -a $TMPMAILFILE

  # checkout module
  ${CHECKOUTCMD[index]} ${MODULEDIR[index]} 2>&1 | tee $OUTROOT/${MODULEDIR[index]}/aaa_checkout.out

  # change into modules make directory
  cd ${MODULEDIR[index]}/$BUILDDIR

  # make all targets
  $MAKECMD 2>&1 | tee $OUTROOT/${MODULEDIR[index]}/aaa_build.out

  # go through all demo programs
  for file in $DEMOSRCDIR/*.c*; do
    # extract binary name from filename
    tmp_str=${file##$DEMOSRCDIR/}
    binary=${tmp_str%%.c*}

    test_demo_app $binary ${MODULEDIR[index]}
  done
}

# the main routine - go through all modules and test them
iter=0
while [ $iter -lt $NUMMODS ]; do
  # tell user what we are doing
  echo "module: ${MODULEDIR[iter]}"

  # remember current directory
  pushd .

  # call the test method
  test_module $iter;

  # send module's mail from temporary mail file
  cat $TMPMAILFILE | $MAILCMD "$SYSTEMNAME ${MODULEDIR[iter]} test" $RECIPIENTS

  # get back into base dir
  popd

  # decrement iter
  iter=$((iter+1))
done
