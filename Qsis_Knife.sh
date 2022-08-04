#!/bin/sh
#######################################################################################
# 
# Author      : Departamento de Sistemas, Quiter Servicios Centrales.
# Date        : 01/2021
#
# 05 5,22 * * * cd /u2/cambio.2021/XXX;sh Qsis_Knife.sh
#
#######################################################################################

######################## Funciones Auxiliares

_Load_Var_(){
	#
	#################### Variables que necesitamos personalizar
	#
	### Codigo cliente en SAC
	CODCLI="0942"
	### Pais paginas_web y QGW (es,mx,co,bo,pt,arg,cl,pe,ag,agarg,agpt,calgor)
	PAIS=es
	# Sufijo de la instancia a desplegar ("" es generica, "B", "C",...)
	sufijo=""
	# Sufijo de la instancia a generar Qbase
	sufijoGEN=""
	### Credenciales id 0 para QuiterSetup & QGW & Rsync
	rootuser="rootquiter"
	rootpassword="HecnlsndS.$CODCLI"
	### Credenciales usuarios Quiter
	aquiterpass="HecnlsndS.$CODCLI"
	quiterpass="Ecnlsnd.$CODCLI"
	gatewaypass="Gecnlsnd.$CODCLI"
	qbiuserpass="Ecnlsnd.$CODCLI"
	ftpqpass="HecnlsndS2017"
	### Host & ip
	HOST="NombreClienteDms o NombreClienteQae"
	DMSnew="10.34.39.63"
	QAEnew="no aplica"
	DMSold="10.34.39.120"
	QAEold="no aplica"
	### DmsTest o InstanciaX
	QAWID=""
	### UniVerse version a instalar
	universever="uv_linux_11.3.4.9004_64bit.zip"
	#universever="uv_linux_11.3.4_64bit.zip"
	#universever="uv_linux_11.3.2.7001_64bit.zip"
	#universever="uv_linux_11.3.1.6025_64bit.zip"
	#universever="uv_linux_11.2.5_64bit.zip"
	#universever="uv_linux_11.2.5_32bit.zip"
	#universever="uv_linux_11.2.4_64bit.zip"
	#universever="uv_linux_11.1.14.zip"
	### UniVerse Numero de serie y usuarios
	UVSERIE="1234567890"
	UVUSERS="15"
	### Libreria UniVerse para QGW
	QGWLIBold="10.2"
	QGWLIBnew="11.3.2"
	### En los procesos de limpieza de Estadisticas del Pool y Sucesos de Mensajes
	### fecha a partir de la que conservamos registros (eliminamos los anteriores a esta fecha).
	MAXDATE="2021-03-01"
	### Email notificacion
	email="israel.pascual@quiter-sc.com"
	#################### Parametros fijos o autogenerados NO modificar
	#
	HOSTDMS=QuiterDms
	HOSTQAE=QuiterQae
	# UniVerse
	UVDIR="/usr/uv"
	UVCMD="/usr/uv/bin/uv"
	# instancia (B,C,...)
	gquiter="quiter${sufijo,,}"
	QPATH="/u2/quiter$sufijo"
	QPATHGEN="/u2/quiter$sufijoGEN"
	# Qae
	QAEPATH="/repositorios/mongodb_data"
	# Dia y hora para logs
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	# Directorio de lanzamiento
	LDIR=`pwd`
	# Logs path
	KSLOG="${LOGDATE}_${LOGTIME}_Qsis_Knife_stdout.log"
	KSERR="${LOGDATE}_${LOGTIME}_Qsis_Knife_stderr.log"
	# Pais (es,mx,co,bo,pt,arg,cl,pe,ag,agarg,agpt,calgor)
	case $PAIS in
		es | ag )      
			LCTIME="ln -vs /usr/share/zoneinfo/Europe/Madrid /etc/localtime"
			QGWENV="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=ES -Duser.country=ES -Duser.timezone=Europe/Madrid -XX:+UseParallelGC -Xmx4G\""
			QGWCAT="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=ES -Duser.country=ES -Duser.timezone=Europe/Madrid -XX:+UseParallelGC -Xms512M -Xmx4G -XX:MaxPermSiz=128m\""
			;;
		bo)      
			LCTIME="ln -vs /usr/share/zoneinfo/America/La_Paz /etc/localtime"
			QGWENV="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=BO -Duser.country=BO -Duser.timezone=America/La_Paz -XX:+UseParallelGC -Xmx4G\""
			QGWCAT="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=BO -Duser.country=BO -Duser.timezone=America/La_Paz -XX:+UseParallelGC -Xms512M -Xmx4G -XX:MaxPermSiz=128m\""
			QISVPN=tunQISLA
			;;
		co)
			LCTIME="ln -vs /usr/share/zoneinfo/America/Bogota /etc/localtime"
			QGWENV="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=CO -Duser.country=CO -Duser.timezone=America/Bogota -XX:+UseParallelGC -Xmx4G\""
			QGWCAT="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=CO -Duser.country=CO -Duser.timezone=America/Bogota -XX:+UseParallelGC -Xms512M -Xmx4G -XX:MaxPermSiz=128m\""
			QISVPN=tunQISLA
			;; 
		pe)
			LCTIME="ln -vs /usr/share/zoneinfo/America/Lima /etc/localtime"
			QGWENV="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=PE -Duser.country=PE -Duser.timezone=America/Lima -XX:+UseParallelGC -Xmx4G\""
			QGWCAT="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=PE -Duser.country=PE -Duser.timezone=America/Lima -XX:+UseParallelGC -Xms512M -Xmx4G -XX:MaxPermSiz=128m\""
			QISVPN=tunQISLA
			;; 
		mx)
			LCTIME="ln -vs /usr/share/zoneinfo/Mexico/General /etc/localtime"
			QGWENV="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=MX -Duser.country=MX -Duser.timezone=America/Mexico_City -XX:+UseParallelGC -Xmx4G\""
			QGWCAT="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=MX -Duser.country=MX -Duser.timezone=America/Mexico_City -XX:+UseParallelGC -Xms512M -Xmx4G -XX:MaxPermSiz=128m\""
			QISVPN=tunQISNA
			VPNPAIS=tapQuiterMX
			;;
		arg | agarg )
			LCTIME="ln -vs /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime"
			QGWENV="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=AR -Duser.country=AR -Duser.timezone=America/Buenos_Aires -XX:+UseParallelGC -Xmx4G\""
			QGWCAT="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=AR -Duser.country=AR -Duser.timezone=America/Buenos_Aires -XX:+UseParallelGC -Xms512M -Xmx4G -XX:MaxPermSiz=128m\""
			QISVPN=tunQISLA
			;;
		pt | agpt )
			LCTIME="ln -vs /usr/share/zoneinfo/Europe/Lisbon /etc/localtime"
			QGWENV="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=PT -Duser.country=PT -Duser.timezone=Europe/Lisbon -XX:+UseParallelGC -Xmx4G\""
			QGWCAT="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=PT -Duser.country=PT -Duser.timezone=Europe/Lisbon -XX:+UseParallelGC -Xms512M -Xmx4G -XX:MaxPermSiz=128m\""
			;;
		cl )
			LCTIME="ln -vs /usr/share/zoneinfo/America/Santiago /etc/localtime"
			QGWENV="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=CL -Duser.country=CL -Duser.timezone=America/Santiago -XX:+UseParallelGC -Xmx4G\""
			QGWCAT="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=CL -Duser.country=CL -Duser.timezone=America/Santiago -XX:+UseParallelGC -Xms512M -Xmx4G -XX:MaxPermSiz=128m\""			
			QISVPN=tunQISLA
			;;
		*)
			LCTIME="ln -vs /usr/share/zoneinfo/Europe/Madrid /etc/localtime"
			QGWENV="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=ES -Duser.country=ES -Duser.timezone=Europe/Madrid -XX:+UseParallelGC -Xmx4G\""
			QGWCAT="JAVA_OPTS=\"-Dquiter.home=\$QUITER_HOME -Dfile.encoding=ISO-8859-15 -Duser.language=es -Duser.region=ES -Duser.country=ES -Duser.timezone=Europe/Madrid -XX:+UseParallelGC -Xms512M -Xmx4G -XX:MaxPermSiz=128m\""
			;;
	esac
	#
	separador="######################################################################################################################################### \\n"
}

_Redir_Log(){
	# Redirigir standard-output y standard-error
	exec 1>${KSLOG} 2>${KSERR}
}

_ScriptLog(){
	echo -e $separador 
	echo -e Date...........................: `date`
	echo -e ScriptName.....................: $0
	echo -e Run dir........................: $LDIR
	echo -e UserID.........................: `id`
	echo -e ScriptID.......................: $$
	echo -e Nº parametros..................: $#
	if [ "$#" -gt 0 ]; then
		echo -e Arguments......................: $*
	fi
	echo -e Standard Output................: $KSLOG
	echo -e Standard Error.................: $KSERR
	echo -e HostName.......................: `hostname`
	echo -e Host...........................: $HOST
	echo -e HostDms........................: $HOSTDMS
	echo -e HostQae........................: $HOSTQAE
	echo -e Direccion ip DMS-nuevo.........: $DMSnew
	echo -e Direccion ip QAE-nuevo.........: $QAEnew
	echo -e Pais...........................: $PAIS
	echo -e Codigo Cliente.................: $CODCLI
	echo -e Email..........................: $email
	echo -e _UniVerse
	echo -e UniVerse version...............: $universever
	echo -e UniVerse ejecutable............: $UVCMD
	echo -e _QuiterSetup
	echo -e QuiterSetup user...............: $rootuser
	echo -e QuiterSetup password...........: $rootpassword
	echo -e Sufijo para Plataformar........: $sufijo
	echo -e Sufijo para Generar............: $sufijoGEN
	echo -e Quiter path para Plataformar...: $QPATH
	echo -e Quiter path para Generar.......: $QPATHGEN
	echo -e Grupo quiter...................: $gquiter
	echo -e _Credenciales Quiter
	echo -e Quiter ........................: $quiterpass
	echo -e Aquiter .......................: $aquiterpass
	echo -e Gateway .......................: $gatewaypass
	echo -e Ftpq ..........................: $ftpqpass
	echo -e _Cambio de servidor
	echo -e Direccion ip DMS-produccion....: $DMSold
	echo -e QGW libreria a modificar.......: $QGWLIBold
	echo -e QGW libreria nueva.............: $QGWLIBnew
	echo -e
	echo -e $separador
	echo -e $separador
}

_DownUnzip(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	DWLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_DownUnzip_stdout.log"
	DWERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_DownUnzip_stderr.log"
	# necesitamos el sitio ftp /quitersetup 
	#DWCMD1="wget -r -np -nH -N --cut-dirs=1 ftp://ftpq:collega@$DMSold/quitersetup/Cliente_Qbase.zip"
	#DWCMD2="curl -v -p ftp://ftpq:collega@$DMSold/quitersetup/Cliente_qjava_qrs_quiterweb_mysql.zip -o Cliente_qjava_qrs_quiterweb_mysql.zip"
	DWCMD1="curl -v -p ftp://eslauto:10800@datosconversion.quiter.com/Cliente_Qbase.zip -o Cliente_Qbase.zip"
	DWCMD2="curl -v -p ftp://eslauto:10800@datosconversion.quiter.com/Cliente_qjava_qrs_quiterweb_mysql.zip -o Cliente_qjava_qrs_quiterweb_mysql.zip"
	#
	UNZIP1="unzip -o Cliente_Qbase.zip"
	UNZIP2="unzip -o Cliente_qjava_qrs_quiterweb_mysql.zip"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	mkdir -p _old_quiter
	cd _old_quiter
	echo -e "==== [$1/$2] Download & Unzip ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $DWLOG
	echo -e Standard Error.................: $DWERR
	echo -e Download Qbase.................: $DWCMD1
	echo -e Download No-Qbase..............: $DWCMD2
	echo -e Unzip Qbase....................: $UNZIP1
	echo -e Unzip No-Qbase.................: $UNZIP2 \\n
	echo -e "\\n Download QBASE"
    date
    echo -e $separador                      1>$DWERR
    echo -e "Download QBASE \\n"            1>>$DWLOG 2>>$DWERR
    date                                    1>>$DWLOG 2>>$DWERR
    echo -e $DWCMD1                         1>>$DWLOG 2>>$DWERR
    $DWCMD1                                 1>>$DWLOG 2>>$DWERR
    date
    echo -e $separador                      1>>$DWERR
    echo -e "\\n Download No-QBASE"
    date
    echo -e "Download No-QBASE \\n"         1>>$DWLOG 2>>$DWERR
    date                                    1>>$DWLOG 2>>$DWERR
    echo -e $DWCMD2                         1>>$DWLOG 2>>$DWERR
    $DWCMD2                                 1>>$DWLOG 2>>$DWERR
    date
    echo -e $separador                      1>>$DWLOG
    echo -e "\\n QBASE"
    date
    echo -e "Unzip QBASE \\n"               1>>$DWLOG 2>>$DWERR
    date                                    1>>$DWLOG 2>>$DWERR
    ls -lha                                 1>$DWLOG
    $UNZIP1                                 1>>$DWLOG 2>>$DWERR
    date                                    1>>$DWLOG 2>>$DWERR
    date
    echo -e $separador                      1>>$DWLOG
    echo -e "\\n Unzip No-QBASE"
    date
    echo -e "Unzip No-QBASE \\n"            1>>$DWLOG 2>>$DWERR
    date                                    1>>$DWLOG 2>>$DWERR
    $UNZIP2                                 1>>$DWLOG 2>>$DWERR
    ls -lha                                 1>>$DWLOG
    date                                    1>>$DWLOG 2>>$DWERR
    date
    cd $LDIR
	echo -e "\\n==== Completed Download & Unzip ====\\n"
}

_QGW_Cfg__(){
	cd $LDIR
	if [ $1 ]
	then
		LOGDATE=`date +\%F`
		LOGTIME=`date +\%T`
		DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
		QGWLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QgwCfg_stdout.log"
		QGWERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QgwCfg_stderr.log"
		echo -e $separador 
		mkdir -p $DIRLOG
		echo -e "==== [$1/$2] QGW Config Cfg ===="
		echo -e Date...........................: `date`
		echo -e Run dir........................: `pwd`
		echo -e Standard Output................: $QGWLOG
		echo -e Standard Error.................: $QGWERR \\n
	else
		echo -e "==== QGW Config UvLib ===="
	fi
	ls -la $QPATH/qjava/conf/quitergateway.properties* 1>>$QGWLOG 2>>$QGWERR
	# tenemos que adaptar la version de objetos universe que utilizamos
	if [ -d /u2/quiter.plat ]
	then
		echo -e "\\ncambio de servidor"
		/usr/bin/cp -rvf /u2/quiter.plat/qjava/libs/Universe/* $QPATH/qjava/libs/Universe 1>>$QGWLOG 2>>$QGWERR
	else
		echo -e "\\nplataformado nuevo"
		unzip -o RepoLin/uvlibs_12.1.1.zip 1>>$QGWLOG 2>>$QGWERR
		mv -v 12.1.1/ $QPATH/qjava/libs/Universe/ 1>>$QGWLOG 2>>$QGWERR
	fi
	chmod -vR 775 $QPATH/qjava/libs/Universe 1>>$QGWLOG 2>>$QGWERR
	cadena1=$QGWLIBold
	cadena2=$QGWLIBnew
	# cp -v $QPATH/qjava/conf/quitergateway.properties $QPATH/qjava/conf/quitergateway.properties.old 1>>$QGWLOG 2>>$QGWERR
	# echo -e "[sed 's/$cadena1/$cadena2/g ' $QPATH/qjava/conf/quitergateway.properties > $QPATH/qjava/conf/quitergateway.properties.mod] \\n" 1>>$QGWLOG 2>>$QGWERR
	# sed "s/$cadena1/$cadena2/g " $QPATH/qjava/conf/quitergateway.properties > $QPATH/qjava/conf/quitergateway.properties.mod
	# ls -la $QPATH/qjava/conf/quitergateway.properties* 1>>$QGWLOG 2>>$QGWERR
	# mv -vf $QPATH/qjava/conf/quitergateway.properties.mod $QPATH/qjava/conf/quitergateway.properties 1>>$QGWLOG 2>>$QGWERR
	# ls -la $QPATH/qjava/conf/quitergateway.properties* 1>>$QGWLOG 2>>$QGWERR
	# chmod -vR 775 $QPATH/qjava/conf 1>>$QGWLOG 2>>$QGWERR
	# cat $QPATH/qjava/conf/quitergateway.properties |grep version_objetos
	
	# Configurar quitergateway.properties
	cp -v $QPATH/qjava/conf/quitergateway.properties $QPATH/qjava/conf/quitergateway.properties.bak 1>>$QGWLOG 2>>$QGWERR
	cp -v $QPATH/qjava/conf/quitergateway.properties $LDIR/$DIRLOG/quitergateway.properties.bak 1>>$QGWLOG 2>>$QGWERR
	sed "s/version_objetos_universe=$QGWLIBold/version_objetos_universe=$QGWLIBnew/g " $LDIR/$DIRLOG/quitergateway.properties.bak > $LDIR/$DIRLOG/quitergateway.properties.mod.1
	sed "s/password_universe=gateway/password_universe=$gatewaypass/g " $LDIR/$DIRLOG/quitergateway.properties.mod.1 > $LDIR/$DIRLOG/quitergateway.properties.mod.2
	sed "s/dias_limite_estadisticas_pool=60/dias_limite_estadisticas_pool=20/g " $LDIR/$DIRLOG/quitergateway.properties.mod.2 > $LDIR/$DIRLOG/quitergateway.properties.mod.3
	sed "s/usuario_administrador=root/usuario_administrador=rootquiter/g " $LDIR/$DIRLOG/quitergateway.properties.mod.3 > $LDIR/$DIRLOG/quitergateway.properties.mod.4
	cp -vf $LDIR/$DIRLOG/quitergateway.properties.mod.4 $QPATH/qjava/conf/quitergateway.properties 1>>$QGWLOG 2>>$QGWERR
	ls -la $QPATH/qjava/conf/quitergateway.properties* 1>>$QGWLOG 2>>$QGWERR
	chmod -vR 775 $QPATH/qjava/conf 1>>$QGWLOG 2>>$QGWERR
	cat $QPATH/qjava/conf/quitergateway.properties |grep version_objetos		
	cd $LDIR
	echo -e "\\n==== Completed QGW libs ====\\n"
}

_QGW_Lib__(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QGWLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QgwUvLib_stdout.log"
	QGWERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QgwUvLib_stderr.log"
	echo -e $separador 
	mkdir -p $DIRLOG
	echo -e "==== [$1/$2] QGW Config UvLib ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QGWLOG
	echo -e Standard Error.................: $QGWERR \\n
	ls -la $QPATH/qjava/conf/quitergateway.properties* 1>>$QGWLOG 2>>$QGWERR
	# tenemos que adaptar la version de objetos universe que utilizamos
	cadena1=$QGWLIBold
	cadena2=$QGWLIBnew
	cp -v $QPATH/qjava/conf/quitergateway.properties $QPATH/qjava/conf/quitergateway.properties.bak 1>>$QGWLOG 2>>$QGWERR
	cp -v $QPATH/qjava/conf/quitergateway.properties $LDIR/$DIRLOG/quitergateway.properties.bak 1>>$QGWLOG 2>>$QGWERR
	sed "s/version_objetos_universe=$QGWLIBold/version_objetos_universe=$QGWLIBnew/g " $LDIR/$DIRLOG/quitergateway.properties.bak > $LDIR/$DIRLOG/quitergateway.properties.mod.1
	cp -vf $LDIR/$DIRLOG/quitergateway.properties.mod.1 $QPATH/qjava/conf/quitergateway.properties 1>>$QGWLOG 2>>$QGWERR
	ls -la $QPATH/qjava/conf/quitergateway.properties* 1>>$QGWLOG 2>>$QGWERR
	chown -vR quiter:quiter $QPATH/qjava/conf/quitergateway.properties 1>>$QGWLOG 2>>$QGWERR
	chmod -vR 775 $QPATH/qjava/conf/quitergateway.properties 1>>$QGWLOG 2>>$QGWERR
	cat $QPATH/qjava/conf/quitergateway.properties |grep version_objetos		
	cd $LDIR
	echo -e "\\n==== Completed QGW libs ====\\n"
}

_QGW_Qae__(){
	cd $LDIR
	if [ $1 ]
	then
		echo -e $separador 
		LOGDATE=`date +\%F`
		LOGTIME=`date +\%T`
		DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
		QGWLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QgwQae_stdout.log"
		QGWERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QgwQae_stderr.log"
		echo -e "==== [$1/$2] QGW Config Qae ===="
		echo -e Date...........................: `date`
		echo -e Run dir........................: `pwd`
		echo -e Standard Output................: $QGWLOG
		echo -e Standard Error.................: $QGWERR \\n
		mkdir -p $DIRLOG
	else
		echo -e "==== QGW Config Qae ===="
	fi
	cadena1="127.0.0.1"
	cadena2=$QAEnew
	cp -v $QPATH/qjava/conf/qae.json $QPATH/qjava/conf/qae.json.old 1>>$QGWLOG 2>>$QGWERR
	ls -la $QPATH/qjava/conf/qae.json* 1>>$QGWLOG 2>>$QGWERR
	echo -e "[sed 's/$cadena1/$cadena2/g ' $QPATH/qjava/conf/qae.json > $QPATH/qjava/conf/qae.json.mod] \\n" 1>>$QGWLOG 2>>$QGWERR
	sed "s/$cadena1/$cadena2/g " $QPATH/qjava/conf/qae.json > $QPATH/qjava/conf/qae.json.mod
	ls -la $QPATH/qjava/conf/qae.json* 1>>$QGWLOG 2>>$QGWERR
	mv -vf $QPATH/qjava/conf/qae.json.mod $QPATH/qjava/conf/qae.json 1>>$QGWLOG 2>>$QGWERR
	ls -la $QPATH/qjava/conf/qae.json* 1>>$QGWLOG 2>>$QGWERR
	chmod -vR 775 $QPATH/qjava/conf 1>>$QGWLOG 2>>$QGWERR
	cat $QPATH/qjava/conf/qae.json |grep mongoServer
	cd $LDIR
	echo -e "==== Completed QGW Qae ====\\n"
}

_QDBLRset_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QDBLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QDBLive_Reset_stdout.log"
	QDBERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QDBLive_Reset_stderr.log"
	echo -e $separador
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] QDBLive reset ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QDBLOG
	echo -e Standard Error.................: $QDBERR
	/etc/init.d/mysql.qjava start 1>$QDBLOG 2>$QDBERR
	sleep 5
	cd $QPATH/QDBLiveLx
	sh QDBLiveLx.sh -r 1>>$QDBLOG 2>>$QDBERR
	sleep 5
	/etc/init.d/mysql.qjava stop 1>>$QDBLOG 2>>$QDBERR
	cd $LDIR
	echo -e "\\n==== Completed QDBLive reset ====\\n"
}

_QgwLibUv_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QGWLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QgwLibUv_stdout.log"
	QGWERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QgwLibUv_stderr.log"
	RSCMD="/usr/bin/rsync -rchv -u -ogp --ignore-existing $LDIR/RepoLin/Universe/* $QPATH/qjava/libs/Universe/"
	UNZIP="unzip -o $LDIR/RepoLin/libs.zip -d $LDIR/RepoLin"
	echo -e $separador 
	mkdir -p $DIRLOG
	echo -e "==== [$1/$2] QGW Rsync LibUv ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QGWLOG
	echo -e Standard Error.................: $QGWERR
	echo -e Rsync command..................: $RSCMD  
	echo -e Unzip command..................: $UNZIP
	echo -e Version Lib UniVerse.new.......: $QGWLIBnew \\n
	# Incorporamos las librerias de UniVerse que nos faltan en QGW
	echo -e \\n Librerias UniVerse iniciales en $QPATH/qjava/libs/Universe/ \\n
	ls -lha $QPATH/qjava/libs/Universe/
	if [ -d $QPATH/qjava/libs/Universe/$QGWLIBnew ];
		then
			echo -e \\n Existe $QPATH/qjava/libs/Universe/$QGWLIBnew \\n
		else
			echo -e \\n No-Existe $QPATH/qjava/libs/Universe/$QGWLIBnew
			echo -e \\n Descomprimir $LDIR/RepoLin/lib.zip
			echo -e \\n $UNZIP                             1>$QGWLOG 
			$UNZIP                                         1>>$QGWLOG 2>>$QGWERR
			chown -vR quiter:quiter $LDIR/RepoLin/Universe 1>>$QGWLOG 2>>$QGWERR
			chmod -vR 775 $LDIR/RepoLin/Universe           1>>$QGWLOG 2>>$QGWERR
			echo -e \\n Incorporar librerias que falten
			echo -e \\n $UNZIP                             1>>$QGWLOG 
			$RSCMD                                         1>>$QGWLOG 2>>$QGWERR
			echo -e \\n Librerias UniVerse finales en $QPATH/qjava/libs/Universe/ \\n
			ls -lha $QPATH/qjava/libs/Universe/
	fi
	cd $LDIR
	echo -e "\\n==== Completed QGW Rsync LibUv ====\\n"

}

_AddAccnt_(){
	cd $LDIR
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_AddAccount_${sufijo}_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_AddAccount_${sufijo}_stderr.log"
	echo -e $separador 
	mkdir -p $DIRLOG
	echo -e "==== [$1/$2] Crear cuentas UniVerse $sufijo ===="
	echo -e Date...........................: `date`		
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR
	echo -e UniVerse path..................: $UVDIR
	echo -e Quiter ..path..................: $QPATH
	echo -e Sufijo.........................: $sufijo \\n
	# Creamos las cuentas aunque no este el directorio destino
	#if [ -d $quiter ]
	#then
	#	echo -e "$quiter found. \\n"
	#else
	#	echo -e "$quiter not found. \\n"
	#	exit
	#fi
	cd $UVDIR
	pwd 1>$UVLOG 2>$UVERR
	cd "&SAVEDLISTS&"
	pwd 1>>$UVLOG 2>>$UVERR
	cp -v UV CONEXION$sufijo 1>>$UVLOG 2>>$UVERR
	cp -v UV COMERCIAL$sufijo 1>>$UVLOG 2>>$UVERR
	cp -v UV CONTA5$sufijo 1>>$UVLOG 2>>$UVERR
	cp -v UV GEN4GL$sufijo 1>>$UVLOG 2>>$UVERR
	cp -v UV POSVENTA5$sufijo 1>>$UVLOG 2>>$UVERR
	cp -v UV BBADAPTER$sufijo 1>>$UVLOG 2>>$UVERR
	cp -v UV VISTA$sufijo 1>>$UVLOG 2>>$UVERR
	cd $UVDIR
	bin/uv "LIST UV.ACCOUNT" 1>>$UVLOG 2>>$UVERR
	bin/uv "COPY FROM UV.SAVEDLISTS TO UV.ACCOUNT CONEXION$sufijo OVERWRITING"  1>>$UVLOG 2>>$UVERR
	bin/uv "COPY FROM UV.SAVEDLISTS TO UV.ACCOUNT COMERCIAL$sufijo OVERWRITING" 1>>$UVLOG 2>>$UVERR
	bin/uv "COPY FROM UV.SAVEDLISTS TO UV.ACCOUNT CONTA5$sufijo OVERWRITING" 1>>$UVLOG 2>>$UVERR
	bin/uv "COPY FROM UV.SAVEDLISTS TO UV.ACCOUNT GEN4GL$sufijo OVERWRITING" 1>>$UVLOG 2>>$UVERR
	bin/uv "COPY FROM UV.SAVEDLISTS TO UV.ACCOUNT POSVENTA5$sufijo OVERWRITING" 1>>$UVLOG 2>>$UVERR
	bin/uv "COPY FROM UV.SAVEDLISTS TO UV.ACCOUNT BBADAPTER$sufijo OVERWRITING" 1>>$UVLOG 2>>$UVERR
	bin/uv "COPY FROM UV.SAVEDLISTS TO UV.ACCOUNT VISTA$sufijo OVERWRITING" 1>>$UVLOG 2>>$UVERR

	# *** CONEXION
	echo "11"> CTA.TXT
	echo R $QPATH/CONEXION>> CTA.TXT
	echo fi>> CTA.TXT
	bin/uv "ED UV.ACCOUNT CONEXION$sufijo"<CTA.TXT 1>>$UVLOG 2>>$UVERR

	# *** COMERCIAL
	echo "11"> CTA.TXT
	echo R $QPATH/COMERCIAL>> CTA.TXT
	echo fi>> CTA.TXT
	bin/uv "ED UV.ACCOUNT COMERCIAL$sufijo"<CTA.TXT 1>>$UVLOG 2>>$UVERR

	# *** CONTA5
	echo "11"> CTA.TXT
	echo R $QPATH/CONTA5>> CTA.TXT
	echo fi>> CTA.TXT
	bin/uv "ED UV.ACCOUNT CONTA5$sufijo"<CTA.TXT 1>>$UVLOG 2>>$UVERR

	# *** GEN4GL
	echo "11"> CTA.TXT
	echo R $QPATH/GEN4GL>> CTA.TXT
	echo fi>> CTA.TXT
	bin/uv "ED UV.ACCOUNT GEN4GL$sufijo"<CTA.TXT 1>>$UVLOG 2>>$UVERR

	# *** POSVENTA5
	echo "11"> CTA.TXT
	echo R $QPATH/POSVENTA5>> CTA.TXT
	echo fi>> CTA.TXT
	bin/uv "ED UV.ACCOUNT POSVENTA5$sufijo"<CTA.TXT 1>>$UVLOG 2>>$UVERR

	# *** BBADAPTER
	echo "11"> CTA.TXT
	echo R $QPATH/BBADAPTER>> CTA.TXT
	echo fi>> CTA.TXT
	bin/uv "ED UV.ACCOUNT BBADAPTER$sufijo"<CTA.TXT 1>>$UVLOG 2>>$UVERR

	# *** VISTA
	echo "11"> CTA.TXT
	echo R $QPATH/VISTA>> CTA.TXT
	echo fi>> CTA.TXT
	bin/uv "ED UV.ACCOUNT VISTA$sufijo"<CTA.TXT 1>>$UVLOG 2>>$UVERR

	bin/uv "LIST UV.ACCOUNT" 1>>$UVLOG 2>>$UVERR
	bin/uv "LIST UV.ACCOUNT"

	cd $LDIR
	echo -e "\\n==== Completada creaacion de cuentas UniVerse ==== \\n"
}

_LogEmail_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	MLLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Email_stdout.log"
	MLERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Email_stderr.log"
	ZIPNM="$LDIR/${HOST}_$3.zip"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Zip Logs & enviar Email ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $MLLOG
	echo -e Standard Error.................: $MLERR
	echo -e Host...........................: $HOST
	echo -e Zip Log name...................: $ZIPNM \\n
	mkdir -p $DIRLOG 
	zip -rv $ZIPNM $3* *Qsis* universe*/uv.*/uv.load.log quitersetup/$3_logs 1>$MLLOG 2>$MLERR
	# El nombre maquina no puede tener _ porque no es un nombre de cuenta valido y gmail no admite el email
	echo "$3 logs attached"|mailx -a $ZIPNM -s "$HOST $3" $email 1>>$MLLOG 2>>$MLERR
	ls -lha $ZIPNM
	echo -e "\\n==== Completado Zip Log & enviar Email ==== \\n"
}

_Qae_Inst_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QAELOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qae_Install_stdout.log"
	QAEERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qae_Install_stderr.log"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Despliegue Qae ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QAELOG
	echo -e Standard Error.................: $QAEERR \\n
	mkdir -v /repositorios 1>$QAELOG 2>$QAEERR
	cp -v $LDIR/RepoQAE/mongodb-linux-x86_64-3.2.4.tgz /usr/local
	sleep 5
	sh $LDIR/RepoQAE/installmongoqae.sh 1>>$QAELOG 2>>$QAEERR
	chown -vR root:root /usr/local/mongodb 1>>$QAELOG 2>>$QAEERR
	chmod -vR 775 /usr/local/mongodb 1>>$QAELOG 2>>$QAEERR
	ps -efjH|grep mongo 
	echo -e "\\n==== Completado despliegue Qae ==== \\n"
}

_Fwd_Dms__(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	FWDLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Fwd_Install_stdout.log"
	FWDERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Fwd_Install_stderr.log"
	FWTEST="1"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Dms-Firewall ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $FWDLOG
	echo -e Standard Error.................: $FWDERR \\n
	
	if [ firewall-cmd ]
	then
		echo -e "\\n firewall-cmd existe \\n "                                    
		FWTEST=$(/usr/bin/firewall-cmd --state 2>&1| grep -c "not")
		#echo $FWTEST
		if [ $FWTEST == 1 ];
		then
			echo -e "\\n FirewallD not Running \\n "
		else
			echo -e "\\n FirewallD Running, insertamos reglas \\n "
			echo -e "\\n>>>>>> nmcli con show\\n"                                  1>>$FWDLOG 2>>$FWDLOG
			nmcli con show                                                         1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> iptables --list\\n"                                 1>>$FWDLOG 2>>$FWDLOG
			iptables --list                                                        1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> firewall-cmd --get-zones\\n"                        1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --get-zones                                               1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> firewall-cmd --get-default-zone\\n"                 1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --get-default-zone                                        1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> firewall-cmd --get-active-zones\\n"                 1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --get-active-zones                                        1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=trusted --change-interface=tap100      1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=trusted --change-interface=tun100      1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=trusted --change-interface=tun1000     1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=trusted --change-interface=tunQIS      1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=public  --add-service=ftp              1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=public  --add-service=http             1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=public  --add-service=samba            1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=public  --add-port=6080/tcp            1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=public  --add-port=6443/tcp            1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=public  --add-port=31438/tcp           1>>$FWDLOG 2>>$FWDLOG
			if [ $QISVPN ]														   1>>$FWDLOG 2>>$FWDLOG
			then
				echo -e "\\n>>>>>> Pais con interfaz vpn-qis duplicado\\n"         1>>$FWDLOG 2>>$FWDLOG
				firewall-cmd --permanent --zone=trusted --change-interface=$QISVPN 1>>$FWDLOG 2>>$FWDLOG
			else
				echo -e "\\n>>>>>> Pais sin interfaz vpn-qis duplicado\\n"         1>>$FWDLOG 2>>$FWDLOG
			fi
			if [ $VPNPAIS ]														   1>>$FWDLOG 2>>$FWDLOG
			then
				echo -e "\\n>>>>>> Pais con interfaz vpn particular \\n"            1>>$FWDLOG 2>>$FWDLOG
				firewall-cmd --permanent --zone=trusted --change-interface=$VPNPAIS 1>>$FWDLOG 2>>$FWDLOG
			else
				echo -e "\\n>>>>>> Pais sin interfaz vpn particular \\n"            1>>$FWDLOG 2>>$FWDLOG
			fi
			if [ $QAEnew ]														   1>>$FWDLOG 2>>$FWDLOG
			then
				echo -e "\\n>>>>>> Configurado servidor Qae, aplicamos regla \\n"  1>>$FWDLOG 2>>$FWDLOG
				firewall-cmd --permanent --zone=trusted --add-source=$QAEnew       1>>$FWDLOG 2>>$FWDLOG
			else
				echo -e "\\n>>>>>> Sin configurar Qae \\n"                         1>>$FWDLOG 2>>$FWDLOG
			fi	
			firewall-cmd --reload                                                  1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --get-active-zones                                        1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> iptables --list\\n"                                 1>>$FWDLOG 2>>$FWDLOG
			iptables --list                                                        1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> firewall-cmd --get-active-zones\\n"                 1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --get-active-zones                                        1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> firewall-cmd --list-all\\n"                         1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --list-all                                                1>>$FWDLOG 2>>$FWDLOG	
		fi
	else
		echo -e "\\n firewall-cmd NO existe \\n "                                    
	fi
	echo -e "\\n==== Completada configuracion Dms-Firewall ==== \\n"
}

_Fwd_Qae__(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	FWDLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Fwd_Install_stdout.log"
	FWDERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Fwd_Install_stderr.log"
	FWTEST="1"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Qae-Firewall ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $FWDLOG
	echo -e Standard Error.................: $FWDERR \\n
	
	if [ firewall-cmd ]
	then
		echo -e "\\n firewall-cmd existe \\n "                                    
		FWTEST=$(/usr/bin/firewall-cmd --state 2>&1| grep -c "not")
		#echo $FWTEST
		if [ $FWTEST == 1 ];
		then
			echo -e "\\n FirewallD not Running \\n "
		else
			echo -e "\\n FirewallD Running, insertamos reglas \\n "
			echo -e "\\n>>>>>> nmcli con show\\n"                              1>$FWDLOG 2>$FWDLOG
			nmcli con show                                                     1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> iptables --list\\n"                             1>>$FWDLOG 2>>$FWDLOG
			iptables --list                                                    1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> firewall-cmd --get-zones\\n"                    1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --get-zones                                           1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> firewall-cmd --get-default-zone\\n"             1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --get-default-zone                                    1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> firewall-cmd --get-active-zones\\n"             1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --get-active-zones                                    1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=trusted --change-interface=tap100  1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=trusted --change-interface=tun100  1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=trusted --change-interface=tun1000 1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=public  --add-port=27017/tcp       1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --permanent --zone=trusted --add-source=$DMSnew       1>>$FWDLOG 2>>$FWDLOG
			# otra opcion para el puerto del mongo
			#firewall-cmd --permanent --zone=internal --add-port=27017/tcp 1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --reload                                              1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --get-active-zones                                    1>>$FWDLOG 2>>$FWDLOG		
			echo -e "\\n>>>>>> iptables --list\\n"                             1>>$FWDLOG 2>>$FWDLOG
			iptables --list                                                    1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> firewall-cmd --get-active-zones\\n"             1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --get-active-zones                                    1>>$FWDLOG 2>>$FWDLOG
			echo -e "\\n>>>>>> firewall-cmd --list-all\\n"                     1>>$FWDLOG 2>>$FWDLOG
			firewall-cmd --list-all                                            1>>$FWDLOG 2>>$FWDLOG	
		fi
	else
		echo -e "\\n firewall-cmd NO existe \\n "                                    
	fi
	echo -e "\\n==== Completada configuracion QAE-Firewall ==== \\n"
}

_MongoStr_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	MGLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_MongoD_Start_stdout.log"
	MGERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_MongoD_Start_stderr.log"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] MongoD Iniciar ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $MGLOG
	echo -e Standard Error.................: $MGERR \\n
	mv -v /usr/local/mongod.log /usr/local/mongod_${LOGDATE}_${LOGTIME}.log 1>$MGLOG 2>$MGERR
	/etc/init.d/mongod start 1>>$MGLOG 2>>$MGERR
	sleep 5
	ps -efjH |grep mongo 1>>$MGLOG 2>>$MGERR
	tail /usr/local/mongod.log 1>>$MGLOG 2>>$MGERR
	ps -efjH |grep mongo
	echo -e "\\n"
	tail /usr/local/mongod.log
	echo -e "\\n==== Completado inicio MongoD ==== \\n"
}

_ApartaUv_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_ApartaUv_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_ApartaUv_stderr.log"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Aparta Uv ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR
	
	echo -e Contenido en / y /usr antes de apartar Uv 1>$UVLOG 2>$UVERR
	ls -alrt /    1>>$UVLOG 2>>$UVERR
	ls -alrt /usr 1>>$UVLOG 2>>$UVERR
	
	if [ -d /usr/ibm ];
	then
		UVDIRINS=/usr/ibm
		UVDIRBAK=/usr/ibm_bak_${LOGDATE}_${LOGTIME}
		echo -e UniVerse Old instalado en......: $UVDIRINS
		echo -e Apartamos UniVerse Old en......: $UVDIRBAK \\n
		echo -e "Timeout en Uv old \\n" 1>>$UVLOG 2>>$UVERR
		echo -e "Timeout en Uv old \\n"
		cat /usr/ibm/unishared/unirpc/unirpcservices 1>>$UVLOG 2>>$UVERR
		cat /usr/ibm/unishared/unirpc/unirpcservices
		# No podemos sacar esta info porque UniVerse esta parado...
		#echo -e "\\n Tuning en Uv old \\n" 1>>$UVLOG 2>>$UVERR
		#echo -e "\\n Tuning en Uv old \\n"
		#/usr/ibm/uv/bin/smat -t|grep "*" 1>>$UVLOG 2>>$UVERR
		#/usr/ibm/uv/bin/smat -t|grep "*"
		echo -e "\\n Apartando $UVDIRINS \\n"
		mv -vf /usr/ibm $UVDIRBAK
		echo -e "\\n Apartando enlace /u2/uv"
		mv -vf /u2/uv $UVDIRBAK/uv_ln_u2 		
	else
		echo -e "\\n"
	fi

	if [ -d /usr/uv ];
	then
		UVDIRINS=/usr/uv
		UVDIRBAK=/usr/uv_bak_${LOGDATE}_${LOGTIME}
		echo -e UniVerse Old instalado en......: $UVDIRINS
		echo -e Apartamos UniVerse Old en......: $UVDIRBAK \\n
		echo -e "Timeout en Uv old \\n" 1>>$UVLOG 2>>$UVERR
		echo -e "Timeout en Uv old \\n"
		cat /usr/unishared/unirpc/unirpcservices 1>>$UVLOG 2>>$UVERR
		cat /usr/unishared/unirpc/unirpcservices
		# No podemos sacar esta info porque UniVerse esta parado...
		#echo -e "\\n Tuning en Uv old \\n" 1>>$UVLOG 2>>$UVERR
		#echo -e "\\n Tuning en Uv old \\n"
		#/usr/uv/bin/smat -t|grep "*" 1>>$UVLOG 2>>$UVERR
		#/usr/uv/bin/smat -t|grep "*"
		echo -e "\\n Apartando $UVDIRINS \\n" 
		mv -vf /usr/uv $UVDIRBAK
	else
		echo -e "\\n"
	fi

	if [ -L /uv ];
	then
		echo -e "\\n Apartando enlace /uv \\n"
		mv -vf /uv $UVDIRBAK/uv_ln_barra 
	else
		echo -e "\\n"
	fi

	if [ -L /.uvlibs ];
	then
		echo -e "\\n Apartando enlace /.uvlibs \\n"
		mv -vf /.uvlibs $UVDIRBAK
	else
		echo -e "\\n"
	fi

	if [ -f /.uvhome ];
	then
		echo -e "\\n Apartando fichero /.uvhome \\n"
		mv -vf /.uvhome $UVDIRBAK
	else
		echo -e "\\n"
	fi

	if [ -f /.unishared ];
	then
		echo -e "\\n Apartando fichero /.unishared \\n"
		mv -vf /.unishared $UVDIRBAK
	else
		echo -e "\\n"
	fi
	
	if [ -f /etc/init.d/uv.rc ];
	then
		echo -e "\\n Apartando fichero /etc/init.d/uv.rc \\n"
		mv -vf /etc/init.d/uv.rc $UVDIRBAK 
	else
		echo -e "\\n"
	fi

	echo -e $separador 1>>$UVLOG 2>>$UVERR
	echo -e Contenido en / y /usr despues de apartar Uv 1>>$UVLOG 2>>$UVERR
	ls -alrt /    1>>$UVLOG 2>>$UVERR
	ls -alrt /usr 1>>$UVLOG 2>>$UVERR
	
	echo -e "\\n==== Completado Aparta Uv ==== \\n"
}

_UvOldBak_(){

	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	ZIPFIL="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvOldBak.tgz"
	ZIPLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvOldBak_stdout.log"
	ZIPERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvOldBak_stderr.log"
	UVCFG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvConfig"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Backup UvOld ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Zip File UvOld Bak.............: $ZIPFIL
	echo -e Standard Output................: $ZIPLOG
	echo -e Standard Error.................: $ZIPERR \\n
	
	echo -e Generando copia de la instalación actual de UniVerse \\n 
	#zip -r --symlinks $ZIPFIL /usr/uv /usr/unishared /etc/init.d/uv.rc /.uvhome /.uvlibs /uv 1>$ZIPLOG 2>$ZIPERR
	# tar gestiona mejor los enlaces simbolicos
	tar cvfz $ZIPFIL /usr/uv /usr/unishared /etc/init.d/uv.rc /.uvhome /.uvlibs /uv 1>$ZIPLOG 2>$ZIPERR

	echo -e Guardamos el fichero uvconfig para reponerlo al final \\n 
	cp -v /usr/uv/uvconfig $UVCFG
	cp -v /usr/uv/uvconfig $LDIR/$DIRLOG/uvconfig.bak

	echo -e Contenido en $LDIR/$DIRLOG \\n
	ls -lha $LDIR/$DIRLOG
	
	echo -e "\\n==== Completado Backup UvOld ==== \\n"
	
}

_UvOldCfg_(){

	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvOldCfg_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvOldCfg_stderr.log"
	if [ -d /usr/ibm ];
	then
		UVDIRINS=/usr/ibm
	else
		echo -e "\\n"
	fi
	if [ -d /usr/uv ];
	then
		UVDIRINS=/usr
	else
		echo -e "\\n"
	fi
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] UniVerse Old Configuracion ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR
	echo -e UniVerse Old instalado en......: $UVDIRINS
	echo -e \\n UniVerse Old timeout...........:
	cat $UVDIRINS/unishared/unirpc/unirpcservices
	echo -e \\n UniVerse Old tuning............:
	$UVDIRINS/uv/bin/smat -t|grep "*"
	echo -e \\n UniVerse Old licencia..........:
	cd $UVDIRINS/uv
	bin/uvregen -z|head
	
	echo -e Contenido en / y /usr                        1>$UVLOG 2>$UVERR
	ls -alrt /                                           1>>$UVLOG 2>>$UVERR
	ls -alrt /usr                                        1>>$UVLOG 2>>$UVERR
	echo -e "\\n Timeout en Uv old \\n"                  1>>$UVLOG 2>>$UVERR
	cat $UVDIRINS/unishared/unirpc/unirpcservices        1>>$UVLOG 2>>$UVERR
	echo -e "\\n Tuning en Uv old \\n"                   1>>$UVLOG 2>>$UVERR
	$UVDIRINS/uv/bin/smat -t|grep "*"                    1>>$UVLOG 2>>$UVERR
	echo -e "\\n Licencia \\n"                           1>>$UVLOG 2>>$UVERR
	bin/uvregen -z                                       1>>$UVLOG 2>>$UVERR
	$UVDIRINS/uv/bin/smat -t|grep "*" > $LDIR/UvOldTunning.txt
	cd $LDIR
	echo -e "\\n==== Completado UniVerse Old Configuracion ==== \\n"
}

_Licen_Uv_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_LicenciarUv_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_LicenciarUv_stderr.log"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Licenciar Uv ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e UniVerse dir...................: $UVDIR
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR
	echo -e UV serial number...............: $UVSERIE
	echo -e UV number users................: $UVUSERS \\n
	
	if [ -d $UVDIR ];
	then
		cd $UVDIR
		echo -e "Licencia UniVerse actual \\n"       1>>$UVLOG 2>>$UVERR
		bin/uvregen -z                               1>>$UVLOG 2>>$UVERR
		echo -e "Deteniendo UniVerse \\n"            1>>$UVLOG 2>>$UVERR
		bin/uv -admin -stop -force                   1>>$UVLOG 2>>$UVERR
		echo -e "Configurando licencia \\n"          1>>$UVLOG 2>>$UVERR
		bin/uvregen -s $UVSERIE -u $UVUSERS          1>>$UVLOG 2>>$UVLOG
		echo -e "Licencia UniVerse actual \\n"       1>>$UVLOG 2>>$UVERR
		bin/uvregen -z                               1>>$UVLOG 2>>$UVERR
		echo -e "\\n Licencia UniVerse actual \\n"
		bin/uvregen -z
		echo -e "\\n Codigo de configuracion \\n"
		bin/uvregen -C                               1>>$UVLOG 2>>$UVERR
		grep Code $UVERR
		
		case $3 in
			_Pst_Platform_DMS)
				echo -e "\\n Iniciando UniVerse \\n" 1>>$UVLOG 2>>$UVERR
				bin/uv -admin -start                 1>>$UVLOG 2>>$UVERR
				;;
			_UniVerse_Install)
				echo -e "\\n UniVerse detenido para activar \\n"  1>>$UVLOG 2>>$UVERR
				;;
			*)
				echo -e "\\n"
				;;
		esac
		
	else
		echo -e "\\n ¡¡¡¡ Atencion no encontrado $UVDIR !!!! \\n"
	fi
	
	cd $LDIR
	echo -e "\\n==== Completado Licenciar Uv ==== \\n"
}

######################## Funciones GeneracionQbase, Despliegue InstanciaX

_Get_Qbase(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	RSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Get_Qbase_${sufijo}_stdout.log"
	RSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Get_Qbase_${sufijo}_stderr.log"
	ZIPFIL="$LDIR/RepoLin/${HOST}_QuiterSetup.zip"
	#RSCMD="/usr/bin/rsync -ahv --delete --stats --progress $rootuser@$DMSold:$ZIPFIL $ZIPFIL"
	RSCMD="curl -v -p ftp://ftpq:collega@${DMSold}/${HOST}_QuiterSetup.zip -o RepoLin/${HOST}_QuiterSetup.zip"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Download $ZIPFIL generado en $DMSold  ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $RSLOG
	echo -e Standard Error.................: $RSERR
	echo -e Rsync command..................: $RSCMD
	echo -e Qbase Origen...................: $ZIPFIL \\n
	echo -e $RSCMD 1>$RSLOG 2>$RSERR
	$RSCMD 1>>$RSLOG 2>>$RSERR
	#ln -vs ${HOST}_QuiterSetup.zip RepoLin/${HOST}_QuiterSetup.zip 1>>$RRLOG 2>>$RRERR
	cd $LDIR
	ls -lha RepoLin
	du -hs RepoLin
	date
	echo -e "\\n==== Completed download $ZIPFIL ==== \\n"
}

_CfgSufijo(){
	cd $LDIR
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	BPLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_ConfigSys_${sufijo}_stdout.log"
	BPERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_ConfigSys_${sufijo}_stderr.log"
	echo -e $separador
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Start Config Sys $sufijo ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $BPLOG
	echo -e Standard Error.................: $BPERR
	echo -e Quiter.Path....................: $QPATH
	echo -e Sufijo.........................: $sufijo
	echo -e GQuiter........................: $gquiter \\n

	if id -u $gquiter &>/dev/null; then
		echo -e existe usuario $gquiter saltamos la configuracion del sistema para la instancia $sufijo \\n
	else
		echo -e no existe usuario $gquiter continuamos con la configuracion del sistema para la instancia $sufijo \\n
		cp -rpv /u2/usuarios/quiter /u2/usuarios/$gquiter 1>$BPLOG 2>$BPERR
		sed "s/qhome/qhome$sufijo/g " /u2/usuarios/quiter/.bash_profile > /u2/usuarios/$gquiter/.bash_profile
		useradd -d /u2/usuarios/$gquiter $gquiter 1>>$BPLOG 2>>$BPERR
		echo $quiterpass | passwd $gquiter --stdin 1>>$BPLOG 2>>$BPERR
		usermod -a -G $gquiter quiter
		usermod -a -G $gquiter ftpq
		usermod -a -G $gquiter gateway
		usermod -a -G $gquiter mysql
		chown -vR $gquiter:$gquiter /u2/usuarios/$gquiter 1>>$BPLOG 2>>$BPERR
		chmod -vR 775 /u2/usuarios/$gquiter 1>>$BPLOG 2>>$BPERR
		cp -rpv /u2/usuarios/$gquiter /u2/usuarios/dsgenerico$sufijo 1>>$BPLOG 2>>$BPERR
		cat /etc/group|grep quiter 1>>$BPLOG 2>>$BPERR
		cat /etc/passwd|grep quiter 1>>$BPLOG 2>>$BPERR
		echo -e $QPATH > /.qhome$sufijo 
		cat /.qhome$sufijo 1>>$BPLOG 2>>$BPERR
		#si hacemos esto aqui no podemos plataformar
		#ln -vs /u2/quiter/qjava $QPATH/qjava 1>>$BPLOG 2>>$BPERR
		cd $LDIR
		tail -n 1 /etc/passwd
		cat /etc/passwd |grep $gquiter
		grep $gquiter /etc/group
	fi
	echo -e "\\n==== Completed Config Sys $sufijo ==== \\n"
}

_DirCfg_X_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	DRLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_DirCfg__${sufijo}_stdout.log"
	DRERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_DirCfg__${sufijo}_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Crear directorios Post-QuiterSetup $sufijo ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $DRLOG
	echo -e Standard Error.................: $DRERR
	echo -e Sufijo para Plataformar........: $sufijo
	echo -e Quiter Path Plataformar........: $QPATH
	echo -e GQuiter........................: $gquiter \\n
	mkdir -p $DIRLOG 
	echo -e "==== BIN ====" 1>$DRLOG 2>$DRERR
	mkdir -pv $QPATH/bin 1>>$DRLOG 2>>$DRERR
	mkdir -pv /u2/usuarios/dsgenerico$sufijo 1>>$DRLOG 2>>$DRERR
	cp -v /u2/usuarios/dsgenerico/.bash_profile /u2/usuarios/dsgenerico$sufijo/.bash_profile.1 1>>$DRLOG 2>>$DRERR
	sed "s/qhome/qhome${sufijo}/g " /u2/usuarios/dsgenerico$sufijo/.bash_profile.1 > /u2/usuarios/dsgenerico$sufijo/.bash_profile 
	sed "s/quiter/$gquiter/g " $LDIR/RepoLin/CreaUsuario > $QPATH/bin/CreaUsuario$sufijo.1 
	sed "s/dsgenerico/dsgenerico$sufijo/g " $QPATH/bin/CreaUsuario$sufijo.1 > $QPATH/bin/CreaUsuario$sufijo
	rm -vf $QPATH/bin/CreaUsuario$sufijo.1
	rm -vf /u2/usuarios/dsgenerico$sufijo/.bash_profile.1
	chown -vR $gquiter:$gquiter /u2/usuarios/dsgenerico$sufijo 1>>$DRLOG 2>>$DRERR
	chown -vR $gquiter:$gquiter $QPATH/bin/CreaUsuario$sufijo 1>>$DRLOG 2>>$DRERR
	chmod -vR 775 /u2/usuarios/dsgenerico$sufijo 1>>$DRLOG 2>>$DRERR 
	chmod -vR 775 $QPATH/bin/CreaUsuario$sufijo 1>>$DRLOG 2>>$DRERR 
	echo -e "==== DATOS ====" 1>>$DRLOG 2>>$DRERR
	mkdir -pv $QPATH/DATOS 1>>$DRLOG 2>>$DRERR
	echo -e "==== Qjava ====" 1>>$DRLOG 2>>$DRERR
	ln -vs /u2/quiter/qjava $QPATH/qjava 1>>$DRLOG 2>>$DRERR
	ls -lha $QPATH
	echo -e "\\n==== Completada creacion directorios Post-QuiterSetup $sufijo ==== \\n"
}

_Ko_Qae___(){
	cd $LDIR
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	GNDIR="$QPATH/GEN4GL"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qae_Desactivar_${sufijo}_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qar_Desactivar_${sufijo}_stderr.log"
	QCMD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Quiter$sufijoCmd.txt"
	echo -e $separador 
	echo -e "==== [$1/$2] Desactivar Qae $sufijo ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR
	echo -e UniVerse command...............: $UVCMD
	echo -e GEN4GL.Dir.....................: $GNDIR
	echo -e Quiter.Path....................: $QPATH
	echo -e Sufijo.........................: $sufijo \\n
	mkdir -p $DIRLOG
	cd $GNDIR
	#modificar PAR_GEN dependiendo de si es plataformando nuevo o cambio de linux
	echo "WHO"                  >  $QCMD
	echo "SH -c pwd"            >> $QCMD
	echo "DATE"                 >> $QCMD
	echo "SERVICIOS.APLICACION" >> $QCMD
	echo ""                     >> $QCMD
	echo "DATE"                 >> $QCMD
	echo "SERVICIOS.APLICACION" >> $QCMD
	echo "QAE"                  >> $QCMD
	echo ""                     >> $QCMD
	echo "DATE"                 >> $QCMD
	echo "SERVICIOS.APLICACION" >> $QCMD
	echo ""                     >> $QCMD
	echo "DATE"                 >> $QCMD
	cd $GNDIR
	$UVCMD <$QCMD 1>>$UVLOG 2>>$UVERR
	sed -i '/^ *$/d' $UVLOG
	cd $LDIR
	echo -e "\\n==== Completada desactivacion de Qae $sufijo ==== \\n"
}

_QsCfgGen_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QSetupConfig_stdout.log"
	QSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QSetupConfig_stderr.log"
	PATHTMP=$LDIR/quitersetup
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Configuracion QuiterSetup ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QSLOG
	echo -e Standard Error.................: $QSERR
	echo -e Sufijo instancia a Generar.....: $sufijoGEN
	echo -e Quiter Path para Generar.......: $QPATHGEN
	echo -e GQuiter........................: $gquiter
	echo -e QuiterSetup PathTmp............: $PATHTMP \\n
	mkdir -p $DIRLOG
	unzip -o RepoLin/QuiterSetup*.zip 1>$QSLOG 2>$QSERR
	dos2unix quitersetup/conf/* 1>>$QSLOG 2>>$QSERR
	dos2unix quitersetup/bin/*  1>>$QSLOG 2>>$QSERR
	# Configuramos setup.properties para generar Qbase
	mv -v $LDIR/quitersetup/conf/setup.properties $LDIR/quitersetup/conf/setup.properties.bak 1>>$QSLOG 2>>$QSERR
	sed "s/ROOTPASS/$rootpassword/g " $LDIR/RepoLin/setup.properties                > $LDIR/quitersetup/conf/setup.properties.mod
	sed "s/SUFIJO/$sufijoGEN/g "      $LDIR/quitersetup/conf/setup.properties.mod   > $LDIR/quitersetup/conf/setup.properties.mod.1
	sed "s/ROOTUSER/$rootuser/g "     $LDIR/quitersetup/conf/setup.properties.mod.1 > $LDIR/quitersetup/conf/setup.properties.mod
	sed "s@PATHTMP@$PATHTMP@g "       $LDIR/quitersetup/conf/setup.properties.mod   > $LDIR/quitersetup/conf/setup.properties.mod.1
	sed "s@QUITERPATH@$QPATHGEN@g "   $LDIR/quitersetup/conf/setup.properties.mod.1 > $LDIR/quitersetup/conf/setup.properties.mod
	# En setup.properties vienen estas exclusiones
	# excluir_cuentas=bin;QRS;QBI;rvs;quiter_web;qjava;Plantillas;QDBLiveLx;U2DBLivePy;DATOS;IMPFILE;HONDA;bk.POSVENTA5
	# Si queremos agregar mas exclusiones es aqui
	#EXCLUSIONES="IMPFILE;BBADAPTER;VISTA"
	#sed "s!IMPFILE!$EXCLUSIONES!g "   $LDIR/quitersetup/conf/setup.properties.mod   > $LDIR/quitersetup/conf/setup.properties.mod.1
	#cp -vf $LDIR/quitersetup/conf/setup.properties.mod.1 $LDIR/quitersetup/conf/setup.properties.mod
	#
	cat $LDIR/quitersetup/conf/setup.properties.mod >>$QSLOG 
	cp -v $LDIR/quitersetup/conf/setup.properties.mod $LDIR/quitersetup/conf/setup.properties 1>>$QSLOG 2>>$QSERR
	ls -la $LDIR/quitersetup/conf/setup.properties* 1>>$QSLOG 2>>$QSERR
	cat $LDIR/quitersetup/conf/setup.properties
	chmod -vR 777 quitersetup 1>>$QSLOG 2>>$QSERR
	echo -e "\\n==== Completada configuracion QuiterSetup ==== \\n"
}

_QsExeGen_(){
	echo -e $separador 
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}/${LOGDATE}_${LOGTIME}"
	QSLOG="$LDIR/$DIRLOG/QSetupExe_stdout.log"
	QSERR="$LDIR/$DIRLOG/QSetupExe_stderr.log"
	ZIPFIL="$LDIR/RepoLin/${HOST}_QuiterSetup.zip"
	mkdir -p $LDIR/$DIRLOG
	echo -e "==== [$1/$2] Ejecutar QuiterSetup Generacion Qbase $sufijoGEN ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e File Zip.......................: $ZIPFIL
	echo -e Standard Output................: $QSLOG
	echo -e Standard Error.................: $QSERR
	echo -e Quiter.Path....................: $QPATHGEN
	echo -e Sufijo.........................: $sufijoGEN \\n
	cd $LDIR/quitersetup/bin
	echo -e Esperando QuiterSetup finalice... \\n
	su $rootuser -c "sh GenerarSetup.sh"
	echo -e Finalizado QuiterSetup
	cp -pv $LDIR/quitersetup/logs/* $LDIR/$DIRLOG 1>$QSLOG 2>$QSERR
	echo -e \\nEmpaquetamos QuiterSetup en RepoLin \\n
	cd $LDIR
	if [ -d $LDIR/RepoLin ]
		then
			echo -e "$LDIR/RepoLin existe \\n"             1>>$QSLOG 2>>$QSERR
		else
			echo -e "$LDIR/RepoLin no existe, creamos \\n" 1>>$QSLOG 2>>$QSERR
			mkdir -pv $LDIR/RepoLin                        1>>$QSLOG 2>>$QSERR
	fi
	zip -vr $ZIPFIL quitersetup                            1>>$QSLOG 2>>$QSERR
	date
	echo -e "\\n==== Completada ejecucion QuiterSetup ==== \\n"
}

_QsCurlDC_(){
	echo -e $separador 
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Curl_stdout.log"
	QSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Curl_stderr.log"
	QSPATH1="$LDIR/RepoLin/${HOST}_QuiterSetup.zip"
	CURLUP1="curl -v -p -T $QSPATH1 ftp://eslauto:10800@datosconversion.quiter.com/${HOST}_QuiterSetup.zip"
	QSPATH2="$LDIR/RepoLin/${HOST}_qjava_qrs_quiterweb_mysql.zip"
	CURLUP2="curl -v -p -T $QSPATH2 ftp://eslauto:10800@datosconversion.quiter.com/${HOST}_qjava_qrs_quiterweb_mysql.zip"
	CURLIST="curl -v -p --list-only ftp://eslauto:10800@datosconversion.quiter.com"
	cd $LDIR
	echo -e "==== [$1/$2] Upload RepoLin/${HOST}_QuiterSetup.zip a datosconversion.quiter.com ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QSLOG
	echo -e Standard Error.................: $QSERR
	echo -e Path QuiterSetup.zip...........: $QSPATH1
	echo -e Path QuiterGateway export......: $QSPATH2
	echo -e Curl up........................: $CURLUP1
	echo -e Curl up........................: $CURLUP2
	echo -e Curl list......................: $CURLIST \\n
	mkdir -p $DIRLOG
	echo -e \\n Subiendo ${HOST}_QuiterSetup.zip... \\n
	echo -e $separador >$QSLOG
	$CURLUP1 1>>$QSLOG 2>>$QSLOG
	tail -n 5 $QSLOG
	echo -e \\n Subiendo ${HOST}_qjava_qrs_quiterweb_mysql.zip... \\n
	echo -e $separador >>$QSLOG
	$CURLUP2 1>>$QSLOG 2>>$QSLOG
	tail -n 5 $QSLOG
	echo -e \\n Contenido en datosconversion.quiter.com \\n
	$CURLIST 1>>$QSLOG 2>>$QSLOG
	tail -n 10 $QSLOG
	date
	echo -e "\\n==== Completado Upload RepoLin/${HOST}_QuiterSetup.zip a datosconversion.quiter.com ==== \\n"
}

_TstRclone(){
	if rclone --version >/dev/null 2>&1
	then
		echo -e "==== Rclone ok ===="
	else
		echo -e "==== Rclone ko ===="
		yum install -y rclone
		if rclone --version >/dev/null 2>&1
		then
			echo -e "==== Rclone ok ===="
		else
			echo -e "==== Rclone ko ===="
			#wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
			#En Centos5 el certificado ya no es válido
			wget --append-output=$RRLOG http://soporte.quiter.es/publico/ks/rclone-current-linux-amd64.zip
			if [ -f rclone-current-linux-amd64.zip ];
			then
				unzip -o rclone-current-linux-amd64.zip
				rm -vf rclone-current-linux-amd64.zip
				#cd rclone-*-linux-amd64
				ln -sv rclone-*-linux-amd64 rclonedir
				echo $PATH
				PATH=$PATH:$LDIR/rclonedir
				echo $PATH
			else
				echo -e "\\n"
			fi
		fi
	fi
	echo -e "=== Test Rclone ==="
	rclone
	
}

_RcloneDw_(){
	echo -e ".- Contenido de RepoLin antes de descargar \\n"
	ls -lha RepoLin
	if [ -f RepoLin/$1 ];
		then
			echo -e "\\n Existe RepoLin/$1 no descargamos \\n"
		else
			echo -e "\\n No existe RepoLin/$1 descargamos \\n"
			#wget --append-output=$RRLOG http://82.223.78.14/publico/ks/rclone.conf
			wget --append-output=$RRLOG http://soporte.quiter.es/publico/ks/rclone.conf
			echo -e "Contenido de RepoLin en GoogleDrive\\n"
			$RRCMD lsl MyRemoteConfig:DirectDownload/RepoLin  
			$RRCMD tree MyRemoteConfig:DirectDownload/RepoLin 
			echo -e "Descargamos RepoLin/$1 ..."
			$RRCMD copy -P --drive-acknowledge-abuse MyRemoteConfig:DirectDownload/RepoLin/$1 $LDIR/RepoLin
			rm -vf $LDIR/rclone.conf
			echo -e "\\n.- Contenido de RepoLin despues de descargar \\n"
			ls -lha RepoLin	
	fi
}

_RepoLin1_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	RRLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_RepoLin_stdout.log"
	RRERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_RepoLin_stderr.log"
	RRCMD="rclone --config=$LDIR/rclone.conf"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Descargar de RepoLin lo necesario para Generar Qbase ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $RRLOG
	echo -e Standard Error.................: $RRERR
	echo -e Rclone command.................: $RRCMD \\n
	mkdir -p $DIRLOG
	_TstRclone 1>$RRLOG 2>$RRERR
	echo -e Descargando QuiterSetup ...\\n
	_RcloneDw_ QuiterSetup.zip  1>>$RRLOG 2>>$RRERR
	echo -e Descargando setup.properties ...\\n
	_RcloneDw_ setup.properties 1>>$RRLOG 2>>$RRERR
	ls -lha RepoLin
	du -hs RepoLin
	date
	echo -e "\\n==== Completada descarga ==== \\n"
}

_RepoLin2_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	RRLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_RepoLin_stdout.log"
	RRERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_RepoLin_stderr.log"
	RRCMD="rclone --config=$LDIR/rclone.conf"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Descargar de RepoLin lo necesario para desplegar instancia X ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $RRLOG
	echo -e Standard Error.................: $RRERR
	echo -e Rclone command.................: $RRCMD \\n
	mkdir -p $DIRLOG
	if [ -d $LDIR/RepoLin ];
		then
			echo -e "Existe $LDIR/RepoLin no descargamos     \\n"
		else
			echo -e "No Existe $LDIR/RepoLin descargamos     \\n"
			_TstRclone                                         1>$RRLOG 2>$RRERR
			echo -e "Descargando QDBLiveLx                   \\n"   
			_RcloneDw_ QDBLiveLx.tar.gz                        1>>$RRLOG 2>>$RRERR
			echo -e "Descargando setup_plataforma.properties \\n"   
			_RcloneDw_ setup_plataforma.properties             1>>$RRLOG 2>>$RRERR
			echo -e "Descargando CreaUsuario                 \\n"   
			_RcloneDw_ CreaUsuario                             1>>$RRLOG 2>>$RRERR
	fi
	ls -lha RepoLin
	du -hs RepoLin
	date
	echo -e "\\n==== Completada descarga ==== \\n"
}

_RepoLin3_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	RRLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_RepoLin_stdout.log"
	RRERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_RepoLin_stderr.log"
	RRCMD="rclone --config=$LDIR/rclone.conf"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Descargar de RepoLin lo necesario para instalar UniVerse ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $RRLOG
	echo -e Standard Error.................: $RRERR
	echo -e Rclone command.................: $RRCMD \\n
	mkdir -p $DIRLOG
	if [ -d $LDIR/RepoLin ];
		then
			echo -e "Existe $LDIR/RepoLin no descargamos \\n"
		else
			echo -e "No Existe $LDIR/RepoLin descargamos \\n"
			_TstRclone                                         1>$RRLOG 2>$RRERR
			echo -e "Descargando $universever            \\n"   
			_RcloneDw_ $universever                            1>>$RRLOG 2>>$RRERR
			echo -e "Descargando qibk.tar.gz             \\n"   
			_RcloneDw_ qibk.tar.gz                             1>>$RRLOG 2>>$RRERR
			echo -e "Descargando libs.zip                \\n"   
			_RcloneDw_ libs.zip                                1>>$RRLOG 2>>$RRERR
	fi
	echo -e "Contenido en $LDIR/RepoLin       \\n"
	ls -lha $LDIR/RepoLin
	du -hs RepoLin
	date
	echo -e "\\n==== Completada descarga ==== \\n"
}

_CP_Rsync_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	RSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_CPrsync_${sufijo}_stdout.log"
	RSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_CPrsync_${sufijo}_stderr.log"
	RSCMD="/usr/bin/rsync -ahv --delete --stats --progress $rootuser@$DMSold:$QPATH/CUENTA ."
	#RSCMD="/usr/bin/rsync -ahv --delete --stats --progress --exclude=quiter/qjava root@$DMSold:$QPATH $LDIR"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Inicio Rsync Cuentas principales ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $RSLOG
	echo -e Standard Error.................: $RSERR
	echo -e Rsync command..................: $RSCMD
	echo -e Sufijo.........................: $sufijo
	echo -e Quiter Path....................: $QPATH \\n
	#recorrer las cuentas principales ejecutando RSCMD
	for i in "CONEXION" "BBADAPTER" "VISTA" "COMERCIAL" "CONTA5" "POSVENTA5" "GEN4GL"
	do
		set -- $i
		echo -e " Procesando $1 \\n"
		if [ -d $QPATH/$1 ];
			then
				cd $QPATH
				pwd
				pwd 1>>$RSLOG 2>>$RSERR
				RSCMD="/usr/bin/rsync -ahv --delete --stats --progress $rootuser@$DMSold:$QPATH/$1 ."
				echo -e $RSCMD 1>>$RSLOG 2>>$RSERR
				$RSCMD 1>>$RSLOG 2>>$RSERR
				echo -e 1>>$RSLOG 2>>$RSERR
				echo
			else
				echo -e " No existe $1 \\n"
		fi
	done
	cd $LDIR
	echo -e "\\n==== Completado Rsync Cuentas principales ==== \\n"
}

_Q_Proces_(){
	cd $LDIR
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QProcess_${sufijo}_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QProcess_${sufijo}_stderr.log"
	QCMD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Quiter$sufijoCmd.txt"
	echo -e $separador 
	mkdir -p $DIRLOG
	echo -e "==== [$1/$2] procesos PostPlataformado $sufijo ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR
	echo -e UniVerse Exe...................: $UVCMD
	echo -e UniVerse Commands..............: $QCMD
	echo -e Quiter.Path....................: $QPATH
	echo -e Sufijo.........................: $sufijo \\n
	# procesos en Quiter despues de plataformar
	# Qbase no incluye indices para FTORMPT
	# Detectado 07/2021 corregido 10/2021
	#echo -e "N"                                                                1>>$QCMD
	#echo -e "DATE"                                                             1>>$QCMD
	#echo -e "WHO"                                                              1>>$QCMD
	#echo -e "SH -c pwd"                                                        1>>$QCMD
	#echo -e "LIST.INDEX FTORMPT ALL"                                           1>>$QCMD
	#echo -e "DATE"                                                             1>>$QCMD
	#echo -e "SET.INDEX FTORMPT INFORM"                                         1>>$QCMD
	#echo -e "DATE"                                                             1>>$QCMD
	#echo -e "SET.INDEX FTORMPT TO NULL FORCE"                                  1>>$QCMD
	#echo -e "DATE"                                                             1>>$QCMD
	#echo -e "LIST.INDEX FTORMPT ALL"                                           1>>$QCMD
	#echo -e "DATE"                                                             1>>$QCMD
	#echo -e "CREATE.INDEX FTORMPT MATRICULA NUMERO REF.SEC F.ENTREGA NO.NULLS" 1>>$QCMD
	#echo -e "DATE"                                                             1>>$QCMD
	#echo -e "LIST.INDEX FTORMPT ALL"                                           1>>$QCMD
	#echo -e "DATE"                                                             1>>$QCMD
	#echo -e "BUILD.INDEX FTORMPT ALL"                                          1>>$QCMD
	#echo -e "DATE"                                                             1>>$QCMD
	#echo -e "LIST.INDEX FTORMPT ALL"                                           1>>$QCMD
	#echo -e "DATE"                                                             1>>$QCMD
	#
	#cd $QPATH/POSVENTA5
	#$UVCMD <$QCMD 1>>$UVLOG 2>>$UVERR
	#tail -n 11 $UVLOG
	#
	cd $LDIR
	echo -e "\\n==== Completado procesos PostPlataformado $sufijo ==== \\n"
}

######################## Funciones Cambio servidor

_Q_Rsync__(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	RSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QRsync_${sufijo}_stdout.log"
	RSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QRsync_${sufijo}_stderr.log"
	RSCMD="/usr/bin/rsync -ahv --delete --stats --progress $rootuser@$DMSold:$QPATH $LDIR"
	#RSCMD="/usr/bin/rsync -ahv --delete --stats --progress --exclude=quiter/qjava root@$DMSold:$QPATH $LDIR"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Start Rsync $QPATH ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $RSLOG
	echo -e Standard Error.................: $RSERR
	echo -e Rsync command..................: $RSCMD
	echo -e Sufijo.........................: $sufijo
	echo -e Quiter Path....................: $QPATH \\n
	echo -e $RSCMD 1>$RSLOG 2>$RSERR
	$RSCMD 1>>$RSLOG 2>>$RSERR
	cd $LDIR
	echo -e "\\n==== Completed rsync $QPATH ==== \\n"
}

_QaeRsync_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	RSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QaeRsync_stdout.log"
	RSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QaeRsync_stderr.log"
	RSCMD="/usr/bin/rsync -ahv --delete --stats --progress $rootuser@$QAEold:$QAEPATH $LDIR"
	oIFS="$IFS"
	IFS='/' tokens=( $QAEPATH )
	#echo ${tokens[2]} 
	RSDIR="$LDIR/${tokens[2]}"
	IFS="$oIFS"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Start Rsync $QAEPATH ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e RSDIR..........................: $RSDIR
	echo -e Standard Output................: $RSLOG
	echo -e Standard Error.................: $RSERR
	echo -e Rsync command..................: $RSCMD
	echo -e QAE Path.......................: $QAEPATH \\n
	echo -e $RSCMD 1>$RSLOG 2>$RSERR
	$RSCMD 1>>$RSLOG 2>>$RSERR
	du -hs $RSDIR
	cd $LDIR
	echo -e "\\n==== Completed rsync $QAEPATH ==== \\n"
}

_Mv_QR_Qu2(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	MVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Mover_QRsync_a_U2_stdout.log"
	MVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Mover_QRsync_a_U2_stderr.log"
	oIFS="$IFS"
	IFS='/' tokens=( $QPATH )
	#echo ${tokens[2]} 
	RSDIR="$LDIR/${tokens[2]}"
	IFS="$oIFS"
	U2DIR=$QPATH
	echo -e $separador
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Move QRsync a Qu2 ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e RSDIR..........................: $RSDIR
	echo -e U2DIR..........................: $U2DIR
	echo -e QuiterPath.....................: $QPATH
	echo -e Standard Output................: $MVLOG
	echo -e Standard Error.................: $MVERR
	ls -lha /u2 1>$MVLOG 2>$MVERR
	mv -v $RSDIR $U2DIR 1>>$MVLOG 2>>$MVERR
	ls -lha /u2 1>>$MVLOG 2>>$MVERR
	cd $LDIR
	echo -e "\\n==== Completed move QRsync a u2  ==== \\n"
}

_Mv_Qu2_QR(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	MVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Mover_U2_a_QRsync_stdout.log"
	MVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Mover_U2_a_QRsync_stderr.log"
	oIFS="$IFS"
	IFS='/' tokens=( $QPATH )
	#echo ${tokens[2]} 
	RSDIR="$LDIR/${tokens[2]}"
	IFS="$oIFS"
	U2DIR=$QPATH	
	echo -e $separador
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Move Qu2 a QRsync ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e RSDIR..........................: $RSDIR
	echo -e U2DIR..........................: $U2DIR
	echo -e QuiterPath.....................: $QPATH
	ls -lha /u2 1>$MVLOG 2>$MVERR
	mv -v $U2DIR $RSDIR 1>$MVLOG 2>$MVERR
	ls -lha /u2 1>$MVLOG 2>$MVERR
	cd $LDIR
	echo -e "\\n==== Completed move Qu2 a QRsync ==== \\n"
}

_Mv_RepoR_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	MVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Mover_RepoRsync_stdout.log"
	MVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Mover_RepoRsync_stderr.log"
	oIFS="$IFS"
	IFS='/' tokens=( $QAEPATH )
	#echo ${tokens[2]} 
	RSDIR="$LDIR/${tokens[2]}"
	IFS="$oIFS"
	REPODIR="/${tokens[1]}"
	echo -e $separador
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Move RepoQae ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e RSDIR..........................: $RSDIR
	echo -e REPODIR........................: $REPODIR
	echo -e Qae Path.......................: $QAEPATH
	echo -e Standard Output................: $MVLOG
	echo -e Standard Error.................: $MVERR
	echo -e "\\n Antes \\n"
	ls -lha $REPODIR
	ls -lha $REPODIR 1>$MVLOG 2>$MVERR
	mv -v $RSDIR $QAEPATH 1>>$MVLOG 2>>$MVERR
	ls -lha $REPODIR 1>>$MVLOG 2>>$MVERR
	echo -e "\\n Despues \\n"
	ls -lha $REPODIR
	cd $LDIR
	echo -e "\\n==== Completed move RepoQae ==== \\n"
}

_Cl_StPol_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	MYCMD="$QPATH/qjava/sys/mysql/bin/mysql"
	MYDUMP="$QPATH/qjava/sys/mysql/bin/mysqldump"
	EPLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Limpiar_Estadisticas_Pool_stdout.log"
	EPERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Limpiar_Estadisticas_Pool_stderr.log"
	EPSQL="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Limpiar_Estadisticas_Pool_sql.txt"
	EPSQL2="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Limpiar_Estadisticas_Pool_sql2.txt"
	echo -e $separador 
	mkdir -p $DIRLOG	
	cd $LDIR
	echo -e "==== [$1/$2] Limpiar estadisticas del pool ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $EPLOG
	echo -e Standard Error.................: $EPERR
		
	#cuando la tabla es ingobernable, copiamos una a cero y reparamos.
	#cp -fv /u2/quiter.plat/qjava/sys/mysql/data/quitergateway/estadisticas_pool.MYD /u2/quiter/qjava/sys/mysql/data/quitergateway/estadisticas_pool.MYD 1>$EPLOG 2>$EPERR
	#/etc/init.d/mysql.qjava start 1>>$EPLOG 2>>$EPERR
	#sleep 5
	#echo "repair table estadisticas_pool;" >> $EPSQL
	#$MYCMD -v -u quiter --password=100495 --database=quitergateway < $EPSQL 1>>$EPLOG 2>>$EPERR
	#sleep 5
	#/etc/init.d/mysql.qjava stop 1>>$EPLOG 2>>$EPERR
	#cd $LDIR
	
	/etc/init.d/mysql.qjava start 1>$EPLOG 2>$EPERR
	sleep 5
	echo "repair table estadisticas_pool;" >> $EPSQL
	echo "SELECT COUNT(*) FROM estadisticas_pool;" >>$EPSQL
	echo "DELETE FROM estadisticas_pool WHERE fecha < (\"$MAXDATE 00:00:00\");" >>$EPSQL
	echo "SELECT COUNT(*) FROM estadisticas_pool;" >>$EPSQL
	$MYCMD -v -u quiter --password=100495 --database=quitergateway < $EPSQL 1>>$EPLOG 2>>$EPERR
	$MYDUMP -u quiter --password=100495 quitergateway estadisticas_pool > $DIRLOG/estadisticas_pool_reducida.sql
	echo "TRUNCATE estadisticas_pool;" >$EPSQL2
	$MYCMD -v -u quiter --password=100495 --database=quitergateway < $EPSQL2 1>>$EPLOG 2>>$EPERR
	$MYCMD -u quiter --password=100495 quitergateway < $DIRLOG/estadisticas_pool_reducida.sql
	sleep 5
	/etc/init.d/mysql.qjava stop 1>>$EPLOG 2>>$EPERR
	cd $LDIR
	echo -e "\\n==== Completed Limpiar estadisticas pool ==== \\n"
}

_Cl_SuMen_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	MYCMD="$QPATH/qjava/sys/mysql/bin/mysql"
	MYDUMP="$QPATH/qjava/sys/mysql/bin/mysqldump"
	EPLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Limpiar_Sucesos_Mensajes_stdout.log"
	EPERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Limpiar_Sucesos_Mensajes_stderr.log"
	EPSQL="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Limpiar_Sucesos_Mensajes_sql.txt"
	EPSQL2="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Limpiar_Sucesos_Mensajes_sql2.txt"
	echo -e $separador 
	mkdir -p $DIRLOG	
	cd $LDIR
	echo -e "==== [$1/$2] Limpiar Sucesos Mensajes ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $EPLOG
	echo -e Standard Error.................: $EPERR

	#cuando la tabla es ingobernable, copiamos una a cero y reparamos.
	#cp -fv /u2/quiter.plat/qjava/sys/mysql/data/quitergateway/sucesos_mensajes.MYD /u2/quiter/qjava/sys/mysql/data/quitergateway/sucesos_mensajes.MYD 1>$EPLOG 2>$EPERR
	#/etc/init.d/mysql.qjava start 1>>$EPLOG 2>>$EPERR
	#sleep 5
	#echo "repair table sucesos_mensajes;" >> $EPSQL
	#$MYCMD -v -u quiter --password=100495 --database=quitergateway < $EPSQL 1>>$EPLOG 2>>$EPERR
	#sleep 5
	#/etc/init.d/mysql.qjava stop 1>>$EPLOG 2>>$EPERR
	#cd $LDIR
	
	#cuando la tabla es ingobernable, copiamos una a cero y reparamos.
	#cp -fv /u2/quiter.plat/qjava/sys/mysql/data/quitergateway/sucesos_parametros.MYD /u2/quiter/qjava/sys/mysql/data/quitergateway/sucesos_parametros.MYD 1>>$EPLOG 2>>$EPERR
	#/etc/init.d/mysql.qjava start 1>>$EPLOG 2>>$EPERR
	#sleep 5
	#echo "repair table sucesos_parametros;" >> $EPSQL
	#$MYCMD -v -u quiter --password=100495 --database=quitergateway < $EPSQL 1>>$EPLOG 2>>$EPERR
	#sleep 5
	#/etc/init.d/mysql.qjava stop 1>>$EPLOG 2>>$EPERR
	#cd $LDIR
	
	/etc/init.d/mysql.qjava start 1>$EPLOG 2>$EPERR
	sleep 5
	echo "repair table sucesos_mensajes;" >> $EPSQL
	echo "SELECT COUNT(*) FROM sucesos_mensajes;" >>$EPSQL
	echo "DELETE FROM sucesos_mensajes WHERE fecha < (\"$MAXDATE 00:00:00\");" >>$EPSQL
	echo "SELECT COUNT(*) FROM sucesos_mensajes;" >>$EPSQL
	$MYCMD -v -u quiter --password=100495 --database=quitergateway < $EPSQL 1>>$EPLOG 2>>$EPERR
	$MYDUMP -u quiter --password=100495 quitergateway sucesos_mensajes > $DIRLOG/sucesos_mensajes_reducida.sql
	echo "TRUNCATE sucesos_mensajes;" >$EPSQL2
	$MYCMD -v -u quiter --password=100495 --database=quitergateway < $EPSQL2 1>>$EPLOG 2>>$EPERR
	$MYCMD -u quiter --password=100495 quitergateway < $DIRLOG/sucesos_mensajes_reducida.sql
	sleep 5
	/etc/init.d/mysql.qjava stop 1>>$EPLOG 2>>$EPERR
	cd $LDIR
	echo -e "\\n==== Completed Limpiar sucesos mensajes ==== \\n"
}

_Cl_Qms___(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QMLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Limpiar_Qms_stdout.log"
	QMERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Limpiar_Qms_stderr.log"
	echo -e $separador
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Limpiar mensajes QMS ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QMLOG
	echo -e Standard Error.................: $QMERR
	ls -lrt $QPATH/DATOS/in 1>$QMLOG 2>$QMERR
	rm -vf $QPATH/DATOS/in/* 1>>$QMLOG 2>>$QMERR
	ls -lht $QPATH/DATOS/out 1>>$QMLOG 2>>$QMERR
	rm -vf $QPATH/DATOS/out/* 1>>$QMLOG 2>>$QMERR
	cd $LDIR
	echo -e "\\n==== Completed QMS ==== \\n"
}

_QD_pause_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	MYCMD="$QPATH/qjava/sys/mysql/bin/mysql"
	QDLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qdemonio_Pausadas_stdout.log"
	QDERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qdemonio_Pausadas_stderr.log"
	QDSQL="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qdemonio_Pausadas_SQL.txt"
	echo -e $separador
	mkdir -p $DIRLOG	
	cd $LDIR
	echo -e "==== [$1/$2] Start QDemonio pausadas ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QDLOG
	echo -e Standard Error.................: $QDERR
	/etc/init.d/mysql.qjava start 1>$QDLOG 2>$QDERR
	echo "SELECT * FROM eventos_cron_proyecto;" >$QDSQL
	# la tarea programada con id=1 habitualmente es VERIFCONTA
	#echo "DELETE FROM eventos_cron_proyecto WHERE ID>1;" >>$QDSQL
	#echo "SELECT * FROM eventos_cron_proyecto WHERE nombre LIKE 'VERIFCONTA';">>$QDSQL
	#echo "DELETE FROM eventos_cron_proyecto WHERE nombre NOT LIKE 'VERIFCONTA';" >>$QDSQL
	echo "UPDATE eventos_cron_proyecto SET estado=\"pausado\" WHERE estado LIKE \"%activo%\";" >>$QDSQL
	echo "SELECT * FROM eventos_cron_proyecto;">>$QDSQL
	$MYCMD -v -u quiter --password=100495 --database=qdemonio < $QDSQL 1>>$QDLOG 2>>$QDERR
	sleep 5
	/etc/init.d/mysql.qjava stop 1>>$QDLOG 2>>$QDERR
	cd $LDIR
	echo -e "\\n==== Completed QDemonio pausadas ==== \\n"
}

_Qbi_Vrfy_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	UVDIR="/usr/uv"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qbi_Verify_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qbi_Verify_stderr.log"
	UVCMD="/usr/uv/bin/uv"
	QCMD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qbi_Verify_Cmd.txt"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] QBI Verify ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR
	echo -e UniVerse Exe...................: $UVCMD
	echo -e UniVerse Commands..............: $QCMD
	echo -e UniVerse dir...................: $UVDIR
	#ejecutar procesos dentro de UniVerse
	cd $UVDIR
	echo -e "LIST UV_SCHEMA" 1>$QCMD 2>$QCMD
	echo -e "VERIFY.SQL SCHEMA $QPATH/POSVENTA5 FIX NOPAGE" 1>>$QCMD 2>>$QCMD
	echo -e "VERIFY.SQL SCHEMA $QPATH/CONTA5 FIX NOPAGE"    1>>$QCMD 2>>$QCMD
	echo -e "VERIFY.SQL SCHEMA $QPATH/COMERCIAL FIX NOPAGE" 1>>$QCMD 2>>$QCMD
	#este comando es peligroso
	#echo -e "VERIFY.SQL ALL FIX NOPAGE"                    1>>$QCMD 2>>$QCMD
	echo -e "LIST UV_SCHEMA"                                1>>$QCMD 2>>$QCMD
	echo -e "LIST UV_USERS"                                 1>>$QCMD 2>>$QCMD
	$UVCMD <$QCMD 1>>$UVLOG 2>>$UVERR
	cd $LDIR
	echo -e "\\n==== Completed QBI Verify ==== \\n"
}

_ImpMySql_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	MYCMD="/u2/quiter/qjava/sys/mysql/bin/mysql"
	IMLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Importar_MySql_stdout.log"
	IMERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Importar_MySql_stderr.log"
	MXSQL1="$LDIR/$DIRLOG/show_allowed_packet.sql"
	MXSQL2="$LDIR/$DIRLOG/set__allowed_packet.sql"
	MYFILE="$LDIR/_old_quiter/mysql_cliente.sql"
	echo -e $separador 
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] MySql Import ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $IMLOG
	echo -e Standard Error.................: $IMERR
	echo -e MySql File.....................: $MYFILE
	echo -e "\\ Iniciando MySql \\n"
	/etc/init.d/mysql.qjava start 1>$IMLOG 2>$IMERR
	echo -e "\\n Esperando finalice importacion $MYFILE"
	sleep 5
	# si nos aparece: ERROR 1153 (08S01) at line 2141: Got a packet bigger than 'max_allowed_packet' bytes
	# desactivamos la ejecucion de estos comandos sql para subir el parametro global max_allowed_packet a 512M
	#echo -e "SHOW VARIABLES LIKE 'max_allowed_packet';"        > $MXSQL1
	#echo -e "set global max_allowed_packet=1024 * 1024 * 512;" > $MXSQL2
	#$MYCMD -v -u quiter --password=100495 < $MXSQL1 1>>$IMLOG 2>>$IMERR
	#$MYCMD -v -u quiter --password=100495 < $MXSQL2 1>>$IMLOG 2>>$IMERR
	#$MYCMD -v -u quiter --password=100495 < $MXSQL1 1>>$IMLOG 2>>$IMERR
	#sleep 5
	$MYCMD -v -u quiter --password=100495 < $MYFILE 1>>$IMLOG 2>>$IMERR
	sleep 5
	echo -e "\\ Deteniendo MySql \\n"
	/etc/init.d/mysql.qjava stop 1>>$IMLOG 2>>$IMERR
	sleep 5
	cd $LDIR
	echo -e "==== Completed MySql Import ==== \\n"
}

_Qtr_plat_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QPLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Quiter_Plat_stdout.log"
	QPERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Quiter_Plat_stderr.log"
	RSCMD="/usr/bin/rsync -ahv --delete --stats --progress $LDIR/_old_quiter/quiter/* /u2/quiter.plat/"
	RSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QRsync_${sufijo}_stdout.log"
	RSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QRsync_${sufijo}_stderr.log"
	echo -e $separador
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Quiter Plat ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QPLOG
	echo -e Standard Error.................: $QPERR
	echo -e Rsync Output...................: $RSLOG
	echo -e Rsync Error....................: $RSERR
	echo -e Rsync command..................: $RSCMD
	echo -e Quiter Path....................: $QPATH \\n 
	#echo -e $RSCMD 1>$RSLOG 2>$RSERR
	#$RSCMD 1>>$RSLOG 2>>$RSERR
	#/usr/bin/cp -rpvf _old_quiter/quiter/QRS /u2/quiter.plat                                                                         1>>$QPLOG 2>>$QPERR
	#/usr/bin/cp -rpvf _old_quiter/quiter/qjava/cache /u2/quiter.plat/qjava                                                           1>>$QPLOG 2>>$QPERR
	#/usr/bin/cp -rpvf _old_quiter/quiter/qjava/conf /u2/quiter.plat/qjava                                                            1>>$QPLOG 2>>$QPERR
	#/usr/bin/cp -rpvf _old_quiter/quiter/qjava/apps/quitergateway/tomcat/webapps/ /u2/quiter.plat/qjava/apps/quitergateway/tomcat    1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/qjava $QPATH                    1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/QDBLiveLx $QPATH                1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/BBADAPTER $QPATH                1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/IMPFILE $QPATH                  1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/DATOS $QPATH                    1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/QRS $QPATH                      1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/Plantillas $QPATH               1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/quiter_web $QPATH               1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/bin $QPATH                      1>>$QPLOG 2>>$QPERR
	#rm -vf $QPATH/quiter_web 1>>$QPLOG 2>>$QPERR 
	#cp -rpv /u2/quiter.plat/quiter_web $QPATH 1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/bin $QPATH 1>>$QPLOG 2>>$QPERR
	#Pasamos el fichero de configuracion de QAE con la ip fijada en el Post-Plataformado
	#mv -vf $QPATH/qjava/conf/qae.json $QPATH/qjava/conf/qae.json.bak 1>>$QPLOG 2>>$QPERR
	#cp -pv $LDIR/new_QGW/qae.json $QPATH/qjava/conf/qae.json 1>>$QPLOG 2>>$QPERR
	#Pasamos el fichero de configuracion de QBIPremiumV2 con la pass de gateway
	#mv -vf $QPATH/QBIPremiumV2/configuration.xml $QPATH/QBIPremiumV2/configuration.xml.bak 1>>$QPLOG 2>>$QPERR
	#cp -pv $LDIR/new_QGW/configuration.xml $QPATH/QBIPremiumV2/configuration.xml 1>>$QPLOG 2>>$QPERR
	#Pasamos el fichero de configuracion de QGW con la pass fijada en el Post-Plataformado
	#mv -vf $QPATH/qjava/conf/quitergateway.properties $QPATH/qjava/conf/quitergateway.properties.BAK 1>>$QPLOG 2>>$QPERR
	#cp -pv $LDIR/new_QGW/quitergateway.properties $QPATH/qjava/conf/quitergateway.properties 1>>$QPLOG 2>>$QPERR
	#Cuando tenemos QDBLive mas actual en DmsNew que en DmsOld
	#mv -v $QPATH/QDBLiveLx $QPATH/QDBLiveLx.old 1>>$QPLOG 2>>$QPERR
	#cp -rpv /u2/quiter.plat/QDBLiveLx $QPATH    1>>$QPLOG 2>>$QPERR
	cd $LDIR
	echo -e "\\n==== Completed Quiter Plat ==== \\n"
}
		
_Old_User_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	SSHLOG1="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Ssh_Cmd_1_stdout.log"
	SSHERR1="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Ssh_Cmd_1_stderr.log"
	SSHCMD1="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Ssh_Cmd_1.txt"
	SSHLOG2="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Ssh_Cmd_2_stdout.log"
	SSHERR2="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Ssh_Cmd_2_stderr.log"
	SSHCMD2="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Ssh_Cmd_2.txt"
	RSNCLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Rsync_shadow.log"
	RSNCERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Rsync_shadow.err"
	UAOLD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Usuarios_Activos_DmsOld.txt"
	UQNEW="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Usuarios_Quiter__DmsNew.txt"
	UQDPS="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Usuarios_Quiter_2puntos.txt"
	PSOLD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Fichero__Shadow__DmsOld.txt"
	PSNEW="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Fichero__Shadow__DmsNew.txt"
	UANEW="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Usuarios_a_Crear_DmsNew.sh"
	UVCMD1="/u2/uv/bin/uv \"LIST DICT GRIDLST WITH @ID LIKE quiter..._1\""

	echo -e $separador
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Generar Script con los user/pass a dar de alta en DmsNew ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Quiter Path....................: $QPATH
	echo -e Sufijo.........................: $sufijo
	echo -e GQuiter........................: $gquiter
	echo -e Dms Old........................: $DMSold
	echo -e Usuario ssh a DmsOld...........: $rootuser
	
	echo -e \\n 1 - Ejecutamos Ssh+UvCmd1 para obtener QCOD.
	echo -e SshCmd1+UvCmd1 Standard Output.: $SSHLOG1
	echo -e SshCmd1+UvCmd1 Standard Error..: $SSHERR1
	echo -e UniVerse Cmd1..................: $UVCMD1
	echo -e "cd $QPATH/GEN4GL"                 >  $SSHCMD1
	#echo -e "/u2/uv/bin/uv \"DATE\""          >> $SSHCMD1
	echo -e $UVCMD1                            >> $SSHCMD1
	#echo -e "/u2/uv/bin/uv \"QSIS.RUN DATE\"" >> $SSHCMD1
	echo -e "exit"                             >> $SSHCMD1
	ssh $rootuser@$DMSold < $SSHCMD1 1>$SSHLOG1 2>$SSHERR1
	QCOD=`cat $SSHLOG1 |awk '/Usuario/ {print $1}'|awk -F'_' '{print $1}'`
	#QCOD=`cat $SSHLOG1 |awk '/digo/ {print $1}'|awk -F'_' '{print $1}'`
	#QCOD=`cat $SSHLOG1 |awk '/Nro/ {print $1}'|awk -F'_' '{print $1}'`
	#ssh -t -t root@10.0.1.60 < $SSHCMD 1>${SSHLOGt}_1 2>${SSHLOGt}_2
	#QCODt=`cat ${SSHLOG}_1 |awk '/Usuario/ {print $1}'|awk -F'_' '{print $1}'`
	echo -e QuiterCod......................: $QCOD 
	#UVCMD2="/u2/uv/bin/uv \"LIST GRIDLST ${QCOD}_1 ${QCOD}_3 BY ORDEN WITH USUARIO = $QCOD AND ${QCOD}_3 <> 1 NOPAGE COL.HDR.SUPP COUNT.SUP\""
	UVCMD2="/u2/uv/bin/uv \"LIST GRIDLST ${QCOD}_1 ${QCOD}_3 BY ORDEN WITH USUARIO = $QCOD NOPAGE COL.HDR.SUPP COUNT.SUP\""
	echo -e \\n 2 - Ejecutamos Ssh+UvCmd2 para obtener usuarios activos en DmsOld.
	echo -e SshCmd2+UvCmd2 Standard Output.: $SSHLOG2
	echo -e SshCmd2+UvCmd2 Standard Error..: $SSHERR2
	echo -e Usuarios activos en DmsOld.....: $UAOLD
	echo -e UniVerse Cmd2..................: $UVCMD2
	echo -e "cd $QPATH/GEN4GL"                 >  $SSHCMD2
	#echo -e "/u2/uv/bin/uv \"DATE\""          >> $SSHCMD2
	echo -e $UVCMD2                            >> $SSHCMD2
	#echo -e "/u2/uv/bin/uv \"QSIS.RUN DATE\"" >> $SSHCMD2
	echo -e "exit"                             >> $SSHCMD2
	ssh $rootuser@$DMSold < $SSHCMD2 1>$SSHLOG2 2>$SSHERR2
	cat $SSHLOG2 |awk -v pat="$QCOD" '$0 ~ pat {print $2}' > $UAOLD
	echo -e Usuarios activos en DmsOld.....: `wc $UAOLD|awk -F' ' '{print $1}'`
	#ssh -t -t root@10.0.1.60 < $SSHCMD 1>${SSHLOGt}_1 2>${SSHLOGt}_2
	#cat ${SSHLOGt}_1 |awk -v pat="$QCOD" '$0 ~ pat {print $2}' > Active_Users_t.txt

	echo -e \\n 3 - Quitamos de usuarios activos a quiter, gateway y qbi.
	echo -e Usuarios a crear en DmsNew.....: $UQNEW
	sed '/^quiter$/d' $UAOLD > $UQNEW
	sed -i '/^gateway$/d' $UQNEW
	sed -i '/^qbi$/d' $UQNEW
	# Eliminamos lineas en blanco
	sed -i '/^$/d' $UQNEW
	echo -e Usuarios a crear en DmsNew.....: `wc $UQNEW|awk -F' ' '{print $1}'`
	# Agregamos dospuntos en la lista
	awk '{print $1":"}' $UQNEW > $UQDPS
	
	echo -e \\n 4 - Traemos de DmsOld el fichero shadow con las password.
	echo -e Archivo password en DmsOld.....: $PSOLD
	/usr/bin/rsync -ahv --delete --stats --progress $rootuser@$DMSold:/etc/shadow $PSOLD 1>$RSNCLOG 2>$RSNCERR
		
	echo -e \\n 5 - Buscamos en el fichero shadowd de DmsOld los password-hash de los usuarios a dar de alta en DmsNew.
	echo -e Archivo password en DmsNew.....: $PSNEW
	echo -e Componiendo fichero de password para DmsNew, por favor espere...
	cat $UQDPS | tee - |egrep -w -f - $PSOLD > $PSNEW
	echo -e Password a crear en DmsNew.....: `wc $PSNEW|awk -F' ' '{print $1}'`
		
	echo -e \\n 6 - Componemos script con los usuarios y password a dar de alta en DmsNew.
	echo -e User/Pass a crear en DmsNew....: $UANEW

	# Probar para instancia-X
	#cat $PSNEW|awk -F':' '{print "useradd -p '\''"$2"'\'' -g quiter -d /u2/usuarios/dsgenerico " $1}'> $UANEW
	cat $PSNEW|awk -F':' '{print "useradd -p '\''"$2"'\'' -g " "'"$gquiter"'" " -d /u2/usuarios/dsgenerico" "'"$sufijo "'" $1 }'> $UANEW
	
	echo -e User/Pass a crear en DmsNew....: `wc $UANEW|awk -F' ' '{print $1}'`
	
	cd $LDIR
	echo -e "\\n==== Finalizado generar Script con los user/pass a dar de alta en DmsNew ==== \\n"

	# Exportar todos los usuarios activos y desactivados
	#UVCMD="/u2/uv/bin/uv \"LIST GRIDLST ${QCOD}_1 ${QCOD}_3 BY ORDEN WITH USUARIO = $QCOD NOPAGE COL.HDR.SUPP COUNT.SUP\""
	#echo -e "cd /u2/quiter/GEN4GL"             >  $SSHCMD
	#echo -e "/u2/uv/bin/uv \"DATE\""          >> $SSHCMD
	#echo -e $UVCMD                             >> $SSHCMD
	#echo -e "/u2/uv/bin/uv \"QSIS.RUN DATE\"" >> $SSHCMD
	#echo -e "exit"                             >> $SSHCMD
	#ssh root@10.0.1.60 < $SSHCMD 1>${SSHLOG1}_1 2>${SSHLOG1}_2
	
}

_Old_Cfg__(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	CPLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Personalizar_stdout.log"
	CPERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Personalizar_stderr.log"
	UVRPC1="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UniVerse_Rpc"
	UVRPC2="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UniVerse_Rpc"
	SMBCFG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Samba_Config"
	HSTCFG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Hosts_Config"
	CRONQ="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Cron__Quiter"
	CRONR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Cron__Root"
	RSCMD="/usr/bin/rsync -ahv --delete --stats --progress $rootuser@$DMSold"
	echo -e $separador
	mkdir -p $DIRLOG
	cd $LDIR
	echo -e "==== [$1/$2] Personalizar ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $CPLOG
	echo -e Standard Error.................: $CPERR
	echo -e Quiter Path....................: $QPATH
	echo -e Dms Old........................: $DMSold \\n	

	echo -e Recuperando configuracion del sistema de $DMSold \\n
	#$RSCMD:/u2/usuarios $LDIR/$DIRLOG                 1>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.usuarios.log  2>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.usuarios.err 
	$RSCMD:/etc $LDIR/$DIRLOG                         1>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.etc.log       2>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.etc.err 
	$RSCMD:/var/spool/cron $LDIR/$DIRLOG              1>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.cron.log      2>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.cron.err 
	#$RSCMD:/u2/instalacionquiterautoweb $LDIR/$DIRLOG 1>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.insqaweb.log  2>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.insqaweb.err 
	$RSCMD:/u2/InstalacionQuiterAutoWeb $LDIR/$DIRLOG 1>>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.insqaweb.log 2>>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.insqaweb.err 
	#$RSCMD:/InstalacionQuiterAutoWeb    $LDIR/$DIRLOG 1>>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.insqaweb.log 2>>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.insqaweb.err 
	$RSCMD:/var/www/html $LDIR/$DIRLOG                1>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.www.log       2>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.www.err 
	$RSCMD:/srv/www/htdocs $LDIR/$DIRLOG              1>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.www.log       2>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.www.err 
	$RSCMD:/usr/ibm $LDIR/$DIRLOG                     1>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.ibm.log       2>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.ibm.err 
	$RSCMD:/usr/uv $LDIR/$DIRLOG                      1>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.uv.log        2>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.uv.err 
	$RSCMD:/usr/unishared $LDIR/$DIRLOG               1>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.unishared.log 2>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.unishared.err 
	$RSCMD:/home $LDIR/$DIRLOG                        1>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.home.log      2>$LDIR/$DIRLOG/$(date +\%u)_$(date +\%T)_rsync.home.err 
	
	echo -e Recuperando configuracion de los ficheros habituales a tener en cuenta \\n
	$RSCMD:/usr/unishared/unirpc/unirpcservices $UVRPC1     1>$CPLOG 2>$CPERR
	$RSCMD:/usr/ibm/unishared/unirpc/unirpcservices $UVRPC2 1>>$CPLOG 2>>$CPERR
	$RSCMD:/etc/samba/smb.conf $SMBCFG                      1>>$CPLOG 2>>$CPERR
	$RSCMD:/etc/hosts $HSTCFG                               1>>$CPLOG 2>>$CPERR
	$RSCMD:/var/spool/cron/quiter $CRONQ                    1>>$CPLOG 2>>$CPERR
	$RSCMD:/var/spool/cron/root $CRONR                      1>>$CPLOG 2>>$CPERR

	cd $LDIR
	echo -e "\\n==== Finalizado Personalizar ==== \\n"
}

_Qgw_Dump_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	MYDUMP="$QPATH/qjava/sys/mysql/bin/mysqldump -u quiter --password=100495 --all-databases"
	DMPFIL="mysql_cliente.sql"
	ZIPFIL="$LDIR/RepoLin/${HOST}_qjava_qrs_quiterweb_mysql.zip"
	ZIPLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Zip_stdout.txt"
	ZIPERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Zip_stderr.txt"
	SRCFIX="${DMPFIL} /quiter/qjava/conf /quiter/qjava/cache /quiter/qjava/apps/quitergateway/tomcat/conf /quiter/qjava/apps/quitergateway/tomcat/webapps /quiter/QRS /quiter/DATOS/in /quiter/DATOS/out /quiter/DATOS/ppgin /quiter/DATOS/ppgout /quiter/quiter_web"
	SOURCE="${SRCFIX} /quiter/Plantillas /quiter/qjava/apps/DMSExtract"
	echo -e $separador 
	mkdir -p $DIRLOG	
	cd $LDIR
	echo -e "==== [$1/$2] Exportar QGW ===="
	echo -e Date.................: `date`
	echo -e Run dir..............: `pwd`
	echo -e File Mysql...........: $DMPFIL
	echo -e File Zip.............: $ZIPFIL
	echo -e Zip standar output...: $ZIPLOG
	echo -e Zip standar error....: $ZIPERR \\n
	cd $DIRLOG
	echo -e Exportando Mysql ... \\n
	$MYDUMP >$DMPFIL
	echo -e Mysql exportado\\n
	echo -e Empaquetamos Qgw exportado en RepoLin\\n
	zip -rv $ZIPFIL $SOURCE 1>$ZIPLOG 2>$ZIPERR
	echo -e Qgw exportado \\n
	cd $LDIR
	echo -e "\\n==== Completado Exportar QGW ==== \\n"
}

######################## Funciones PostPlataformado

_RepoDMS__(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	RRLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_RepoLin_stdout.log"
	RRERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_RepoLin_stderr.log"
	RRCMD="rclone --config=$LDIR/rclone.conf"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Descargar RepoLin ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $RRLOG
	echo -e Standard Error.................: $RRERR
	echo -e Rclone command.................: $RRCMD \\n
	mkdir -p $DIRLOG
	if [ -d $LDIR/RepoLin ];
		then
			echo -e "Existe $LDIR/RepoLin no descargamos \\n"
			echo -e "Contenido en $LDIR/RepoLin          \\n"
			ls -lha $LDIR/RepoLin
		else
			echo -e "No Existe $LDIR/RepoLin descargamos  \\n"
			yum install -y rclone 1>$RRLOG 2>$RRERR
			#wget --append-output=$RRLOG http://82.223.78.14/publico/ks/rclone.conf
			wget --append-output=$RRLOG http://soporte.quiter.es/publico/ks/rclone.conf
			echo -e $RRCMD 1>>$RRLOG 2>>$RRERR
			$RRCMD lsl MyRemoteConfig:DirectDownload/RepoLin 1>>$RRLOG 2>>$RRERR
			$RRCMD tree MyRemoteConfig:DirectDownload/RepoLin 1>>$RRLOG 2>>$RRERR
			echo -e Descargando RepoLin...\\n
			$RRCMD copy -P --drive-acknowledge-abuse MyRemoteConfig:DirectDownload/RepoLin $LDIR/RepoLin 1>>$RRLOG 2>>$RRERR
			rm -vf $LDIR/rclone.conf 1>>$RRLOG 2>>$RRERR
	fi
	du -hs RepoLin
	date
	echo -e "\\n==== Completada descarga RepoLin ==== \\n"
}

_RepoQAE__(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	RRLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_RepoQae_stdout.log"
	RRERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_RepoQae_stderr.log"
	RRCMD="rclone --config=$LDIR/rclone.conf"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Descargar RepoQae ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $RRLOG
	echo -e Standard Error.................: $RRERR
	echo -e Rclone command.................: $RRCMD \\n
	mkdir -p $DIRLOG
	yum install -y rclone 1>$RRLOG 2>$RRERR
	#wget --append-output=$RRLOG http://82.223.78.14/publico/ks/rclone.conf
	wget --append-output=$RRLOG http://soporte.quiter.es/publico/ks/rclone.conf
	echo -e $RRCMD 1>>$RRLOG 2>>$RRERR
	$RRCMD lsl MyRemoteConfig:DirectDownload/RepoQAE 1>>$RRLOG 2>>$RRERR
	$RRCMD tree MyRemoteConfig:DirectDownload/RepoQAE 1>>$RRLOG 2>>$RRERR
	echo -e Descargando RepoQAE...\\n
	$RRCMD copy -P --drive-acknowledge-abuse MyRemoteConfig:DirectDownload/RepoQAE $LDIR/RepoQAE 1>>$RRLOG 2>>$RRERR
	rm -vf $LDIR/rclone.conf 1>>$RRLOG 2>>$RRERR
	du -hs RepoQAE
	date
	echo -e "\\n==== Completada descarga RepoQae ==== \\n"
}

_Q_Users__(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	USRLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QuiterUsers_stdout.log"
	USRERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QuiterUsers_stderr.log"
	echo -e $separador
	cd $LDIR
	echo -e "==== [$1/$2] Crear usuarios quiter, ftpq, gateway, qbi_user ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $USRLOG
	echo -e Standard Error.................: $USRERR \\n
	mkdir -p $DIRLOG
	
	if id -u conversion &>/dev/null; then
		echo 'existe usuario conversion' 1>>$USRLOG 2>>$USRERR
		userdel -r convesion 1>>$USRLOG 2>>$USRERR
		groupdel conversion 1>>$USRLOG 2>>$USRERR
	else
		echo 'no existe usuario conversion' 1>>$USRLOG 2>>$USRERR
	fi
	
	if id -u quiter &>/dev/null; then
		echo 'existe usuario quiter' 1>>$USRLOG 2>>$USRERR
		echo $quiterpass | passwd quiter --stdin 1>>$USRLOG 2>>$USRERR
	else
		echo 'no existe usuario quiter' 1>>$USRLOG 2>>$USRERR
		useradd -d /u2/usuarios/quiter quiter 1>>$USRLOG 2>>$USRERR
		echo $quiterpass | passwd quiter --stdin 1>>$USRLOG 2>>$USRERR
	fi
	
	if id -u gateway &>/dev/null; then
		echo 'existe usuario gateway' 1>>$USRLOG 2>>$USRERR
		echo $gatewaypass | passwd gateway --stdin 1>>$USRLOG 2>>$USRERR
	else
		echo 'no existe usuario gateway' 1>>$USRLOG 2>>$USRERR
		useradd -d /u2/usuarios/gateway -g quiter gateway 1>>$USRLOG 2>>$USRERR
		echo $gatewaypass | passwd gateway --stdin 1>>$USRLOG 2>>$USRERR
	fi

	if id -u ftpq &>/dev/null; then
		echo 'existe usuario ftpq' 1>>$USRLOG 2>>$USRERR
		echo $ftpqpass | passwd ftpq --stdin 1>>$USRLOG 2>>$USRERR
	else
		echo 'no existe usuario ftpq' 1>>$USRLOG 2>>$USRERR
		useradd -d /u2/usuarios/ftpq -g quiter ftpq 1>>$USRLOG 2>>$USRERR
		echo $ftpqpass | passwd ftpq --stdin 1>>$USRLOG 2>>$USRERR
	fi

	if id -u qbi_user &>/dev/null; then
		echo 'existe usuario qbi_user' 1>>$USRLOG 2>>$USRERR
		echo $qbiuserpass | passwd qbi_user --stdin 1>>$USRLOG 2>>$USRERR
	else
		echo 'no existe usuario qbi_user' 1>>$USRLOG 2>>$USRERR
		useradd -d /u2/usuarios/dsgenerico -g quiter qbi_user 1>>$USRLOG 2>>$USRERR
		echo $qbiuserpass | passwd qbi_user --stdin 1>>$USRLOG 2>>$USRERR
	fi
	
	rm -vrf /u2/usuarios/ 1>>$USRLOG 2>>$USRERR
	tar xvf $LDIR/RepoLin/usuarios.tar 1>>$USRLOG 2>>$USRERR
	mv usuarios /u2 1>>$USRLOG 2>>$USRERR
	rm -vrf /u2/usuarios/aquiter /u2/usuarios/conversion 1>>$USRLOG 2>>$USRERR
	ls -lha /u2/usuarios 1>>$USRLOG 2>>$USRERR
	tail /etc/passwd 1>>$USRLOG 2>>$USRERR
	tail /etc/passwd |grep usuarios
	echo -e "\\n==== Creados usuarios quiter, ftpq, gateway, qbi_user  ==== \\n"
}

_Dir_Cfg__(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	SSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_DirCfg_stdout.log"
	SSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_DirCfg_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Crear InstalacionQuiterAutoWeb, /u3, /qhome y /qdisco ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $SSLOG
	echo -e Standard Error.................: $SSERR \\n
	mkdir -p $DIRLOG
	if [ -d /u2/InstalacionQuiterAutoWeb  ]
		then
			echo -e "/u2/InstalacionQuiterAutoWeb existe \\n" 1>>$SSLOG 2>>$SSERR
		else
			echo -e "/u2/InstalacionQuiterAutoWeb no existe, creamos \\n" 1>>$SSLOG 2>>$SSERR
			mkdir -pv /u2/InstalacionQuiterAutoWeb 1>>$SSLOG 2>>$SSERR
	fi
	if [ -L /InstalacionQuiterAutoWeb  ]
		then
			echo -e "/InstalacionQuiterAutoWeb existe \\n" 1>>$SSLOG 2>>$SSERR
		else
			echo -e "/InstalacionQuiterAutoWeb no existe, creamos\\n" 1>>$SSLOG 2>>$SSERR
			ln -vs /u2/InstalacionQuiterAutoWeb /InstalacionQuiterAutoWeb 1>>$SSLOG 2>>$SSERR
	fi
	if [ -d /u3 ]
		then
			echo -e "/u3 existe \\n"
		else
			echo -e "/u3 no existe \\n"
			mkdir -v /u3 1>>$SSLOG 2>>$SSERR
	fi
	chown -vR quiter:quiter /u2/InstalacionQuiterAutoWeb 1>>$SSLOG 2>>$SSERR
	chmod -v 775 /u2/InstalacionQuiterAutoWeb 1>>$SSLOG 2>>$SSERR
	chmod -v 777 /u2 1>>$SSLOG 2>>$SSERR
	chmod -v 777 /u3 1>>$SSLOG 2>>$SSERR
	ls -la /u2 1>>$SSLOG 2>>$SSERR
	ls -la /u3 1>>$SSLOG 2>>$SSERR
	echo -e $QPATH > /.qhome
	echo /u2 > /.qdisco
	ls -lha / 1>>$SSLOG 2>>$SSERR
	echo -e "\\n==== Completada creacion InstalacionQuiterAutoWeb, /u3, /qhome y /qdisco ==== \\n"
}

_UV__Inst_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvInstall_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvInstall_stderr.log"
	QCMD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvCmd.txt"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Desplegar UniVerse ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e UniVerse Path..................: $UVDIR
	echo -e UniVerse Commands..............: $QCMD
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR \\n
	mkdir -p $DIRLOG 
	unzip -o RepoLin/$universever 1>$UVLOG 2>$UVERR
	cd universe*
	chmod -v 775 *.sh 1>>$UVLOG 2>>$UVERR
	./1-instalar.sh   1>>$UVLOG 2>>$UVERR
	./2-licenciar.sh  1>>$UVLOG 2>>$UVERR
	./3-configurar.sh 1>>$UVLOG 2>>$UVERR
	cp -v uv.*/uv.load.log $LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_uv.load.log 1>>$UVLOG 2>>$UVERR
	chmod -v a+rw /usr/uv/SYS.MESSAGE   1>>$UVLOG 2>>$UVERR
	chmod -v a+rw /usr/uv/UV.ACCESS     1>>$UVLOG 2>>$UVERR
	chmod -v a+rw /usr/uv/UV.ACCOUNT    1>>$UVLOG 2>>$UVERR
	chmod -v u+s /usr/uv/bin/list_readu 1>>$UVLOG 2>>$UVERR
	/bin/cp -vf /usr/uv/terminfo/w/wyse60 /usr/share/terminfo/w/wyse60 1>>$UVLOG 2>>$UVERR
	ls -la /usr/share/terminfo/w/wyse60* 1>>$UVLOG 2>>$UVERR
	cp -v $UVDIR/uvodbc.config $UVDIR/uvodbc.config.bak 1>>$UVLOG 2>>$UVERR
	echo "MAXFETCHBUFF = 2097152" >>$UVDIR/uvodbc.config
	cp -v /usr/unishared/unirpc/unirpcservices /usr/unishared/unirpc/unirpcservices.bak 1>>$UVLOG 2>>$UVERR
	echo "qbics /usr/uv/bin/uvapi_server * TCP/IP 0 28800" >>/usr/unishared/unirpc/unirpcservices
	cd $UVDIR
	echo "LIST UV_USERS NOPAGE"         > $QCMD
	# lo hacemos uno a uno porque todos juntos si algun usuario falta no entra ninguno
	echo "GRANT CONNECT TO rootquiter;" >>$QCMD
	echo "GRANT CONNECT TO aquiter;"    >>$QCMD
	echo "GRANT CONNECT TO quiter;"     >>$QCMD
	echo "GRANT CONNECT TO gateway;"    >>$QCMD
	echo "GRANT CONNECT TO qbi_user;"   >>$QCMD
	echo "GRANT DBA TO rootquiter;"     >>$QCMD
	echo "GRANT DBA TO aquiter;"        >>$QCMD
	echo "GRANT DBA TO quiter;"         >>$QCMD
	echo "GRANT DBA TO gateway;"        >>$QCMD
	echo "GRANT DBA TO qbi_user;"       >>$QCMD
	echo "LIST UV_USERS NOPAGE"         >>$QCMD
	$UVCMD <$QCMD 1>>$UVLOG 2>>$UVERR
	cd /usr/uv
	echo -e "UniVerse Info"
	bin/uvregen -z
	echo -e "UniVerse Build Number"
	bin/uv -buildno 2>&1
	oIFS="$IFS"
	IFS='/' tokens=( $QPATH )
	LINK=${tokens[1]}
	IFS="$oIFS"
	if [ -L /$LINK/uv  ]
		then
			echo -e "/u2/uv existe \\n"            1>>$UVLOG 2>>$UVERR
		else
			echo -e "/u2/uv no existe, creamos\\n" 1>>$UVLOG 2>>$UVERR
			ln -vs $UVDIR /$LINK/uv                1>>$UVLOG 2>>$UVERR
	fi
	cd $LDIR
	echo -e "\\n==== Completado despliegue UniVerse ==== \\n"
}

_UV__Upgr_(){
	
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvUpgrade_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvUpgrade_stderr.log"
	QCMD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UvCmd.txt"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] UniVerse Upgrade ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e UniVerse Path..................: $UVDIR
	echo -e UniVerse Commands..............: $QCMD
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR \\n
	mkdir -p $DIRLOG 
	unzip -o RepoLin/$universever 1>$UVLOG 2>$UVERR
	cd universe*
	chmod -v 775 *.sh 1>>$UVLOG 2>>$UVERR
	./1-instalar.sh   1>>$UVLOG 2>>$UVERR
	./2-licenciar.sh  1>>$UVLOG 2>>$UVERR
	./3-configurar.sh 1>>$UVLOG 2>>$UVERR
	cp -v uv.*/uv.load.log $LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_uv.load.log 1>>$UVLOG 2>>$UVERR
	chmod -v a+rw /usr/uv/SYS.MESSAGE   1>>$UVLOG 2>>$UVERR
	chmod -v a+rw /usr/uv/UV.ACCESS     1>>$UVLOG 2>>$UVERR
	chmod -v a+rw /usr/uv/UV.ACCOUNT    1>>$UVLOG 2>>$UVERR
	chmod -v u+s /usr/uv/bin/list_readu 1>>$UVLOG 2>>$UVERR
	#/bin/cp -vf /usr/uv/terminfo/w/wyse60 /usr/share/terminfo/w/wyse60 1>>$UVLOG 2>>$UVERR
	ls -la /usr/share/terminfo/w/wyse60* 1>>$UVLOG 2>>$UVERR
	#cp -v $UVDIR/uvodbc.config $UVDIR/uvodbc.config.bak 1>>$UVLOG 2>>$UVERR
	#echo "MAXFETCHBUFF = 2097152" >>$UVDIR/uvodbc.config
	#cp -v /usr/unishared/unirpc/unirpcservices /usr/unishared/unirpc/unirpcservices.bak 1>>$UVLOG 2>>$UVERR
	#echo "qbics /usr/uv/bin/uvapi_server * TCP/IP 0 28800" >>/usr/unishared/unirpc/unirpcservices
	cd $UVDIR
	echo "LIST UV_USERS NOPAGE"         > $QCMD
	# lo hacemos uno a uno porque todos juntos si algun usuario falta no entra ninguno
	#echo "GRANT CONNECT TO rootquiter;" >>$QCMD
	#echo "GRANT CONNECT TO aquiter;"    >>$QCMD
	#echo "GRANT CONNECT TO quiter;"     >>$QCMD
	#echo "GRANT CONNECT TO gateway;"    >>$QCMD
	#echo "GRANT CONNECT TO qbi_user;"   >>$QCMD
	#echo "GRANT DBA TO rootquiter;"     >>$QCMD
	#echo "GRANT DBA TO aquiter;"        >>$QCMD
	#echo "GRANT DBA TO quiter;"         >>$QCMD
	#echo "GRANT DBA TO gateway;"        >>$QCMD
	#echo "GRANT DBA TO qbi_user;"       >>$QCMD
	#echo "LIST UV_USERS NOPAGE"         >>$QCMD
	$UVCMD <$QCMD 1>>$UVLOG 2>>$UVERR
	cd /usr/uv
	echo -e "UniVerse Info"
	bin/uvregen -z
	echo -e "UniVerse Build Number"
	bin/uv -buildno 2>&1
	oIFS="$IFS"
	IFS='/' tokens=( $QPATH )
	LINK=${tokens[1]}
	IFS="$oIFS"
	if [ -L /$LINK/uv  ]
		then
			echo -e "/u2/uv existe \\n"            1>>$UVLOG 2>>$UVERR
		else
			echo -e "/u2/uv no existe, creamos\\n" 1>>$UVLOG 2>>$UVERR
			ln -vs $UVDIR /$LINK/uv                1>>$UVLOG 2>>$UVERR
	fi
	cd $LDIR
	echo -e "\\n==== Completado UniVerse Upgrade ==== \\n"
}

_QsCfgPlt_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QSetupConfig_stdout.log"
	QSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QSetupConfig_stderr.log"
	PATHTMP=$LDIR/quitersetup
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Configuracion QuiterSetup ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QSLOG
	echo -e Standard Error.................: $QSERR
	echo -e Sufijo para Plataformar........: $sufijo
	echo -e Quiter Path Plataformar........: $QPATH
	echo -e GQuiter........................: $gquiter
	echo -e QuiterSetup PathTmp............: $PATHTMP
	mkdir -p $DIRLOG
	case $3 in
		_Pst_Platform_DMS)
			echo -e User para Plataformar..........: $rootuser
			echo -e Pass para Plataformar..........: $rootpassword \\n
			echo -e Desplegamos RepoLin/Quitersetup.zip \\n
			unzip -o RepoLin/QuiterSetup.zip 1>$QSLOG 2>$QSERR
			;;
		_Desplegar__InstX)
			#plataformar con $gquiter y $quiterpass en lugar de $rootuser y $rootpassword
			#De esta forma podemos encadenar GeneracionQbase y Despliegue instanciaX
			rootuser=${gquiter}
			rootpassword=${quiterpass}
			echo -e User para Plataformar..........: $rootuser
			echo -e Pass para Plataformar..........: $rootpassword \\n
			echo -e Desplegamos RepoLin/${HOST}_Quitersetup.zip \\n
			unzip -o RepoLin/${HOST}_QuiterSetup.zip 1>$QSLOG 2>$QSERR
			;;
		*)
			unzip -o RepoLin/QuiterSetup.zip 1>$QSLOG 2>$QSERR
			;;
	esac	
	dos2unix quitersetup/conf/* 1>>$QSLOG 2>>$QSERR
	dos2unix quitersetup/bin/* 1>>$QSLOG 2>>$QSERR
	# Configuramos setup_plataforma.properties para desplegar instancia quiterSUFIJO
	mv -vf $LDIR/quitersetup/conf/setup_plataforma.properties $LDIR/quitersetup/conf/setup_plataforma.properties.bak 1>>$QSLOG 2>>$QSERR
	sed "s/ROOTPASS/$rootpassword/g " $LDIR/RepoLin/setup_plataforma.properties       > $LDIR/RepoLin/setup_plataforma.properties.mod
	sed "s/SUFIJO/$sufijo/g "         $LDIR/RepoLin/setup_plataforma.properties.mod   > $LDIR/RepoLin/setup_plataforma.properties.mod.1
	sed "s/ROOTUSER/$rootuser/g "     $LDIR/RepoLin/setup_plataforma.properties.mod.1 > $LDIR/RepoLin/setup_plataforma.properties.mod
	sed "s@PATHTMP@$PATHTMP@g "       $LDIR/RepoLin/setup_plataforma.properties.mod   > $LDIR/RepoLin/setup_plataforma.properties.mod.1
	sed "s@QUITERPATH@$QPATH@g "      $LDIR/RepoLin/setup_plataforma.properties.mod.1 > $LDIR/RepoLin/setup_plataforma.properties.mod
	cat $LDIR/RepoLin/setup_plataforma.properties.mod >>$QSLOG 
	cp -vf $LDIR/RepoLin/setup_plataforma.properties.mod $LDIR/quitersetup/conf/setup_plataforma.properties 1>>$QSLOG 2>>$QSERR
	ls -la $LDIR/quitersetup/conf/setup_plataforma.properties* 1>>$QSLOG 2>>$QSERR
	cat $LDIR/quitersetup/conf/setup_plataforma.properties
	chmod -vR 777 quitersetup 1>>$QSLOG 2>>$QSERR
	echo -e "\\n==== Completada configuracion QuiterSetup ==== \\n"
}

_QsExePlt_(){
	echo -e $separador 
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}/${LOGDATE}_${LOGTIME}/"
	QSLOG="$LDIR/$DIRLOG/QSetupExe_stdout.log"
	QSERR="$LDIR/$DIRLOG/QSetupExe_stderr.log"
	mkdir -p $LDIR/$DIRLOG
	echo -e "==== [$1/$2] Ejecutar QuiterSetup $sufijo ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QSLOG
	echo -e Standard Error.................: $QSERR
	echo -e Sufijo para Plataformar........: $sufijo
	echo -e Quiter Path Plataformar........: $QPATH
	echo -e GQuiter........................: $gquiter \\n
	#ln -vs $LDIR/quitersetup/logs $LDIR/$DIRLOG
	#../jvm/jrelx/bin/java -server -Dfile.encoding=ISO-8859-15 -classpath ../lib/commons-compress-1.5.jar:../lib/commons-io-2.4.jar:../lib/asjava.zip:../lib/asjava_p.zip:../lib/ibmjsse.jar:../lib/QuiterSetup.jar:../lib/mail.jar:../lib/activation.jar:../lib/QSDSCoreV2.jar com.quiter.qsd.ver2.plataformado.Plataformar
	#sh plataformar.sh
	#su $gquiter -c "sh plataformar.sh"
	cd $LDIR/quitersetup/bin
	#mkdir -p $QPATH
	#chmod 777 $QPATH
	echo -e Esperando QuiterSetup finalice... 
	su $rootuser -c "sh plataformar.sh"
	echo -e Finalizado QuiterSetup
	cp -pv $LDIR/quitersetup/logs/* $LDIR/$DIRLOG 1>$QSLOG 2>$QSERR
	#mv $LDIR/quitersetup/logs $LDIR/quitersetup/$3_logs
	#rm -f $LDIR/$DIRLOG
	#ln -vs $LDIR/quitersetup/$3_logs $LDIR/$DIRLOG
	oIFS="$IFS"
	IFS='/' tokens=( $QPATH )
	LINK=${tokens[2]}
	IFS="$oIFS"
	if [ -L /$LINK ]
		then
			echo -e "/$LINK existe \\n" 
		else
			echo -e "/$LINK no existe, creamos" 
			ln -vs $QPATH /$LINK
	fi
	ls -lha $QPATH
	date
	echo -e "\\n==== Completada ejecucion QuiterSetup ==== \\n"
}

_Q_Webpag_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QWLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Quiter_Web_stdout.log"
	QWERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Quiter_Web_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Desplegar paginas_web ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Web pages......................: paginas-$PAIS.zip
	echo -e Standard Output................: $QWLOG
	echo -e Standard Error.................: $QWERR \\n
	mkdir -p $DIRLOG 
	mkdir -pv $QPATH/quiter_web 1>$QWLOG 2>$QWERR
	unzip -o paginas-$PAIS.zip -d $QPATH/quiter_web 1>>$QWLOG 2>>$QWERR
	ln -vs /u2/InstalacionQuiterAutoWeb $QPATH/quiter_web/download 1>>$QWLOG 2>>$QWERR
	ln -vs /u2/InstalacionQuiterAutoWeb $QPATH/quiter_web/descargas 1>>$QWLOG 2>>$QWERR
	du -hs $QPATH/quiter_web
	echo -e "\\n==== Completado despliegue paginas_web ==== \\n"
}

_QGW_Inst_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QGWLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QGW_stdout.log"
	QGWERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QGW_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Desplegar QuiterGateway ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QGWLOG
	echo -e Standard Error.................: $QGWERR
	echo -e Quiter Path....................: $QPATH \\n
	mkdir -p $DIRLOG 
	tar xvfz RepoLin/PaqueteQJavaLinux_64.tar.gz 1>$QGWLOG 2>$QGWERR
	mv qjava $QPATH/qjava 1>>$QGWLOG 2>>$QGWERR
	if [ -f /etc/my.cnf ];
		then
			echo "Existe /etc/my.cnf, apartamos" 1>>$QGWLOG 2>>$QGWERR
			mv -v /etc/my.cnf /etc/my.cnf.NO.ACTIVAR 1>>$QGWLOG 2>>$QGWERR
		else
			echo "No-existe /etc/my.cnf" 1>>$QGWLOG 2>>$QGWERR
	fi
	cd $QPATH/qjava/temp
	echo suse > suse.txt
	sh instalarQGWNuevo.sh < suse.txt 1>>$QGWLOG 2>>$QGWERR
	cd $LDIR
	sleep 60
	echo -e "==== esperando 60seg a que termine QuiterGateway de desplegar ===="
	/etc/init.d/quitergateway.service stop 1>>$QGWLOG 2>>$QGWERR
	echo -e "==== esperando 10seg a detener QuiterGateway ===="
	sleep 10

	# Agregamos *.war que tenemos en RepoLin
	echo -e "==== Agregando *.war disponibles en RepoLin ===="
	cp -vf RepoLin/*.war $QPATH/qjava/apps/quitergateway/tomcat/webapps 1>>$QGWLOG 2>>$QGWERR
	
	# Configurar quitergateway.properties
	cp -v $QPATH/qjava/conf/quitergateway.properties $QPATH/qjava/conf/quitergateway.properties.bak 1>>$QGWLOG 2>>$QGWERR
	cp -v $QPATH/qjava/conf/quitergateway.properties $LDIR/$DIRLOG/quitergateway.properties.bak 1>>$QGWLOG 2>>$QGWERR
	sed "s/version_objetos_universe=10.2/version_objetos_universe=$QGWLIBnew/g " $LDIR/$DIRLOG/quitergateway.properties.bak > $LDIR/$DIRLOG/quitergateway.properties.mod.1
	sed "s/password_universe=gateway/password_universe=$gatewaypass/g " $LDIR/$DIRLOG/quitergateway.properties.mod.1 > $LDIR/$DIRLOG/quitergateway.properties.mod.2
	echo -e "dias_limite_estadisticas_pool=20" >> $LDIR/$DIRLOG/quitergateway.properties.mod.2
	echo -e "usuario_administrador=$rootuser" >> $LDIR/$DIRLOG/quitergateway.properties.mod.2
	cp -vf $LDIR/$DIRLOG/quitergateway.properties.mod.2 $QPATH/qjava/conf/quitergateway.properties 1>>$QGWLOG 2>>$QGWERR
	ls -la $QPATH/qjava/conf/quitergateway.properties* 1>>$QGWLOG 2>>$QGWERR
	
	# Configurar setenv.sh
	mv -v $QPATH/qjava/apps/quitergateway/tomcat/bin/setenv.sh $QPATH/qjava/apps/quitergateway/tomcat/bin/setenv.sh.bak 1>>$QGWLOG 2>>$QGWERR
	echo $QGWENV > $QPATH/qjava/apps/quitergateway/tomcat/bin/setenv.sh
	chmod -v 777 $QPATH/qjava/apps/quitergateway/tomcat/bin/setenv.sh
	
	# Configurar catalina.sh
	mv -v $QPATH/qjava/apps/quitergateway/tomcat/bin/catalina.sh $QPATH/qjava/apps/quitergateway/tomcat/bin/catalina.sh.bak 1>>$QGWLOG 2>>$QGWERR
	LINEOPTS=`awk '/JAVA_OPTS=/{ print NR; exit }' $QPATH/qjava/apps/quitergateway/tomcat/bin/catalina.sh.bak` 1>>$QGWLOG 2>>$QGWERR
	sed "${LINEOPTS}s{.*{$QGWCAT{" $QPATH/qjava/apps/quitergateway/tomcat/bin/catalina.sh.bak > $QPATH/qjava/apps/quitergateway/tomcat/bin/catalina.sh
	chmod -v 777 $QPATH/qjava/apps/quitergateway/tomcat/bin/catalina.sh
	
	#/etc/init.d/quitergateway.service start 1>>$QGWLOG 2>>$QGWERR
	#echo -e "==== esperando 60seg a que termine de desplegar completo ===="
	#sleep 60
	cat $QPATH/qjava/apps/quitergateway/tomcat/bin/catalina.sh|grep Duser.country
	cat $QPATH/qjava/apps/quitergateway/tomcat/bin/setenv.sh
	echo -e "==== Completada configuracion QuiterGateway ==== \\n"
		
	# Configurar licencias de conectividad
	MYCMD="/u2/quiter/qjava/sys/mysql/bin/mysql"
	MYDUMP="/u2/quiter/qjava/sys/mysql/bin/mysqldump"
	MYLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_TablaLic_stdout.log"
	MYERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_TablaLic_stderr.log"
	MYSQL="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_MySqlCmd.txt"
	cd $LDIR
	echo -e "==== Configurar MySql ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $MYLOG
	echo -e Standard Error.................: $MYERR
	echo "SELECT * FROM quitergateway.licencias;" >>$MYSQL
	echo "INSERT INTO quitergateway.licencias (``aplicacion``, ``licencias``) VALUES ('Conectividad', '2');" >>$MYSQL
	echo "SELECT * FROM quitergateway.licencias;" >>$MYSQL
	$MYCMD -v -u quiter --password=100495 --database=quitergateway < $MYSQL 1>>$MYLOG 2>>$MYERR
	tail -n 1 $MYLOG
	echo -e "\\n==== MySql configurado ==== \\n"
	
	/etc/init.d/quitergateway.service start 1>>$QGWLOG 2>>$QGWERR
	echo -e "==== esperando 60seg a que QuiterGateway termine de desplegar completo ===="
	sleep 60

	# Configurar ip QAE
	_QGW_Qae__

	echo -e "\\n==== Completado despliegue QuiterGateway ==== \\n"
}

_Q_DBLive_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QDBLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QDBLive_stdout.log"
	QDBERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QDBLive_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Desplegar QDBLive ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QDBLOG
	echo -e Standard Error.................: $QDBERR
	echo -e Sufijo.........................: $sufijo
	echo -e Quiter Path....................: $QPATH
	echo -e GQuiter........................: $gquiter \\n
	mkdir -p $DIRLOG 
	tar xvfz RepoLin/QDBLiveLx.tar.gz -C $QPATH 1>$QDBLOG 2>$QDBERR
	case $3 in
		_Pst_Platform_DMS)
			if grep QDBLive /var/spool/cron/$gquiter 1>>$QDBLOG 2>>$QDBERR;
				then
					echo -e "/var/spool/cron/${gquiter} ya tiene tarea QDBLive activada \\n"
				else
					echo -e "/var/spool/cron/${gquiter} NO tiene tarea QDBLive, activamos \\n"
					sed "s{QPATH{$QPATH{g " $QPATH/QDBLiveLx/crontab.quiter >> /var/spool/cron/$gquiter
					chown -v $gquiter:$gquiter /var/spool/cron/$gquiter 1>>$QDBLOG 2>>$QDBERR
					chmod -v 644 /var/spool/cron/$gquiter 1>>$QDBLOG 2>>$QDBERR
					cat /var/spool/cron/$gquiter 1>>$QDBLOG 2>>$QDBERR
			fi
			;;
		_Desplegar__InstX)
			echo -e "No podemos activar para instancia-X misma programacion que en instancia generica \\n"
			echo -e "Si es necesaria programacion QDBLive en instancia-X, personalizar manualmente. \\n"
			;;
		*)
			echo -e "opcion no esperada \\n"
			;;
	esac	
	mv -v $QPATH/QDBLiveLx/u2dblivepy.conf $QPATH/QDBLiveLx/u2dblivepy.conf.bak 1>>$QDBLOG 2>>$QDBERR
	sed "s/QSISUSERDMS/$gquiter/g " $QPATH/QDBLiveLx/u2dblivepy.conf.bak > $QPATH/QDBLiveLx/u2dblivepy.conf
	sed "s/QSISPASSDMS/$quiterpass/g " $QPATH/QDBLiveLx/u2dblivepy.conf > $QPATH/QDBLiveLx/u2dblivepy.conf.mod
	sed "s{QSISPATH{$QPATH{g " $QPATH/QDBLiveLx/u2dblivepy.conf.mod > $QPATH/QDBLiveLx/u2dblivepy.conf
	mv -v $QPATH/QDBLiveLx/TaskQDBLiveLx.sh $QPATH/QDBLiveLx/TaskQDBLiveLx.mod 1>>$QDBLOG 2>>$QDBERR
	sed "s{QSISPATH{$QPATH{g " $QPATH/QDBLiveLx/TaskQDBLiveLx.mod > $QPATH/QDBLiveLx/TaskQDBLiveLx.sh
	du -hs $QPATH/QDBLiveLx
	if [ -f /var/spool/cron/$gquiter ];
		then
			cat /var/spool/cron/$gquiter
		else
			echo -e "\\n No existe /var/spool/cron/$gquiter\\n"
	fi
	cd $QPATH/QDBLiveLx
	pwd
	echo -e "sh QDBLiveLx.sh SMP -ac $QPATH/GEN4GL/ -f PARAMETROS"
	sh QDBLiveLx.sh SMP -ac $QPATH/GEN4GL/ -f PARAMETROS
	echo -e "\\n==== Completado despliegue QDBLive ==== \\n"
}

_Dir_Cfg2_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	SSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_DirCfg_stdout.log"
	SSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_DirCfg_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Crear directorios Post-QuiterSetup ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $SSLOG
	echo -e Standard Error.................: $SSERR
	echo -e Quiter Path....................: $QPATH \\n
	mkdir -p $DIRLOG 
	echo -e "==== BIN ===="                        1>$SSLOG 2>$SSERR
	mkdir -pv $QPATH/bin                           1>>$SSLOG 2>>$SSERR
	cp -v $LDIR/RepoLin/CreaUsuario $QPATH/bin     1>>$SSLOG 2>>$SSERR
	echo -e "==== QRS ===="                        1>>$SSLOG 2>>$SSERR
	mkdir -pv $QPATH/QRS/IMPRESOS $QPATH/QRS/LOGOS 1>>$SSLOG 2>>$SSERR
	echo -e "==== IMPFILE ===="                    1>>$SSLOG 2>>$SSERR
	mkdir -pv $QPATH/IMPFILE                       1>>$SSLOG 2>>$SSERR	
	echo -e "\\n==== Completada creacion directorios Post-QuiterSetup ==== \\n"
}

_Q_Rights_(){
	cd $LDIR
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	PSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Permisos_${sufijo}_stdout.log"
	PSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Permisos_${sufijo}_stderr.log"
	echo -e $separador 
	mkdir -p $DIRLOG
	echo -e "==== [$1/$2] Permisos $sufijo ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $PSLOG
	echo -e Standard Error.................: $PSERR
	echo -e Quiter Path....................: $QPATH
	echo -e Sufijo.........................: $sufijo
	echo -e GQuiter........................: $gquiter \\n
	chown -vR $gquiter:$gquiter $QPATH                       1>$PSLOG  2>$PSERR
	chown -vR $gquiter:$gquiter /u2/InstalacionQuiterAutoWeb 1>>$PSLOG 2>>$PSERR
	chmod -vR 775 $QPATH                                     1>>$PSLOG 2>>$PSERR
	chmod -vR 775 /u2/InstalacionQuiterAutoWeb               1>>$PSLOG 2>>$PSERR
	chmod -vR 777 $QPATH/quiter_web                          1>>$PSLOG 2>>$PSERR
	chmod -vR 777 $QPATH/POSVENTA5/COM*                      1>>$PSLOG 2>>$PSERR
	chmod -vR 777 $QPATH/CONTA5/COM*                         1>>$PSLOG 2>>$PSERR
	chmod -vR 777 $QPATH/COMERCIAL/COM*                      1>>$PSLOG 2>>$PSERR
	chmod -vR 777 $QPATH/GEN4GL/COM*                         1>>$PSLOG 2>>$PSERR
	ls -lhR $QPATH                                           1>>$PSLOG 2>>$PSERR
	ls -lh $QPATH
	echo -e "\\n==== Completado Permisos $sufijo ==== \\n"
}

_UpdAccnt_(){
	cd $LDIR
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	UALOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UpAccount_${sufijo}_stdout.log"
	UAERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_UpAccount_${sufijo}_stderr.log"
	echo -e $separador 
	mkdir -p $DIRLOG
	echo -e "==== [$1/$2] Update Account $sufijo ===="
	echo -e Date...........................: `date`		
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $UALOG
	echo -e Standard Error.................: $UAERR
	echo -e UniVerse command...............: $UVCMD
	echo -e Quiter Path....................: $QPATH
	echo -e Sufijo.........................: $sufijo
	echo -e GQuiter........................: $gquiter \\n
	#recorrer las cuentas UV ejecutando UV.ACCOUNT
	for i in "CONEXION" "BBADAPTER" "VISTA"
	do
		set -- $i
		echo -e " Procesando $1 \\n"
		if [ -d $QPATH/$1 ];
			then
				cd $QPATH/$1
				pwd
				pwd 1>>$UALOG 2>>$UAERR
				$UVCMD "UPDATE.ACCOUNT" 1>>$UALOG 2>>$UAERR
				$UVCMD "COPYI FROM &TEMP& TO VOC UP OVERWRITING" 1>>$UALOG 2>>$UAERR
				echo -e 1>>$UALOG 2>>$UAERR
				echo
			else
				echo -e " No existe $1 \\n"
		fi
	done
	#
	cd $LDIR
	echo -e "\\n==== Completado Update Account $sufijo ==== \\n"
}

_Q_Triger_(){
	cd $LDIR
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	GNDIR="$QPATH/GEN4GL"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Triggers_${sufijo}_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Triggers_${sufijo}_stderr.log"
	QCMD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Quiter$sufijoCmd.txt"
	echo -e $separador 
	mkdir -p $DIRLOG
	echo -e "==== [$1/$2] Desplegar Triggers $sufijo ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR
	echo -e UniVerse Exe...................: $UVCMD
	echo -e UniVerse Commands..............: $QCMD
	echo -e GEN4GL.Dir.....................: $GNDIR
	echo -e Quiter.Path....................: $QPATH
	echo -e Sufijo.........................: $sufijo \\n
	#ejecutar procesos dentro de Quiter$sufijo
	cd $GNDIR
	if [ $sufijo ]
	then
		echo -e "N"                                                   1>>$QCMD
		echo -e "QSIS.PREPBATCH $sufijo"                              1>>$QCMD
		echo -e "QSIS.RUN.SUFIJO $sufijo DATE"                        1>>$QCMD
		echo -e "QSIS.RUN.SUFIJO $sufijo WHO"                         1>>$QCMD
		echo -e "QSIS.RUN.SUFIJO $sufijo SH -c pwd"                   1>>$QCMD
		#Solo puede estar catalogado globalemente el trigger de la instancia generica
		#echo -e "QSIS.RUN.SUFIJO $sufijo ICATALOG BP CENTRAL.TRIGGER" 1>>$QCMD
	else
		echo -e "N"				                                      1>>$QCMD
		echo -e "UPDATE.ACCOUNT"                                      1>>$QCMD
		echo -e "COPYI FROM &TEMP& TO VOC UP OVERWRITING"             1>>$QCMD
		echo -e "QSIS.INI.UV"                                         1>>$QCMD
		echo -e "QSIS.PREPBATCH"                                      1>>$QCMD
		echo -e "QSIS.RUN DATE"                                       1>>$QCMD
		echo -e "QSIS.RUN WHO"                                        1>>$QCMD
		echo -e "QSIS.RUN SH -c pwd"                                  1>>$QCMD
		echo -e "QSIS.RUN ICATALOG BP CENTRAL.TRIGGER"                1>>$QCMD
	fi
	#echo -e $UVCMD "QSIS.RUN.SUFIJO $sufijo RUN BP INSTALL.TRIGGERS"
	#$UVCMD "QSIS.RUN.SUFIJO $sufijo RUN BP INSTALL.TRIGGERS" 1>>$UVLOG 2>>$UVERR
	#2020/08/24 no funciona porque CONEXION no tiene lo necesario y aborta
	#recorrer cuentas UV ejecutando INSTALL.TRIGGERS
	echo -e "LOGTO GEN4GL$sufijo"         1>>$QCMD
	echo -e "SH -c pwd"                   1>>$QCMD
	echo -e "DROP TRIGGER GNFILE ALL;"    1>>$QCMD
	echo -e "LIST.SICA PARAMETROS"        1>>$QCMD
	for i in "GEN4GL$sufijo" "COMERCIAL$sufijo" "CONTA5$sufijo" "POSVENTA5$sufijo"
	do
		set -- $i
		echo -e "DISPLAY <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALAMOS TRIGGERS EN $1" >>$QCMD
		echo -e "LOGTO $1"                1>>$QCMD
		echo -e "WHO"                     1>>$QCMD
		echo -e "SH -c pwd"               1>>$QCMD
		echo -e "RUN BP INSTALL.TRIGGERS" 1>>$QCMD
	done
	echo -e "LOGTO GEN4GL$sufijo"         1>>$QCMD
	echo -e "SH -c pwd"                   1>>$QCMD
	echo -e "LIST.SICA PARAMETROS"        1>>$QCMD
	cd $GNDIR
	$UVCMD <$QCMD 1>>$UVLOG 2>>$UVERR
	cd $LDIR
	tail -n 11 $UVLOG
	echo -e "\\n==== Completado despliegue Triggers $sufijo ==== \\n"
}

_Q_ParGen_(){
	cd $LDIR
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	GNDIR="$QPATH/GEN4GL"
	UVLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_ParGen_${sufijo}_stdout.log"
	UVERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_ParGen_${sufijo}_stderr.log"
	QCMD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Quiter$sufijoCmd.txt"
	echo -e $separador 
	echo -e "==== [$1/$2] Configurar Par_Gen $sufijo ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $UVLOG
	echo -e Standard Error.................: $UVERR
	echo -e UniVerse command...............: $UVCMD
	echo -e GEN4GL.Dir.....................: $GNDIR
	echo -e Quiter.Path....................: $QPATH
	echo -e Sufijo.........................: $sufijo \\n
	mkdir -p $DIRLOG
	cd $GNDIR
	#modificar PAR_GEN dependiendo de si es plataformando nuevo o cambio de linux
	echo "WHO"                          > $QCMD
	echo "SH -c pwd"                   >> $QCMD
	echo "DATE"                        >> $QCMD
	echo "CT PAR_GEN GEN -NO.PAGE"     >> $QCMD
	case $3 in
		_Cambio_lin_a_lin)
			#echo "ED PAR_GEN GEN"      >> $QCMD
			# Si no tenemos firewall activo dejamos las transferencias ftp como estaban
			# Si tenemos firewall activo mejor cambiar las transferencias ftp a modo activo
			#echo "41"                  >> $QCMD
			#echo "DE"                  >> $QCMD
			#echo "I"                   >> $QCMD
			#echo "1"                   >> $QCMD
			#echo ""                    >> $QCMD
			# Si cambia de ip el Dms
			#echo "42"                  >> $QCMD
			#echo "DE"                  >> $QCMD
			#echo "I"                   >> $QCMD
			#echo "http://$DMSnew:6080" >> $QCMD
			#echo ""                    >> $QCMD
			#echo "FI"                  >> $QCMD
			echo "DATE"                >> $QCMD
			echo "RUN BP PUTUSRTRANS"  >> $QCMD
			echo "ftpq"                >> $QCMD
			echo "$ftpqpass"           >> $QCMD
			echo "QUITER"              >> $QCMD
			;;
		_Cambio_win_a_lin)
			echo "ED PAR_GEN GEN"      >> $QCMD
			# Si no tenemos firewall activo dejamos las transferencias ftp como estaban
			# Si tenemos firewall activo mejor cambiar las transferencias ftp a modo activo
			#echo "41"                  >> $QCMD
			#echo "DE"                  >> $QCMD
			#echo "I"                   >> $QCMD
			#echo "1"                   >> $QCMD
			#echo ""                    >> $QCMD
			echo "42"                  >> $QCMD
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "http://$DMSnew:6080" >> $QCMD
			echo ""                    >> $QCMD
			echo "44"                  >> $QCMD
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "$QPATH/qjava/"       >> $QCMD
			echo ""                    >> $QCMD
			echo "53"                  >> $QCMD
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "$gquiter"            >> $QCMD
			echo ""                    >> $QCMD
			echo "59"                  >> $QCMD		
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "$UVDIR"              >> $QCMD	
			echo ""                    >> $QCMD
			echo "FI"                  >> $QCMD
			echo "DATE"                >> $QCMD
			echo "RUN BP PUTUSRTRANS"  >> $QCMD
			echo "ftpq"                >> $QCMD
			echo "$ftpqpass"           >> $QCMD
			echo "QUITER"              >> $QCMD			
			;;
		_UniVerse_Install)
			#echo "ED PAR_GEN GEN"      >> $QCMD
			#echo "59"                  >> $QCMD		
			#echo "DE"                  >> $QCMD
			#echo "I"                   >> $QCMD
			#echo "$UVDIR"              >> $QCMD	
			#echo ""                    >> $QCMD
			#echo "FI"                  >> $QCMD
			echo "DATE"                >> $QCMD			
			;;
		_UniVerse___InstX)
			echo "DATE"                >> $QCMD
			;;
		_Pst_Platform_DMS | _Desplegar__InstX )
			echo "ED PAR_GEN GEN"      >> $QCMD
			# Si no tenemos firewall activo dejamos las transferencias ftp como estaban
			# Si tenemos firewall activo mejor cambiar las transferencias ftp a modo activo
			# Los servidores nuevos la mayoria vienen con firewall activo
			echo "41"                  >> $QCMD
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "1"                   >> $QCMD
			echo ""                    >> $QCMD
			echo "42"                  >> $QCMD
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "http://$DMSnew:6080" >> $QCMD
			echo ""                    >> $QCMD
			echo "44"                  >> $QCMD
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "$QPATH/qjava/"       >> $QCMD
			echo ""                    >> $QCMD
			echo "53"                  >> $QCMD
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "$gquiter"            >> $QCMD
			echo ""                    >> $QCMD
			echo "57"                  >> $QCMD
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			if [ $QAWID ]
				then
					echo "$QAWID"      >> $QCMD
				else
					echo " "           >> $QCMD	
			fi
			echo ""                    >> $QCMD
			echo "59"                  >> $QCMD		
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "$UVDIR"              >> $QCMD	
			echo ""                    >> $QCMD
			echo "FI"                  >> $QCMD
			echo "DATE"                >> $QCMD
			echo "RUN BP PUTUSRTRANS"  >> $QCMD
			echo "ftpq"                >> $QCMD
			echo "$ftpqpass"           >> $QCMD
			echo "QUITER"              >> $QCMD
			;;
		_Activar_DmsTest_)
			echo "ED PAR_GEN GEN"      >> $QCMD
			echo "42"                  >> $QCMD
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "http://$DMSnew:6080" >> $QCMD
			echo ""                    >> $QCMD
			echo "57"                  >> $QCMD		
			echo "DE"                  >> $QCMD
			echo "I"                   >> $QCMD
			echo "$QAWID"              >> $QCMD	
			echo ""                    >> $QCMD
			echo "FI"                  >> $QCMD
			echo "DATE"                >> $QCMD
			echo "RUN BP PUTUSRTRANS"  >> $QCMD
			echo "ftpq"                >> $QCMD
			echo "$ftpqpass"           >> $QCMD
			echo "QUITER"              >> $QCMD
			;;
		*)
			echo "DATE"                >> $QCMD
			;;
	esac
	echo "DATE"                        >> $QCMD
	echo "CT PAR_GEN GEN -NO.PAGE"     >> $QCMD
	echo "DATE"                        >> $QCMD
	cd $GNDIR
	$UVCMD <$QCMD 1>>$UVLOG 2>>$UVERR
	$UVCMD "CT PAR_GEN GEN -NO.PAGE"|grep 25
	$UVCMD "CT PAR_GEN GEN -NO.PAGE"|grep 26
	$UVCMD "CT PAR_GEN GEN -NO.PAGE"|grep 37
	$UVCMD "CT PAR_GEN GEN -NO.PAGE"|grep 38
	$UVCMD "CT PAR_GEN GEN -NO.PAGE"|grep 41
	$UVCMD "CT PAR_GEN GEN -NO.PAGE"|grep 42
	$UVCMD "CT PAR_GEN GEN -NO.PAGE"|grep 44
	$UVCMD "CT PAR_GEN GEN -NO.PAGE"|grep 53
	$UVCMD "CT PAR_GEN GEN -NO.PAGE"|grep 57
	$UVCMD "CT PAR_GEN GEN -NO.PAGE"|grep 59
	cd $LDIR
	echo -e "\\n==== Completada configuracion Par_Gen $sufijo ==== \\n"
}

_Qibk_Ins_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QBKLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qibk_stdout.log"
	QBKERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Qibk_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Desplegar Qibk ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e UniVerse Dir...................: $UVDIR
	echo -e Standard Output................: $QBKLOG
	echo -e Standard Error.................: $QBKERR \\n
	mkdir -p $DIRLOG
	tar xvfz RepoLin/qibk.tar.gz -C $UVDIR 1>$QBKLOG 2>$QBKERR
	if ! grep -q qibk "/var/spool/cron/root" 1>>$QBKLOG 2>>$QBKERR;
		then
			echo -e "\\n Agregando Qibk al crontab "
			cat $UVDIR/qibk/linux/crontab.txt >> /var/spool/cron/root
		else
			echo -e "\\n Qibk ya programado en crontab"
	fi
	cat /var/spool/cron/root >>$QBKLOG
	du -hs $UVDIR/qibk
	cat /var/spool/cron/root|grep qibk
	if mountpoint -q "/u3";
		then
			echo -e "\\n /u3 es punto de montaje "
			mkdir -pv /u3/quiter_bk  1>>$QBKLOG 2>>$QBKERR
			ln -vs /u3/quiter_bk /u2/quiter_bk 1>>$QBKLOG 2>>$QBKERR
		else
			echo -e "\\n /u3 no es punto de montaje "
			mkdir -v /u2/quiter_bk  1>>$QBKLOG 2>>$QBKERR
			cp -v $UVDIR/qibk/linux/conf_simple.xml $UVDIR/qibk/linux/conf_simple.xml.bak 1>>$QBKLOG 2>>$QBKERR
			sed "s/u3/u2/g " $UVDIR/qibk/linux/conf_simple.xml.bak > $UVDIR/qibk/linux/conf_simple.xml
	fi
	echo -e "\\n Qibk configurado contra:"
	cat $UVDIR/qibk/linux/conf_simple.xml|grep qibk
	echo -e "\\n==== Completado despliegue Qibk ==== \\n"
}

_QAW__Ins_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	QAWLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QAW_stdout.log"
	QAWERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_QAW_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Desplegar QuiterAutoWeb ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $QAWLOG
	echo -e Standard Error.................: $QAWERR \\n
	mkdir -p $DIRLOG
	unzip -o RepoLin/InsQAW.zip -d /u2/InstalacionQuiterAutoWeb 1>$QAWLOG 2>$QAWERR
	chown -vR $gquiter:$gquiter /u2/InstalacionQuiterAutoWeb 1>>$QAWLOG 2>>$QAWERR
	chmod -vR 775 /u2/InstalacionQuiterAutoWeb 1>>$QAWLOG 2>>$QAWERR
	du -hs /u2/InstalacionQuiterAutoWeb
	ls -lha /u2/InstalacionQuiterAutoWeb/InstalarQAW*
	echo -e "\\n==== Completado despliegue QuiterAutoWeb ==== \\n"
}

_Sys_Srvs_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	SSLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_SysServices_stdout.log"
	SSERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_SysServices_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Activar&Iniciar servicios de sistema ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $SSLOG
	echo -e Standard Error.................: $SSERR \\n
	mkdir -p $DIRLOG
	cp -vf $LDIR/RepoLin/httpd.quiter.conf /etc/httpd/conf.d/ 1>>$SSLOG 2>>$SSERR
	cp -vf $LDIR/RepoLin/smb.conf /etc/samba/smb.conf 1>>$SSLOG 2>>$SSERR
	systemctl enable httpd 1>$SSLOG 2>$SSERR
	systemctl enable vsftpd 1>>$SSLOG 2>>$SSERR
	systemctl enable telnet.socket 1>>$SSLOG 2>>$SSERR
	systemctl enable smb 1>>$SSLOG 2>>$SSERR
	systemctl start httpd 1>>$SSLOG 2>>$SSERR
	systemctl start vsftpd 1>>$SSLOG 2>>$SSERR
	systemctl start telnet.socket 1>>$SSLOG 2>>$SSERR
	systemctl start smb 1>>$SSLOG 2>>$SSERR
	
	echo "==== autopasswd ====" 1>>$SSLOG 2>>$SSERR
	echo "[cp $LDIR/RepoLin/autopasswd /sbin]" 1>>$SSLOG 2>>$SSERR
	cp -vf $LDIR/RepoLin/autopasswd /sbin 1>>$SSLOG 2>>$SSERR
	chmod -v 777 /sbin/autopasswd 1>>$SSLOG 2>>$SSERR
	ls -lha /sbin/autopasswd 1>>$SSLOG 2>>$SSERR
	ls -lha /sbin/autopasswd
	echo -e "\\n==== Completada configuracion servicios de sistema ==== \\n"
}

_Test_Ftp_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	FTPLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Ftp_stdout.log"
	FTPERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Ftp_stderr.log"
	FTPCMD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_FtpCmd.txt"
	echo -e $separador
	cd $LDIR
	echo -e "==== [$1/$2] Ftp test login ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $FTPLOG
	echo -e Standard Error.................: $FTPERR \\n
	mkdir -p $DIRLOG
	echo "open localhost" >$FTPCMD
	echo "quote USER aquiter" >>$FTPCMD
	echo "quote PASS $aquiterpass" >>$FTPCMD
	echo "cd $QPATH" >>$FTPCMD
	echo "ls" >>$FTPCMD
	echo "close" >>$FTPCMD
	echo "open localhost" >>$FTPCMD
	echo "quote USER quiter" >>$FTPCMD
	echo "quote PASS $quiterpass" >>$FTPCMD
	echo "cd $QPATH" >>$FTPCMD
	echo "ls" >>$FTPCMD
	echo "close" >>$FTPCMD
	echo "open localhost" >>$FTPCMD
	echo "quote USER gateway" >>$FTPCMD
	echo "quote PASS $gatewaypass" >>$FTPCMD
	echo "cd $QPATH" >>$FTPCMD
	echo "ls" >>$FTPCMD
	echo "close" >>$FTPCMD
	echo "open localhost" >>$FTPCMD
	echo "quote USER ftpq" >>$FTPCMD
	echo "quote PASS $ftpqpass" >>$FTPCMD
	echo "cd $QPATH" >>$FTPCMD
	echo "ls" >>$FTPCMD
	echo "close" >>$FTPCMD
	ftp -invd < $FTPCMD 1>$FTPLOG 2>$FTPERR
	grep "Login successful" $FTPLOG
	echo -e "\\n==== Completado Ftp test login ==== \\n"
}

_Clean_Up_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	CLLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Clean_stdout.log"
	CLERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Clean_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Limpieza ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $CLLOG
	echo -e Standard Error.................: $CLERR \\n
	mkdir -p $DIRLOG
	rm -vf paginas* 1>$CLLOG 2>$CLERR
	#si haces esto QuiterSetup no lo puedes llevar a Windows
	#rm -rfv quitersetup/jvm/j2re1.4.2_14/ 1>>$CLLOG 2>>$CLERR
	rm -rfv universe-11.3.* 1>>$CLLOG 2>>$CLERR
	rm -vf token_v2.json 1>>$CLLOG 2>>$CLERR
	rm -vf uojlog_0.log.0* 1>>$CLLOG 2>>$CLERR
	echo -e "\\n==== Completada limpieza ==== \\n"
	echo -e $separador
}

######################## Funciones Pre-Plataformado

_SElinux__(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	SELOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_SElinux_stdout.log"
	SEERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_SElinux_stderr.log"
	FWLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Firewall_stdout.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] SElinux ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $SELOG
	echo -e Standard Error.................: $SEERR \\n
	mkdir -p $DIRLOG
	#copiar el .bash_history de root para reponerlo despues
	cp -vp /root/.bash_history /root/.bash_history.bak 1>$SELOG 2>$SEERR
	#SELinux
	getenforce 1>>$SELOG 2>>$SEERR
	cp -vp /etc/selinux/config /etc/selinux/config.bak 1>>$SELOG 2>>$SEERR
	cat /etc/selinux/config 1>>$SELOG 2>>$SEERR
	sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
	setenforce 0 1>>$SELOG 2>>$SEERR
	cat /etc/selinux/config 1>>$SELOG 2>>$SEERR
	getenforce 1>>$SELOG 2>>$SEERR
	getenforce
	#Firewall
	echo -e "\\n>>>>>> iptables --list\\n" 1>>$FWLOG 2>>$FWLOG
	iptables --list 1>>$FWLOG 2>>$FWLOG
	echo -e "\\n>>>>>> firewall-cmd --get-zones\\n" 1>>$FWLOG 2>>$FWLOG
	firewall-cmd --get-zones 1>>$FWLOG 2>>$FWLOG
	echo -e "\\n>>>>>> firewall-cmd --get-default-zone\\n" 1>>$FWLOG 2>>$FWLOG
	firewall-cmd --get-default-zone 1>>$FWLOG 2>>$FWLOG
	echo -e "\\n>>>>>> firewall-cmd --get-active-zones\\n" 1>>$FWLOG 2>>$FWLOG
	firewall-cmd --get-active-zones 1>>$FWLOG 2>>$FWLOG

	echo -e "\\n==== Completed SElinux ==== \\n"
}

_LocalTime(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	LTLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_LocalTime_stdout.log"
	LTERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_LocalTime_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] LocalTime ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $LTLOG
	echo -e Standard Error.................: $LTERR
	echo -e Pais...........................: $PAIS \\n
	mkdir -p $DIRLOG 
	date 1>$LTLOG 2>$LTERR
	ls -lha /etc/localtime* 1>>$LTLOG 2>>$LTERR
	mv -vf /etc/localtime /etc/localtime.bak 1>>$LTLOG 2>>$LTERR
	echo -e Pais=$PAIS 1>>$LTLOG 2>>$LTERR
	$LCTIME 1>>$LTLOG 2>>$LTERR
	ls -lha /etc/localtime* 1>>$LTLOG 2>>$LTERR
	date 1>>$LTLOG 2>>$LTERR
	ls -lha /etc/localtime
	date
	echo -e "\\n==== Completed Localtime ==== \\n"
}

_SysUsers_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	USRLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_SisUsers_stdout.log"
	USRERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_SisUsers_stderr.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Crear usuarios aquiter y rootquiter ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $USRLOG
	echo -e Standard Error.................: $USRERR \\n
	mkdir -p $DIRLOG 
	ls -lha /etc/passwd /etc/shadow /etc/group 1>$USRLOG 2>$USRERR
	cp -vp /etc/passwd /etc/passwd.$LOGDATE 1>>$USRLOG 2>>$USRERR
	cp -vp /etc/shadow /etc/shadow.$LOGDATE 1>>$USRLOG 2>>$USRERR
	cp -vp /etc/group /etc/group.$LOGDATE 1>>$USRLOG 2>>$USRERR
	ls -lha /etc/passwd* /etc/shadow* /etc/group*  1>>$USRLOG 2>>$USRERR
	
	# AQUITER
	echo -e $separador 1>>$USRLOG 2>>$USRERR
	if id -u aquiter &>/dev/null; then
		echo 'Existe aquiter' 1>>$USRLOG 2>>$USRERR
		echo $aquiterpass | passwd aquiter --stdin 1>>$USRLOG 2>>$USRERR
		#aquiter_home=$(grep aquiter /etc/passwd|cut -f6 -d":")
		#cp -v $aquiter_home /home 1>>$USRLOG 2>>$USRERR
		usermod -m -d /home/aquiter aquiter 1>>$USRLOG 2>>$USRERR
	else
		echo 'No-existe aquiter' 1>>$USRLOG 2>>$USRERR
		echo 'Creando aquiter  ' 1>>$USRLOG 2>>$USRERR
		useradd -d /home/aquiter aquiter 1>>$USRLOG 2>>$USRERR
		echo $aquiterpass | passwd aquiter --stdin 1>>$USRLOG 2>>$USRERR
	fi
	echo -e "PS1='[aquiter@$HOST \W]$ '" >> /home/aquiter/.bashrc
	chown -vR aquiter:aquiter /home/aquiter/ 1>>$USRLOG 2>>$USRERR
	#chmod -vR 770 /home/aquiter/ 1>>$USRLOG 2>>$USRERR
	cat /etc/passwd |grep aquiter 1>>$USRLOG 2>>$USRERR
	id aquiter 1>>$USRLOG 2>>$USRERR
	echo -e "aquiter ALL=(ALL)		ALL" > /etc/sudoers.d/aquiter
	#systemctl restart sshd.service
	
	# ROOTQUITER
	echo -e $separador 1>>$USRLOG 2>>$USRERR
	if id -u rootquiter &>/dev/null; then
		echo 'Existe rootquiter' 1>>$USRLOG 2>>$USRERR
		echo $aquiterpass | passwd rootquiter --stdin 1>>$USRLOG 2>>$USRERR
	else
		echo 'No-existe rootquiter' 1>>$USRLOG 2>>$USRERR
		echo 'Creando rootquiter  ' 1>>$USRLOG 2>>$USRERR
		useradd -d /home/rootquiter rootquiter 1>>$USRLOG 2>>$USRERR
		echo $aquiterpass | passwd rootquiter --stdin 1>>$USRLOG 2>>$USRERR
	fi
	IDROOTQUITER=`id -u rootquiter`
	echo 'Asignando Id 0 a rootquiter' 1>>$USRLOG 2>>$USRERR
	sed -i "s/$IDROOTQUITER/0/g" /etc/passwd
	echo -e "PS1='[rootquiter@$HOST \W]# '" >> /home/rootquiter/.bashrc
	chown -vR rootquiter:rootquiter /home/rootquiter/ 1>>$USRLOG 2>>$USRERR
	#chmod -vR 770 /home/rootquiter/ 1>>$USRLOG 2>>$USRERR
	cat /etc/passwd |grep rootquiter 1>>$USRLOG 2>>$USRERR
	id rootquiter 1>>$USRLOG 2>>$USRERR
		
	tail /etc/passwd |grep quiter
	echo -e "\\n==== Usuarios aquiter y rootquiter creados ==== \\n"
}

_Paquetes_(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	YUMLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Paquetes_stdout.log"
	YUMERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_Paquetes_stderr.log"
	full=`cat /etc/redhat-release`
	major=$(cat /etc/redhat-release | tr -dc '0-9.'|cut -d \. -f1)
	minor=$(cat /etc/redhat-release | tr -dc '0-9.'|cut -d \. -f2)
	asynchronous=$(cat /etc/redhat-release | tr -dc '0-9.'|cut -d \. -f3)
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Descargar Paquetes ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $YUMLOG
	echo -e Standard Error.................: $YUMERR 
	echo -e OS Version.....................: $full
	echo -e Major Relase...................: $major
	echo -e Minor Relase...................: $minor \\n
	mkdir -p $DIRLOG
	echo -e Descargando paquetes...
	case $major in
		7)
			echo -e $separador 1>$YUMLOG 2>$YUMERR
			yum install -y epel-release \\n 1>>$YUMLOG 2>>$YUMERR
			yum install -y yum-utils @ftp-server @web-server java-11-openjdk-headless.x86_64 openvpn net-tools tree wget zip unzip ed hdparm crypto-utils ftp iptraf iptstate mc iotop unix2dos dos2unix expect pexpect samba samba-client telnet telnet-server nmon htop fping lshw lsof ncurses-libs.i686 compat-libstdc++-33 sharutils system-storage-manager socat iftop atop rclone mailx rsync check-mk-agent open-vm-tools postfix xinetd 1>>$YUMLOG 2>>$YUMERR
			echo -e $separador 1>>$YUMLOG 2>>$YUMERR
			yum -y update 1>>$YUMLOG 2>>$YUMERR
			yum -y remove java 1>>$YUMLOG 2>>$YUMERR
			;;
		8)
			echo -e $separador 1>$YUMLOG 2>$YUMERR
			echo -e Instalando nuestros paquetes 1>>$YUMLOG 2>>$YUMERR
			dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm 1>>$YUMLOG 2>>$YUMERR
			#dnf -y install @ftp-server @web-server mailx ftp iptraf mc iotop expect python3-pexpect samba samba-client telnet telnet-server nmon htop fping openvpn glibc.i686 postfix system-storage-manager ncurses-libs.i686 ncurses-compat-libs.i686 ncurses-libs ncurses-compat-libs libnsl libnsl.i686 socat atop iftop rclone postfix gnutls-utils nss-tools rsyslog zip ed open-vm-tools net-tools sysstat dos2unix 1>>$YUMLOG 2>>$YUMERR
			#dnf -y install @ftp-server @web-server mailx ftp iptraf mc iotop expect python3-pexpect samba samba-client telnet telnet-server nmon htop fping openvpn glibc.i686 postfix system-storage-manager ncurses-libs.i686 ncurses-compat-libs.i686 ncurses-libs ncurses-compat-libs libnsl.x86_64 libnsl.i686 socat atop iftop rclone postfix gnutls-utils nss-tools rsyslog zip ed open-vm-tools net-tools sysstat dos2unix lsof 1>>$YUMLOG 2>>$YUMERR
			dnf -y install @ftp-server @web-server java-11-openjdk-headless.x86_64 mailx ftp iptraf mc iotop expect python3-pexpect samba samba-client telnet telnet-server nmon htop fping openvpn glibc.i686 postfix system-storage-manager ncurses-libs.i686 ncurses-compat-libs.i686 ncurses-libs ncurses-compat-libs libnsl.x86_64 libnsl.i686 socat atop iftop rclone postfix gnutls-utils nss-tools rsyslog zip ed open-vm-tools net-tools sysstat dos2unix lsof 1>>$YUMLOG 2>>$YUMERR
			echo -e $separador 1>>$YUMLOG 2>>$YUMERR
			echo -e Realizando Update \\n 1>>$YUMLOG 2>>$YUMERR
			dnf -y update 1>>$YUMLOG 2>>$YUMERR
			dnf -y remove java 1>>$YUMLOG 2>>$YUMERR
			;;
	esac
	echo -e "\\n==== Paquetes descargados ==== \\n"
}

_SysConfig(){
	LOGDATE=`date +\%F`
	LOGTIME=`date +\%T`
	DIRLOG="$3_$1_$2_${FUNCNAME[0]}"
	SISLOG="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_SisConfig_stdout.log"
	SISERR="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_SisConfig_stderr.log"
	SISHWD="$LDIR/$DIRLOG/${LOGDATE}_${LOGTIME}_SisHard.log"
	echo -e $separador 
	cd $LDIR
	echo -e "==== [$1/$2] Configuracion del Sistema ===="
	echo -e Date...........................: `date`
	echo -e Run dir........................: `pwd`
	echo -e Standard Output................: $SISLOG
	echo -e Standard Error.................: $SISERR \\n
	mkdir -p $DIRLOG 
	
	echo -e "\\n==== my.cnf ==== \\n" 1>>$SISLOG 2>>$SISERR
	mv -v /etc/my.cnf /etc/my.cnf.NO.ACTIVAR 1>$SISLOG 2>$SISERR
	echo -e "Apartar    /etc/my.cnf "
	
	echo -e "\\n==== sysctl.conf ==== \\n" 1>>$SISLOG 2>>$SISERR
	cp -v /etc/sysctl.conf /etc/sysctl.conf.bak 1>>$SISLOG 2>>$SISERR
	echo net.ipv4.ip_forward = 0 >> /etc/sysctl.conf
	echo net.ipv4.conf.default.rp_filter = 1 >> /etc/sysctl.conf
	echo net.ipv4.conf.default.accept_source_route = 0 >> /etc/sysctl.conf
	echo kernel.sysrq = 0 >> /etc/sysctl.conf
	echo kernel.core_uses_pid = 1 >> /etc/sysctl.conf
	echo net.ipv4.tcp_syncookies = 1 >> /etc/sysctl.conf
	echo kernel.msgmnb = 65536 >> /etc/sysctl.conf
	echo kernel.msgmax = 65536 >> /etc/sysctl.conf
	echo kernel.shmmax = 68719476736 >> /etc/sysctl.conf
	echo kernel.shmall = 4294967296 >> /etc/sysctl.conf
	echo vm.swappiness = 10 >> /etc/sysctl.conf
	echo vm.vfs_cache_pressure = 30 >> /etc/sysctl.conf
	echo vm.dirty_ratio = 30 >> /etc/sysctl.conf
	echo vm.dirty_writeback_centisecs = 5000 >> /etc/sysctl.conf
	echo vm.dirty_expire_centisecs = 5000 >> /etc/sysctl.conf
	echo net.ipv4.ip_local_port_range = 10000 65000 >> /etc/sysctl.conf
	echo net.core.rmem_max = 16777216 >> /etc/sysctl.conf
	echo net.core.wmem_max = 16777216 >> /etc/sysctl.conf
	echo net.core.rmem_default = 16777216 >> /etc/sysctl.conf
	echo net.core.wmem_default = 16777216 >> /etc/sysctl.conf
	echo net.core.optmem_max = 40960 >> /etc/sysctl.conf
	echo net.ipv4.tcp_rmem = 4096 87380 16777216 >> /etc/sysctl.conf
	echo net.ipv4.tcp_wmem = 4096 65536 16777216 >> /etc/sysctl.conf
	echo net.core.netdev_max_backlog = 50000 >> /etc/sysctl.conf
	echo net.ipv4.tcp_max_syn_backlog = 30000 >> /etc/sysctl.conf
	echo net.ipv4.tcp_max_tw_buckets = 2000000 >> /etc/sysctl.conf
	echo net.ipv4.tcp_tw_reuse = 1 >> /etc/sysctl.conf
	echo net.ipv4.tcp_fin_timeout = 10 >> /etc/sysctl.conf
	echo net.ipv4.tcp_slow_start_after_idle = 0 >> /etc/sysctl.conf
	echo net.ipv4.tcp_keepalive_time = 60 >> /etc/sysctl.conf
	echo net.ipv4.tcp_keepalive_probes = 3 >> /etc/sysctl.conf
	echo net.ipv4.tcp_keepalive_intvl = 10 >> /etc/sysctl.conf
	### ojo esta es la que hace que telnet no arranque y tengamos que hacer dracut
	### echo net.ipv6.conf.all.disable_ipv6 = 1
	sysctl -a  2>>$SISERR|grep net.ipv4.tcp_fin_timeout 1>>$SISLOG
	date 1>>$SISLOG 2>>$SISERR
	sysctl -p 1>>$SISLOG 2>>$SISERR
	date 1>>$SISLOG 2>>$SISERR
	sysctl -a  2>>$SISERR|grep net.ipv4.tcp_fin_timeout 1>>$SISLOG
	echo -e "Configurar /etc/sysctl.conf "
	
	echo -e "\\n==== hosts ==== \\n" 1>>$SISLOG 2>>$SISERR
	cp -v /etc/hosts /etc/hosts.bak 1>>$SISLOG 2>>$SISERR
	echo -e "\\n$DMSnew\t$HOSTDMS\tDms" 1>>/etc/hosts
	echo -e "$QAEnew\t$HOSTQAE\tQae" 1>>/etc/hosts
	echo -e "10.60.16.1\tQuiter" 1>>/etc/hosts
	echo -e "10.77.0.1\tQuiter" 1>>/etc/hosts
	echo -e "10.20.4.1\tQuiter\\n" 1>>/etc/hosts
	echo -e "Configurar /etc/hosts "
	
	echo -e "\\n==== rc.local ==== \\n" 1>>$SISLOG 2>>$SISERR
	cp -v /etc/rc.d/rc.local /etc/rc.d/rc.local.bak 1>>$SISLOG 2>>$SISERR
	echo "df -T | awk '{print \$1}' | grep "^/dev" | xargs /sbin/blockdev --setra 16384" >> /etc/rc.local
	cat /etc/rc.local 1>>$SISLOG 2>>$SISERR
	chmod -v +x /etc/rc.d/rc.local 1>>$SISLOG 2>>$SISERR
	ls -lha /etc/rc.d/rc.local* 1>>$SISLOG 2>>$SISERR
	cp -vf /etc/rc.d/rc.local /etc/rc.d/rc.local.bak.quiter 1>>$SISLOG 2>>$SISERR
	echo -e "Configurar /etc/rc.local "

	echo -e "\\n==== httpd ==== \\n" 1>>$SISLOG 2>>$SISERR
	ls -la /etc/httpd/conf/httpd.conf* 1>>$SISLOG 2>>$SISERR
	cadena1="AddDefaultCharset UTF-8"
	cadena2="AddDefaultCharset ISO-8859-1"
	echo "[sed 's/$cadena1/$cadena2/g ' /etc/httpd/conf/httpd.conf > /etc/httpd/conf/httpd.conf.mod]" 1>>$SISLOG 2>>$SISERR
	sed "s/$cadena1/$cadena2/g " /etc/httpd/conf/httpd.conf > /etc/httpd/conf/httpd.conf.mod
	mv -v /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak 1>>$SISLOG 2>>$SISERR
	mv -v /etc/httpd/conf/httpd.conf.mod /etc/httpd/conf/httpd.conf 1>>$SISLOG 2>>$SISERR
	ls -lha /etc/httpd/conf/httpd.conf* 1>>$SISLOG 2>>$SISERR
	echo -e "Configurar /etc/httpd/httpd.conf "
	
	echo -e "\\n==== smb ==== \\n" 1>>$SISLOG 2>>$SISERR
	mv -vf /etc/samba/smb.conf /etc/samba/smb.conf.bak 1>>$SISLOG 2>>$SISERR
	echo -e "Configurar /etc/samba/smb.conf "
	
	echo -e "\\n==== vsftpd ==== \\n" 1>>$SISLOG 2>>$SISERR
	ls -la /etc/vsftpd/vsftpd.conf* 1>>$SISLOG 2>>$SISERR
	cadena1="local_umask=022"
	cadena2="local_umask=002"
	cadena3="#ascii_upload_enable=YES"
	cadena4="ascii_upload_enable=YES"
	cadena5="#ascii_download_enable=YES"
	cadena6="ascii_download_enable=YES"
	cadena7="anonymous_enable=YES"
	cadena8="anonymous_enable=NO"
	echo "[sed 's/$cadena1/$cadena2/g; s/$cadena3/$cadena4/g; s/$cadena5/$cadena6/g; s/$cadena7/$cadena8/g ' /etc/vsftpd/vsftpd.conf > /etc/vsftpd/vsftpd.conf.mod]" 1>>$SISLOG 2>>$SISERR
	sed "s/$cadena1/$cadena2/g; s/$cadena3/$cadena4/g; s/$cadena5/$cadena6/g; s/$cadena7/$cadena8/g " /etc/vsftpd/vsftpd.conf > /etc/vsftpd/vsftpd.conf.mod
	mv -vf /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak 1>>$SISLOG 2>>$SISERR
	mv -vf /etc/vsftpd/vsftpd.conf.mod /etc/vsftpd/vsftpd.conf 1>>$SISLOG 2>>$SISERR
	ls -la /etc/vsftpd/vsftpd.conf* 1>>$SISLOG 2>>$SISERR
	echo -e "Configurar /etc/vsftpd/vsftpd.conf "

	echo -e "\\n==== openvpn ==== \\n" 1>>$SISLOG 2>>$SISERR
	cd /etc/openvpn/client 
	pwd 1>>$SISLOG 2>>$SISERR
	wget --append-output=$SISLOG http://soporte.quiter.es/publico/openvpn/openvpn15.conf
	wget --append-output=$SISLOG http://soporte.quiter.es/publico/openvpn/milpies.conf
	#wget http://soporte.quiter.es/publico/openvpn/openvpnDmsApi.conf 1>>$SISLOG 2>>$SISERR
	chmod -v 775 * 1>>$SISLOG 2>>$SISERR
	ls -la 1>>$SISLOG 2>>$SISERR
	cd /lib/systemd/system
	pwd 1>>$SISLOG 2>>$SISERR 
	mv -vf openvpn@.service openvpn@.service.old 1>>$SISLOG 2>>$SISERR
	wget --append-output=$SISLOG http://soporte.quiter.es/publico/openvpn/openvpn@.service
	ls -la openvpn* 1>>$SISLOG 2>>$SISERR
	cd $LDIR
	echo -e "Configurar /etc/openvpn/client "

	echo -e "\\n==== postfix ====" 1>>$SISLOG 2>>$SISERR
	ls -la /etc/postfix/main.cf* 1>>$SISLOG 2>>$SISERR
	cadena1="inet_interfaces = localhost"
	cadena2="inet_interfaces = all"
	echo "[sed 's/$cadena1/$cadena2/g ' /etc/postfix/main.cf > /etc/postfix/main.cf.mod]" 1>>$SISLOG 2>>$SISERR
	sed "s/$cadena1/$cadena2/g " /etc/postfix/main.cf > /etc/postfix/main.cf.mod
	mv -f /etc/postfix/main.cf /etc/postfix/main.cf.bak 1>>$SISLOG 2>>$SISERR
	mv -f /etc/postfix/main.cf.mod /etc/postfix/main.cf 1>>$SISLOG 2>>$SISERR
	ls -la /etc/postfix/main.cf* 1>>$SISLOG 2>>$SISERR
	cat /etc/postfix/main.cf |grep inet_interfaces 1>>$SISLOG 2>>$SISERR
	echo -e "Configurar /etc/postfix/main.cf "
	if [ -e /var/spool/postfix/public/pickup ];
		then
			echo -e "Existe /var/spool/postfix/public/pickup \\n"
		else
			echo -e "No existe /var/spool/postfix/public/pickup \\n"
			mkfifo /var/spool/postfix/public/pickup
			systemctl restart postfix.service
	fi
	
	echo -e "\\n==== lshw ==== \\n" 1>>$SISLOG 2>>$SISERR
	lshw > $SISHWD
	
	echo -e "\\n==== Completada configuracion del sistema ==== \\n"
	echo -e $separador
}
	
######################## Procesos Principales

_Cambio_lin_a_lin(){
	#
	# Logica de cambio de Dms linux a linux
	#
	echo -e "[ Inicio Cambio Linux a Linux]"
	date
	_Q_Rsync__ 01 14 $FUNCNAME
	if [ -d $QPATH ];
		then
			echo -e "Existe $QPATH ejecucion detenida \\n"
		else
			echo -e "No Existe $QPATH continua la ejecucion \\n"
				mv -v /etc/init.d/quitergateway.service /etc/init.d/quitergateway.service.NO.ACTIVAR
				_Mv_QR_Qu2 02 14 $FUNCNAME
				sleep 5
				_Q_Rights_ 03 14 $FUNCNAME
				_UpdAccnt_ 04 14 $FUNCNAME
				_Q_Triger_ 05 14 $FUNCNAME
				_Q_ParGen_ 06 14 $FUNCNAME
				_Cl_SuMen_ 07 14 $FUNCNAME
				_Cl_StPol_ 08 14 $FUNCNAME
				_QGW_Cfg__ 09 14 $FUNCNAME
				_Qtr_plat_ 10 14 $FUNCNAME
				if [ $1 ]
					then
						echo -e "\\n ¡¡¡¡¡      E j e c u c i o n    p a r a   P r o d u c c i o n      !!!!! \\n"
						# Cuando realizamos el ultimo rsync para entrar en produccion,
						# no pausamos tareas QDemonio _QD_pause_ las tareas del QDemonio quedan como estaban.
						# no limpiamos sms en cola    _Cl_Qms___ dejamos los sms en cola como estaban.
					else
						echo -e "\\n ¡¡¡¡¡      E j e c u c i o n    p a r a   T e s t P r o c e s o    !!!!! \\n"
						_QD_pause_ 11 14 $FUNCNAME
						_Cl_Qms___ 12 14 $FUNCNAME
				fi
				_Qbi_Vrfy_ 13 14 $FUNCNAME
				sleep 5
				# Qbi_Verify aqui por si uvfile se bloquea el resto de procesos esten terminados.
				_Mv_Qu2_QR 14 14 $FUNCNAME
				mv -v /etc/init.d/quitergateway.service.NO.ACTIVAR /etc/init.d/quitergateway.service
	fi
	echo -e $separador
	date
	echo -e "[ Fin Cambio Linux a Linux] \\n"
}

_Cambio_win_a_lin(){
	#
	# Logica de cambio de Dms windows a linux
	# el QBASE de windows tiene que estar donde quitersetup este configurado para encontrarlo
	# el .sql de windows tiene que estar en LDIR y llamase mysql_cliente.sql
	#
	echo -e "[ Inicio Cambio Windows a Linux]"
	date
	_DownUnzip 01 14 $FUNCNAME
	date
	_QsExePlt_ 02 14 $FUNCNAME &
	sleep 10
	date
	echo -e "\\n ==== Lanzado QuiterSetup en background \\n"
	echo -e $separador
	cd $LDIR
	if [ -d $QPATH ];
		then
			echo -e "Existe $QPATH ejecucion continua \\n"
				mv -v /etc/init.d/quitergateway.service /etc/init.d/quitergateway.service.NO.ACTIVAR
				echo -e
				_Qtr_plat_ 03 14 $FUNCNAME 
				_ImpMySql_ 04 14 $FUNCNAME 
				_QD_pause_ 05 14 $FUNCNAME 
				_Cl_SuMen_ 06 14 $FUNCNAME 
				_Cl_StPol_ 07 14 $FUNCNAME 
				_QDBLRset_ 08 14 $FUNCNAME 
				#QGW_lib no es necesario porque en quiter.plat dejamos el qjava que vamos a utilizar
				#QGW_qae no es necesario porque en quiter.plat dejamos el qjava que vamos a utilizar
				date
				echo -e "Esperando que termine QuiterSetup ...\\n"
				wait
				date
				_UpdAccnt_ 09 14 $FUNCNAME
				_Q_Triger_ 10 14 $FUNCNAME
				_Q_ParGen_ 11 14 $FUNCNAME
				_Q_Proces_ 12 14 $FUNCNAME
				_Qbi_Vrfy_ 13 14 $FUNCNAME
				_Q_Rights_ 14 14 $FUNCNAME
				mv -v /etc/init.d/quitergateway.service.NO.ACTIVAR /etc/init.d/quitergateway.service
		else
			echo -e "No Existe $QPATH ejecucion detenida \\n"
	fi
	echo -e $separador
	date
	echo -e "[ Fin Cambio Windows a Linux] \\n"
}

_Cambio_MongoData(){
	#
	# Logica de cambio de Qae linux
	#
	echo -e "[ Inicio Cambio Qae]"
	date
	_QaeRsync_ 01 03 $FUNCNAME
	if [ -d $QAEPATH ];
		then
			echo -e "Existe $QAEPATH ejecucion detenida \\n"
		else
			echo -e "No Existe $QAEPATH continua la ejecucion \\n"
			_Mv_RepoR_ 02 03 $FUNCNAME
			_MongoStr_ 03 03 $FUNCNAME				
	fi
	echo -e $separador
	date
	echo -e "[ Fin Cambio Qae] \\n"
}

_GenQbase_ExpGgw_(){
	#
	# Logica para generar Qbase y exportar Qgw
	# Logica para el cambio de lin a win
	#
	echo -e "[ Inicio Generar Qbase y Exportar Qgw ]"
	echo "Inicio Generar Qbase y Exportar Qgw"|mailx -s "$HOST $FUNCNAME" $email
	date
	if [ -d $QPATH ]
		then
			echo -e "Existe $QPATH continua ejecucion. \\n"
			if [ -d $LDIR/quitersetup ]
				then
					echo -e "Existe $LDIR/quitersetup continua ejecucion sin descargar ni configurar QuiterSetup. \\n"
				else
					echo -e "No-Existe $LDIR/quitersetup continua ejecucion descargando y configurando QuiterSetup. \\n"
					_RepoLin1_ 01 07 $FUNCNAME
					_QsCfgGen_ 02 07 $FUNCNAME
			fi
			_QsExeGen_ 03 07 $FUNCNAME
			_Qgw_Dump_ 04 07 $FUNCNAME
			_QsCurlDC_ 05 07 $FUNCNAME
			_LogEmail_ 06 07 $FUNCNAME
			_Clean_Up_ 07 07 $FUNCNAME
		else 
			echo -e "No-Existe $QPATH ejecucion finalizada. \\n"
	fi
	date
	echo "Fin Generar Qbase y Exportar Qgw"|mailx -s "$HOST $FUNCNAME" $email
	echo -e "[ Fin Generar Qbase y Exportar Qgw ]\\n"
}

_Generar__Qbase__(){
	#
	# Logica generacion Qbase
	#
	echo -e "[ Inicio Generacion Qbase ]"
	echo "Inicio Generacion Qbase"|mailx -s "$HOST $FUNCNAME" $email
	date
	if [ -d $QPATHGEN ]
		then
			echo -e "Existe $QPATHGEN continua ejecucion. \\n"
			if [ -d $LDIR/quitersetup ]
				then
					echo -e "Existe $LDIR/quitersetup continua ejecucion sin descargar ni configurar QuiterSetup. \\n"
				else
					echo -e "No-Existe $LDIR/quitersetup continua ejecucion descargando y configurando QuiterSetup. \\n"
					_RepoLin1_ 01 05 $FUNCNAME
					_QsCfgGen_ 02 05 $FUNCNAME
			fi
			_QsExeGen_ 03 05 $FUNCNAME
			_LogEmail_ 04 05 $FUNCNAME
			_Clean_Up_ 05 05 $FUNCNAME
		else 
			echo -e "No-Existe $QPATHGEN ejecucion finalizada. \\n"
	fi
	date
	echo "Fin Generacion Qbase"|mailx -s "$HOST $FUNCNAME" $email
	echo -e "[ Fin Generacion Qbase ]\\n"
}

_Desplegar__InstX(){
	#
	# Logica plataformado instancia Sufijo B C ...
	#
	echo -e "[ Inicio Plataformado $QPATH ]"
	echo "Inicio Plataformado $QPATH"|mailx -s "$HOST $FUNCNAME" $email
	date
	if [ -d $QPATH ]
		then
			echo -e "Existe $QPATH ejecucion finalizada. \\n"
		else 
			echo -e "No-Existe $QPATH continua ejecucion. \\n"
			_RepoLin2_ 01 15 $FUNCNAME
			_Get_Qbase 02 15 $FUNCNAME
			_CfgSufijo 03 15 $FUNCNAME
			_QsCfgPlt_ 04 15 $FUNCNAME
			_QsExePlt_ 05 15 $FUNCNAME
			_DirCfg_X_ 06 15 $FUNCNAME
			_Q_DBLive_ 07 15 $FUNCNAME
			_Q_Rights_ 08 15 $FUNCNAME
			_UpdAccnt_ 09 15 $FUNCNAME
			_Q_Triger_ 10 15 $FUNCNAME
			_Q_ParGen_ 11 15 $FUNCNAME
			_Ko_Qae___ 12 15 $FUNCNAME
			_Q_Proces_ 13 15 $FUNCNAME
			_LogEmail_ 14 15 $FUNCNAME
			_Clean_Up_ 15 15 $FUNCNAME
	fi
	date
	echo "Fin Plataformado $QPATH"|mailx -s "$HOST $FUNCNAME" $email
	echo -e "[ Fin Plataformado $QPATH ]\\n"
}

_Desplegar_Quiter(){
	#
	# Logica plataformado instancia generica
	#
	echo -e "[ Inicio Plataformado $QPATH ]"
	echo "Inicio Plataformado $QPATH"|mailx -s "$HOST $FUNCNAME" $email
	date
	if [ -d $QPATH ]
		then
			echo -e "Existe $QPATH ejecucion finalizada. \\n"
		else 
			echo -e "No-Existe $QPATH continua ejecucion. \\n"
			if [ -d $LDIR/quitersetup ]
				then
					echo -e "Existe $LDIR/quitersetup continua ejecucion sin descargar ni configurar QuiterSetup. \\n"
				else
					echo -e "No-Existe $LDIR/quitersetup continua ejecucion descargando y configurando QuiterSetup. \\n"
					_RepoLin2_ 01 11 $FUNCNAME
					_QsCfgGen_ 02 11 $FUNCNAME
			fi
			_QsExePlt_ 03 11 $FUNCNAME
			_Q_DBLive_ 04 11 $FUNCNAME
			_Q_Rights_ 05 11 $FUNCNAME
			_UpdAccnt_ 06 11 $FUNCNAME
			_Q_Triger_ 07 11 $FUNCNAME
			_Q_ParGen_ 08 11 $FUNCNAME
			_Q_Proces_ 09 11 $FUNCNAME
			_LogEmail_ 10 11 $FUNCNAME
			_Clean_Up_ 11 11 $FUNCNAME
	fi
	date
	echo "Fin Plataformado $QPATH"|mailx -s "$HOST $FUNCNAME" $email
	echo -e "[ Fin Plataformado $QPATH ]\\n"
}

_UniVerse___InstX(){
	#
	# Logica para agregar instancia X despues de instalar UniVerse
	#
	echo -e "[ Inicio UniVerse InstanciaX ]"
	date
	#_CfgSufijo 01 06 $FUNCNAME
	_AddAccnt_ 01 04 $FUNCNAME
	_UpdAccnt_ 02 04 $FUNCNAME
	_Q_Triger_ 03 04 $FUNCNAME
	_Q_ParGen_ 04 04 $FUNCNAME
	#_Q_Rights_ 06 06 $FUNCNAME
	date
	echo -e "[ Fin UniVerse InstanciaX ] \\n"
}

_QuiterRst__InstX(){
	#
	# Logica para habilitar Quiter despues de restaurar
	#
	echo -e "[ Inicio Quiter Instancia Restaurada ]"
	date
	_UpdAccnt_ 01 04 $FUNCNAME
	_Q_Triger_ 02 04 $FUNCNAME
	_Q_ParGen_ 03 04 $FUNCNAME
	_Q_Rights_ 04 04 $FUNCNAME
	date
	echo -e "[ Fin Quiter Instancia Restaurada ] \\n"
}

_Activar_DmsTest_(){
	#
	# Logica despues de refrescar DmsPruebas con datos y aplicacion de DmsProduccion
	#
	echo -e "[ Inicio Activar DmsTest ]"
	date
	#_CP_Rsync_ 01 05 $FUNCNAME
	_UpdAccnt_ 01 04 $FUNCNAME
	_Q_Triger_ 02 04 $FUNCNAME
	_Q_ParGen_ 03 04 $FUNCNAME
	_Q_Rights_ 04 04 $FUNCNAME
	#_Ko_Qae___ 06 06 $FUNCNAME
	date
	echo -e "[ Fin Activar DmsTest ] \\n"
}

_UniVerse_Downld_(){
	#
	# Descargar version UniVerse , Qibk , lib.zip
	# Incorporar en QGW librerias UniVerse que falten.
	# Extrae informacion de la configuracion de UniVerse.
	#
	echo -e "[ Inicio UniVerse Download ]"
	date
	_RepoLin3_ 01 03 $FUNCNAME
	_QgwLibUv_ 02 03 $FUNCNAME
	_UvOldCfg_ 03 03 $FUNCNAME
	date
	echo -e "[ Fin UniVerse Download ] \\n"

}

_UniVerse_Install(){
	#
	# Logica instalacion UniVerse
	#
	echo -e "[ Incio UniVerse Install ]"
	date
	if ipcs -m | grep -q '0xacec';
		then
			echo -e "\\n ¡¡¡¡¡  Existen segmentos de memoria compartida asignados a UniVerse  !!!!! \\n"
			echo -e "\\n ¡¡¡¡¡      P  r  o  c  e  s  o       d  e  t  e  n  i  d  o          !!!!! \\n"
			echo -e "\\n Ejecuta ipcs -m y elimina los segmentos 0xacecXXX con ipcrm -M 0xacecXXX   \\n"
		else
			echo -e "\\n Memoria compartida sin segmentos asignados a UniVerse, continua el proceso \\n"
			_RepoLin3_ 01 11 $FUNCNAME
			_ApartaUv_ 02 11 $FUNCNAME
			_UV__Inst_ 03 11 $FUNCNAME
			_AddAccnt_ 04 11 $FUNCNAME
			_UpdAccnt_ 05 11 $FUNCNAME
			_Q_Triger_ 06 11 $FUNCNAME
			_Q_ParGen_ 07 11 $FUNCNAME
			_QgwLibUv_ 08 11 $FUNCNAME
			_QGW_Lib__ 09 11 $FUNCNAME
			_Qibk_Ins_ 10 11 $FUNCNAME
			_Licen_Uv_ 11 11 $FUNCNAME
	fi
	echo -e $separador
	date
	echo -e "[ Fin UniVerse Install ] \\n"
}

_UniVerse_Upgrade(){
	#
	# Logica Upgrade UniVerse
	#
	echo -e "[ Incio UniVerse Upgrade ]"
	date
	if ipcs -m | grep -q '0xacec';
		then
			echo -e "\\n ¡¡¡¡¡  Existen segmentos de memoria compartida asignados a UniVerse  !!!!! \\n"
			echo -e "\\n ¡¡¡¡¡      P  r  o  c  e  s  o       d  e  t  e  n  i  d  o          !!!!! \\n"
			echo -e "\\n Ejecuta ipcs -m y elimina los segmentos 0xacecXXX con ipcrm -M 0xacecXXX   \\n"
		else
			echo -e "\\n Memoria compartida sin segmentos asignados a UniVerse, continua el proceso \\n"
			_RepoLin3_ 01 08 $FUNCNAME
			_UvOldBak_ 02 08 $FUNCNAME
			_UV__Upgr_ 03 08 $FUNCNAME
			_UpdAccnt_ 04 08 $FUNCNAME
			_Q_Triger_ 05 08 $FUNCNAME
			_QgwLibUv_ 06 08 $FUNCNAME
			_QGW_Lib__ 07 08 $FUNCNAME
			_Licen_Uv_ 08 08 $FUNCNAME
	fi
	echo -e $separador
	date
	echo -e "[ Fin UniVerse Upgrade ] \\n"
}

_Pst_Platform_DMS(){
	#
	# Logica Post-Plataformado DMS Standard
	#
	echo -e "[ Inicio Post-Plataformado DMS Standard ]"
	echo "Inicio Post-Plataformado DMS"|mailx -s "$HOST $FUNCNAME" $email
	date
	_RepoDMS__ 01 23 $FUNCNAME
	_Q_Users__ 02 23 $FUNCNAME
	_Dir_Cfg__ 03 23 $FUNCNAME
	_UV__Inst_ 04 23 $FUNCNAME
	_Licen_Uv_ 05 23 $FUNCNAME 
	_QsCfgPlt_ 06 23 $FUNCNAME
	_QsExePlt_ 07 23 $FUNCNAME
	_Q_Webpag_ 08 23 $FUNCNAME
	_QGW_Inst_ 09 23 $FUNCNAME
	_Q_DBLive_ 10 23 $FUNCNAME
	_Dir_Cfg2_ 11 23 $FUNCNAME
	_Q_Rights_ 12 23 $FUNCNAME
	_Qibk_Ins_ 13 23 $FUNCNAME
	_QAW__Ins_ 14 23 $FUNCNAME
	_UpdAccnt_ 15 23 $FUNCNAME
	_Q_Triger_ 16 23 $FUNCNAME
	_Q_ParGen_ 17 23 $FUNCNAME
	_Q_Proces_ 18 23 $FUNCNAME
	_Sys_Srvs_ 19 23 $FUNCNAME
	_Test_Ftp_ 20 23 $FUNCNAME
	_Fwd_Dms__ 21 23 $FUNCNAME
	_LogEmail_ 22 23 $FUNCNAME
	_Clean_Up_ 23 23 $FUNCNAME
	date
	echo "Fin Post-Plataformado DMS"|mailx -s "$HOST $FUNCNAME" $email
	echo -e "[ Fin Post-Plataformado DMS Standard ] \\n"
}

_Pst_Platform_QAE(){
	#
	# Logica Post-Plataformado QAE Standard
	#
	echo -e "[ Inicio Post-Plataformado QAE Standard ]"
	echo "Inicio Post-Plataformado QAE"|mailx -s "$HOST $FUNCNAME" $email
	date
	_RepoQAE__ 01 05 $FUNCNAME
	_Qae_Inst_ 02 05 $FUNCNAME
	_Fwd_Qae__ 03 05 $FUNCNAME
	_LogEmail_ 04 05 $FUNCNAME
	_Clean_Up_ 05 05 $FUNCNAME
	date
	echo "Fin Post-Plataformado QAE "|mailx -s "$HOST $FUNCNAME" $email
	echo -e "[ Fin Post-Plataformado QAE Standard ] \\n"
}

_Pre_Plataformado(){
	#
	# Logica Pre-Plataformado DMS Standard
	#
	echo -e "[ Incio Pre-Plataformado Standard ]"
	date
	_SElinux__ 01 06 $FUNCNAME
	_LocalTime 02 06 $FUNCNAME	
	_SysUsers_ 03 06 $FUNCNAME
	_Paquetes_ 04 06 $FUNCNAME
	_SysConfig 05 06 $FUNCNAME
	_LogEmail_ 06 06 $FUNCNAME
	echo -e $separador
	date
	#ahora tenemos configurado postfix intentamos enviar email
	echo "Fin Pre-Plataformado"|mailx -s "$HOST $FUNCNAME" $email
	echo -e "[ Fin Pre-Plataformado Standard ] \\n"
}

######################## MAIN 

_Load_Var_
_Redir_Log
_ScriptLog

### funcion CONFIGURA FIREWALL
###		Incluir los interfaces tun100, tap100, tun1000 y TunQis en la zona trusted 
### 	Primero conectamos los interfaces almenos en una ocasion para poder agregarlos en la zona trusted
### 	Recomendado acceder saltando desde QAE para configurar fw del DMS y viceversa
#_Fwd_Dms__
#_Fwd_Qae__

### proceso HABILITAR EN UNIVERSE INSTANCIAX existente en el sistema [agregar cuentas, trigers y pargen]
#_UniVerse___InstX

### proceso DESCARGA UNIVERSE [descarga software E incorpora en QGW las librerias UniVerse que falten]
###		Configurar en Load_Var()
###			version UniVerse a instalar $universever
###			version de librerias que tiene quitergateway.properties $QGWLIBold y version que queremos $QGWLIBnew
###		Este proceso realiza las tareas previas a la instalacion de UniVerse que podemos avanzar sin detener servicios.
###			1.-Verifica si rclone funciona y descargar software.
###			2.-Descarga UniVerse ($universever), qibk y libs.zip.
###			3.-Incorpora en QGW las librerias que falten.
###			4.-Extrae informacion de la configuracion de UniVerse.
###		Cuando posteriormente ejecutemos el proceos _UniVerse_Install estos pasos los omitira.
#_UniVerse_Downld_

### proceso INSTALA UNIVERSE [descarga software, aparta Uv_old, trigers , pargen , qibk , incorpora librerias UniVerse en QGW , QGW conf , licencia]
### 	Configurar en Load_Var()
###			version UniVerse a instalar $universever
###			numero de serie de la licencia $UVSERIE y numero de usuarios $UVUSERS
### 		version de librerias que tiene quitergateway.properties $QGWLIBold y version que queremos $QGWLIBnew
###		Descarga UniVerse ($universever), qibk y libs.zip.
###		Si previamente hemos ejecutado _UniVerse_Downld_ , _UniVerse_Install omite descarga de software e incorporacion en QGW de librerias UniVerse.
###		Asumimos que Uv_old esta detenido.
###		El proceso deja Uv_new detenido para activar.
#_UniVerse_Install
#_Qbi_Vrfy_

### proceso UPGRADE UNIVERSE [descarga software, backup Uv_old, trigers , incorpora librerias UniVerse en QGW , QGW conf , licencia]
### 	Configurar en Load_Var()
###			version UniVerse a instalar $universever
###			numero de serie de la licencia $UVSERIE y numero de usuarios $UVUSERS
### 		version de librerias que tiene quitergateway.properties $QGWLIBold y version que queremos $QGWLIBnew
###		Descarga UniVerse ($universever), qibk y libs.zip.
###		Si previamente hemos ejecutado _UniVerse_Downld_ , _UniVerse_Upgrade omite descarga de software e incorporacion en QGW de librerias UniVerse.
###		Asumimos que Uv_old esta detenido.
###		El proceso deja Uv_new detenido para activar.
#_UniVerse_Upgrade
#_Qbi_Vrfy_

### proceso ACTIVAR DMSTEST [trigers, pargen, desactivar Qae]
### 	Logica despues de refrescar las cuentas principales del DmsPruebas con DmsProduccion
### 	Generalmente el refresco de las cuentas lo hace el cliente.
### 	El proceso incluye:
###			funcion que podemos activar si tenemos que hacer el refresco nosotros
###			funcion que podemos activar si queremos desactivar Qae
### 	Configurar en Load_Var() el identificador de apliacion QAWID y la clave de ftpq en DmsPruebas
#_Activar_DmsTest_

### proceso ACTIVAR QUITER [trigers, pargen, permisos]
### 	Logica despues de restaurar Quiter
#_QuiterRst__InstX

### proceso CAMBIAR DMS ORIGEN LINUX DESTINO LINUX
### 	funcion para EXTRAER CONFIGURACION DEL SISTEMA EN DMSACTUAL
### 	Configurar en Load_Var():
### 		1.- rootuser/rootpassword para rsync
### 		2.- DMSold direccion ip del Dms en produccion-antiguo
#_Old_Cfg__ 1 2 Dms
### 	funcion para EXTRAER DE DMSACTUAL USUARIOS ACTIVOS EN DMS Y GENERAR SCRIPT ALTA DE USER/PASS EN DMSNUEVO
### 	Antes de ejecutar esta funcion es necesario desde QAW exportar a excel los usuarios activos (aunque no utilizamos ese excel)
#_Old_User_ 2 2 Dms
### 	proceso de cambio de servidor, origen linux destino linux. Ejecucion para probar el proceso.
#_Cambio_lin_a_lin
### 	proceso de cambio de servidor, origen linux destino linux. Ejecucion para entrar en produccion.
#_Cambio_lin_a_lin REAL

### proceso CAMBIAR DMS ORIGEN LINUX instancia-X DESTINO LINUX instancia-X
### 	Configurar en _Load_Var():
### 		1.- sufijo B,C,...
### 		2.- rootuser/rootpassword para rsync
### 		3.- DMSold direccion ip del Dms en produccion-antiguo
### 		4.- quiterpass password de quiterb,quiterc... 
### 		5.- ftpqpass   password de ftpq para el PAR_GEN 37
### Damos de alta las cuentas-X en ORIGEN
#_AddAccnt_ 01 02 $FUNCNAME
### Configuramos sistema origen para instancia-X
#_CfgSufijo 02 02 $FUNCNAME
### En el proceso _Cambio_lin_a_lin cambio de servidor, origen linux destino linux
### puenteamos las funciones 07-13 quedando activas las funciones 01-06 y 14. Renumerar funciones de 01 a 07.
#_Cambio_lin_a_lin

### proceso CAMBIAR DMS ORIGEN WINDOWS DESTINO LINUX
### 	Configurar en _Load_Var():
### 		1.- rootuser/rootpassword para plataformar
###			2.- DMSold (Win)
### 	Necesitamos el sitio ftp /quitersetup en DMSold (Win) donde encontrar:
###			Cliente_Qbase.zip
###			Cliente_qjava_qrs_quiterweb_mysql.zip
###		Si DmsOld (Win) tiene credenciales distintas de ftpq collega editar cadena de descarga en funcion _DownUnzip
#_Cambio_win_a_lin

### proceso CAMBIAR QAE
###		Asumimos:
###		1.- Mongo detenido
###		2.- /repositorios/mongodb_data no existe
### 	Configurar en _Load_Var():
### 		1.- rootuser/rootpassword para rsync
#_Cambio_MongoData

### proceso GENERAR QBASE
### 	Asumimos:
### 		1.- Dms pre y post-plataformado.
### 		2.- En el directorio de lanzamiento, QsisKnife descarga dentro de RepoLin si no existen:
###				2.1.- QuiterSetup.zip que utilizamos para generar Qbase
###				2.2.- setup.properties modificado para QsisKnife
### 	Configurar en _Load_Var():
### 		1.- rootuser/rootpassword para generar Qbase
###         2.- sufijoGEN con el sufijo de la instancia a generar Qbase
###		En el directorio de lanzamiento queda RepoLin/$HOST_QuiterSetup.zip con QuiterSetup+Qbase generado
#_Generar__Qbase__

### proceso GENERAR QBASE, EXPORTAR QGW Y SUBIR A DATOSCONVERSION
### 	Asumimos:
### 		1.- Dms pre y post-plataformado.
### 		2.- En el directorio de lanzamiento, QsisKnife descarga dentro de RepoLin si no existen:
###				2.1.- QuiterSetup.zip que utilizamos para generar Qbase
###				2.2.- setup.properties modificado para QsisKnife
### 	Configurar en _Load_Var():
### 		1.- rootuser/rootpassword para generar Qbase
###		En el directorio de lanzamiento queda RepoLin/$HOST_QuiterSetup.zip con el Qbase generado
###		En el directorio de lanzamiento queda RepoLin/$HOST_qjava_qrs_quiterweb_mysql.zip con la exportacion de Ggw
#_GenQbase_ExpGgw_

### proceso DESPLEGAR INSTANCIAX [platafoma quiterX, configura sistema, permisos, trigers, pargen, qdblive, desactivar Qae]
### 	Asumimos:
### 		1.- Dms pre y post-plataformado.
###			2.- En el directorio de lanzamiento, QsisKnife descarga dentro de RepoLin si no existen:
###					2.1.- setup_plataforma.properties modificado para QsisKnife
###					2.2.- QDBLiveLx.tar.gz
###					2.3.- CreaUsuario
### 		3.- En el directorio de lanzamiento, existe RepoLin/$HOST_QuiterSetup.zip con QuiterSetup+Qbase que queremos desplegar.
###					El proceso de generar Qbase nos lo deja asi.
###			4.- Para evitar interferir en produccion plataforma instanciaX con usuario quiterX.
### 	Configurar en _Load_Var():
### 		1.- sufijo B,C,...
### 		2.- quiterpass password de quiterb,quiterc... 
### 		3.- ftpqpass   password de ftpq para el PAR_GEN 37
### 		4.- ip del Dms para el PAR_GEN 42
###		Atencion
###			.- incluye funcion _Get_Qbase__ para 
###			.- incluye funcion _Q_Proces_ para construir los indices del FTORMPT que el Qbase no incluye
###			.- incluye funcion para desactivar QAE
###			.- es posible encadenar GENERAR QBASE y DESPLEGAR INSTANCIAX
#_Desplegar__InstX

### proceso DESPLEGAR QUITER [platafoma quiter, permisos, trigers, pargen, qdblive]
### Este proceso es util cuando por algun motivo el proceso de post-plataformado no desplego Quiter
### 	Asumimos:
###			1.- Dms pre y post-plataformado.
###			2.- En el directorio de lanzamiento, QsisKnife descarga dentro de RepoLin si no existen:
###					2.1.- setup_plataforma.properties modificado para QsisKnife
###					2.2.- QDBLiveLx.tar.gz
###					2.3.- CreaUsuario
###			3.- En el directorio de lanzamiento, existe RepoLin/$HOST_QuiterSetup.zip con QuiterSetup+Qbase que queremos desplegar.
###					El proceso de generar Qbase nos lo deja asi.
### 	Configurar en _Load_Var():
###			1.- rootuser/rootpassword para plataformar
###			2.- ftpqpass   password de ftpq para el PAR_GEN 37
###			3.- ip del Dms para el PAR_GEN 42
###		Atencion
###			.- incluye funcion _Q_Proces_ para construir los indices del FTORMPT que el Qbase no incluye
#_Desplegar_Quiter

### proceso PRE--PLATAFORMADO standard Centos/RedHat_7_8 
#_Pre_Plataformado

### proceso POST-PLATAFORMADO DMS standard
###		Atencion
###			.- incluye funcion _Q_Proces_ para ejecutar procesos en Quiter una vez plataformado
###				por ejemplo construir los indices del FTORMPT que el Qbase no incluye (corregido en 2021/10)
#_Pst_Platform_DMS

### proceso POST-PLATAFORMADO QAE standard
#_Pst_Platform_QAE

exit 0

