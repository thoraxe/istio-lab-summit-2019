if [ ! -z "$2" ]
  then
    export IDENTITY="-i $2"
fi

export LC_MYIP=`dig $1 +short`
ssh -o SendEnv=LC_MYIP $IDENTITY lab-user@$1
