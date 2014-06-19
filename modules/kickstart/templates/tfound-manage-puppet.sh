#!/bin/bash
LOG=/var/log/tfound-manage-puppet.log
RUNPUPPET=0
# adding zenoss as default
ZENOSS=1
NAGIOS=1
PUPPETOPTS="-t --pluginsync"
AUTOMATE=0
DC="ec2"
FACTS=/etc/facter/facts.d
MODULES=( buildserver kickstart zenoss nagios mysql red5 openstack )
RED='\e[0;31m'
ENDCOLOR="\e[0m";
SELECTIONINFO=()
SELECTIONLST=()

[ -e ${FACTS}/datacenter.txt ] && DC=$(cat ${FACTS}/datacenter.txt | cut -d= -f2)
[ -e ${FACTS}/environment.txt ] && ENVIRON=$(cat ${FACTS}/environment.txt | cut -d= -f2)

# build array for dialog
num=0
for mod in ${MODULES[@]} ; do

    SELECTIONLST+=( "${num}|${mod}" )
    num=$(( num + 1 ))

    if [ -e ${FACTS}/nodeless_${mod}.txt ] ; then 
        MODULE=${mod}
        COMPONENT=$( cat ${FACTS}/nodeless_${mod}.txt | cut -d= -f2)
    fi
done

for f in "${SELECTIONLST[@]}" ; do
    SELECTIONINFO+=( "${f%|*}" "${f#*|}" ); 
done
SELECTIONINFO+=( "99" "Exit" )


msg()
{
    echo -e "${RED}**${ENDCOLOR} $*"
}
if [ -z "$PUPPETMASTER" ] ; then
    PUPPETMASTER="<%= @puppetmasterip %>"
    PUPPETMASTERNAME="<%= @puppetmaster %>"
fi


function help()
{
    echo "Usage:"
    echo "$0 -v (verbose) -h (help) -a (automation) -d datacenter -e environment -m module -c 'module,components,here' -p (run puppet)"
    echo
    exit 1
}

while getopts "ae:m:c:pd:hvz" OPTION
do
    case "$OPTION" in
    # debug
    a) export AUTOMATE=1
    ;;
    e) export ENVIRON=$OPTARG
    ;;
    m) export MODULE=$OPTARG
    ;;
    c) export COMPONENT=$OPTARG
    ;;
    p) export RUNPUPPET=1
    ;;
    d) export DC=$OPTARG
    ;;
    v) set -x ; PUPPETOPTS="-tvd --pluginsync" 
    ;;
    h) help
    ;;
    z) export ZENOSS=1
    ;;
    n) export NAGIOS=1
    ;;
    *) help
    ;;
    esac
done

function do_install
{
    if [ $AUTOMATE -ne 1 ] ; then	
	    echo
	    echo
	    echo "This will install and run TFOUND aws puppet. Hit Ctrl-C to end"
	    echo
	    read -p "Press Enter to continue"
	    echo
    fi
    mkdir -p /etc/facter/facts.d
	if ! $(which dialog > /dev/null 2>&1) ; then
	    echo "Installing dialog ..."
	    yum -y install dialog > /dev/null 2>&1
	fi
	if ! $(which puppet > /dev/null 2>&1) ; then
	    echo "Installing puppet ..."
	    rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-5.noarch.rpm
	    yum -y install puppet-2.7.19-1.el6.noarch > /dev/null 2>&1
	    echo "$PUPPETMASTER   $PUPPETMASTERNAME  puppet" >> /etc/hosts
	fi
}
function do_subclass()
{
    MODULE=$1
    COMPONENT=$(dialog --stdout --backtitle "Manage puppet for $MODULE" --title "To include a puppet subclass for $MODULE , ie ${MODULE}::web, enter below" \
--inputbox "To include more than one puppet subclass for $MODULE , type in comma delimited. Example: web,ftp,cron" 8 50 )
    if [ ! -z "$COMPONENT" ] ; then
        echo "nodeless_${MODULE}=${COMPONENT}" >  /etc/facter/facts.d/nodeless_${MODULE}.txt
        export COMPONENT
    fi
}
function do_environment()
{
    environ=$(dialog --stdout --backtitle "Manage puppet | Environment: ${ENVIRON}" --menu "Choose Environment:" 15 40 5 \
1 Development  \
2 QA  \
3 Staging  \
4 Production )
	case $environ in
		1) export ENVIRON="development"
		;;
		2) export ENVIRON="qa"
		;;
		3) export ENVIRON="stage"
		;;
		4) export ENVIRON="production"
		;;
	esac
    export FACTER_environment="${ENVIRON}"
	echo -e "environment=${ENVIRON}" > /etc/facter/facts.d/environment.txt

}
function do_puppet()
{
    clear
    echo
    [ -e /usr/bin/fortune ] && fortune
    echo
    echo
    echo
    msg Running puppet agent ${PUPPETOPTS} in 5 secs.  Ctrl-C to abort.
    echo -n "5 "
    sleep 1
    for i in 4 3 2 1 ; do
        echo -n "$i "
        sleep 1
    done
    echo
    rm -f /var/lib/puppet/lib/puppet/provider/zenoss_host/zenoss.rb
    puppet agent ${PUPPETOPTS}
}

function do_hostname()
{
    if [ -e /opt/aws/bin/ec2-metadata ] ; then
        IPDATA=$(/opt/aws/bin/ec2-metadata -o)
        IP=${IPDATA##local-ipv4: }
        DC="ec2"
    else
        IP=$(ifconfig eth0 |grep "inet addr"| awk '{print $2}' | cut -d: -f2)
    fi
    FIRST=$(echo $COMPONENT | tr ',' '-')
    SECOND=$(echo $IP | tr '.' '-')
	case $ENVIRON in
		'development') THIRD="dev"
		;;
		'qa') export THIRD="qa"
		;;
		'stage') THIRD="stage"
		;;
		'production') THIRD="prod"
		;;
	esac
    FOURTH=$MODULE
    LAST="${DC}.tfound.org"
    hostname ${FIRST}-${SECOND}.${THIRD}.${FOURTH}.${LAST}
}
function do_datacenter()
{
    datacenter=$(dialog --stdout --backtitle "Manage Platform | Datacenter: $DC | Environment: ${ENVIRON}" --menu "Choose Datacenter:" 15 40 5 \
1 EC2  \
2 VA  \
3 SG  \
4 ATL )
	case $datacenter in
		1) export DC="ec2"
		;;
		2) export DC="va"
		;;
		3) export DC="sg"
		;;
		4) export DC="atl"
		;;
	esac
    export FACTER_datacenter="${DC}"
	echo -e "datacenter=${DC}" > /etc/facter/facts.d/datacenter.txt
    echo -e "nodeless_dns=client" > /etc/facter/facts.d/nodeless_dns.txt
}
function manage_box()
{
    PICKMODULE=$(dialog --stdout --backtitle "Manage Platform | Datacenter: $DC | Environment: ${ENVIRON} | Customer: $MODULE | Components: $COMPONENT" --menu "What do you want to configure? Press Enter to continue." 20 40 15 \
1 Environment \
2 Datacenter \
5 "Infrastructure" \
6 "Run Puppet" \
7 "Fix Hostname" \
8 Exit)
    [ -z "$PICKMODULE" ] && return
    case $PICKMODULE in
             1) do_environment ; return
             ;;
             2) do_datacenter ; return
             ;;
             3) export MODULE='appstudio' ;
             ;;
             4) export MODULE='tfoundcloud' ;
             ;;
             5) export MODULE="infra"
             ;;
             6) do_puppet ; return
             ;;
             7) echo ; echo ; echo "Current hostname is $(hostname) . You can change it back if you wish."
             read -p "Press the ENTER key to update it."
             do_hostname ; echo ; echo ; 
             echo "Hostname is now $(hostname) based upon your options." ;
             read -p "Press the ENTER key to continue." ; 
             return
             ;;
             8) exit 0
             ;;
    esac
    if [ "$MODULE" == "infra" ]
    then
            pupmod=$(dialog --stdout --backtitle "Manage Platform | Environment: ${ENVIRON}" --menu  "What puppet module do you want to add? (no sub modules yet)" 20 80 10 "${SELECTIONINFO[@]}" )
            if [ $? -ne 0 ] ; then
                echo 
                return
            fi
		
            case $pupmod in
                99) return
                ;;
                *) echo -e "nodeless_${MODULES[$pupmod]}=true" > /etc/facter/facts.d/nodeless_${MODULES[$pupmod]}.txt ;
			do_subclass ${MODULES[$pupmod]}
                ;;
           esac
  else 
      echo -e "nodeless_${MODULE}=true" >  /etc/facter/facts.d/nodeless_${MODULE}.txt
      do_subclass $MODULE
  fi
}
function main()
{
	if [ $AUTOMATE -eq 1 ] ; then
 
	    msg Running automation ... | tee $LOG
	    do_install | tee $LOG
	    export FACTER_environment="${ENVIRON}"
	    echo -e "environment=${ENVIRON}" > /etc/facter/facts.d/environment.txt
        echo -e "nodeless_dns=client" > /etc/facter/facts.d/nodeless_dns.txt
	    [ ! -z "$MODULE" ] && echo -e "nodeless_${MODULE}=true" >  /etc/facter/facts.d/nodeless_${MODULE}.txt
	    [ ! -z "$COMPONENT" ] && echo -e "nodeless_${MODULE}=${COMPONENT}" >  /etc/facter/facts.d/nodeless_${MODULE}.txt
        [ ! -z "$ZENOSS" ] && echo -e "nodeless_zenoss=client" >  /etc/facter/facts.d/nodeless_zenoss.txt
        [ ! -z "$NAGIOS" ] && echo -e "nodeless_nagios=client" >  /etc/facter/facts.d/nodeless_nagios.txt
        [ ! -z "$DC" ] && echo -e "datacenter=${DC}" > /etc/facter/facts.d/datacenter.txt
        do_hostname
	    do_puppet | tee $LOG
        # bad boys do it twice
	    do_puppet | tee $LOG

	    msg Done!
	else
	    if ! $(which dialog > /dev/null 2>&1) ; then
	        do_install
	    elif ! $(which puppet > /dev/null 2>&1) ; then
	        do_install
	    fi
        if [ $RUNPUPPET -eq 1 ] ; then
            do_puppet
        else
            # main loop
	        while manage_box
	        do
	            sleep 1
	        done
        fi
	fi
}
main
exit 0
