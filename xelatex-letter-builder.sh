#! /bin/bash
#
#
#  -----------------------------------------------------------
#  |                "XeLaTeX-LetterBuilder"                    |
#  -----------------------------------------------------------

#  Ein BASH-Skript, um automatisiert schön gelayoutete Briefe
#  mit XeLaTeX zu erstelen
#   
#
#    Copyright (C) 2015  Paul Jerabek
#
# __________________________________________________________
#    Dieses Programm ist freie Software. Sie können es unter den 
# Bedingungen der GNU General Public License, wie von der Free 
# Software Foundation veröffentlicht, weitergeben und/oder modifizieren, 
# entweder gemäß Version 3 der Lizenz oder (nach Ihrer Option) jeder 
# späteren Version.
#
#    Die Veröffentlichung dieses Programms erfolgt in der Hoffnung, daß 
# es Ihnen von Nutzen sein wird, aber OHNE IRGENDEINE GARANTIE, sogar 
# ohne die implizite Garantie der MARKTREIFE oder der VERWENDBARKEIT 
# FÜR EINEN BESTIMMTEN ZWECK. 
# 
# Details finden Sie in der GNU General Public License.
# __________________________________________________________
#
#
#
# Dies ist ein Skript, um automatisiert XeLaTeX-Briefe mit der Schriftart
# Linux Libertine und Linux Biolinum zu erstellen. Es wird hierbei auf
# die scrlttr2-Klasse des KOMA-Scripts zurückgegriffen.
#
# Nach einer Reihe von Abfragen öffnet sich der nano-Editor, in dem man den
# Brieftext eingeben kann. Anschließend wird ein PDF-Dokument erzeugt.
#
# Das Skript kann einfach an die eigenen Vorlieben angepasst werden, indem
# die XeLaTeX-Briefvorlage entsprechend geändert wird.
#
# Weiterhin speichert es schon einmal verwendete Absenderdaten im Ordner 
# ~/.xelatex-letter-builder ab, um sie nochmals zu verwenden
#
# Benötigte Pakete: xelatex, fonts-linuxlibertine, nano
#
# 
# 
#  07/01/2015: Version 1.0
#
##############################################################



#
# Definition von Variablen 
#

DATE=`date +%Y-%m-%d`
MAINFONT="Linux Libertine O"
SANSFONT="Linux Biolinum O"
SAVEPATH="$HOME/.xelatex-letter-builder"
MYPWD=`pwd`

#
# Definition von Funktionen
#

function welcome {
echo ""
echo "#################################################"
echo "#    Willkommen zum XeLaTeX-Brief-Generator!    #"
echo "#################################################"
echo ""
echo ""
echo ""
}

function sender {
SENDER=""
echo ""
while [ "$SENDER" == "" ]; do
        echo "#################################################"
        echo "Bitte den Absender eingeben! (q zum Beenden)"
        read SENDER
        if [ "$SENDER" == "q" ]; then
                exit 0
        fi
done
echo "#################################################"
echo ""
echo ""
echo "Absenderanschrift:"
echo ""
echo "Straße und Hausnummer?"
read SENDERSTREET
echo ""
echo "Postleitzahl und Stadt?"
read SENDERCITY
echo ""
echo ""
echo "Telefonnummer?"
read TELEPHONE
if  [ "$TELEPHONE" == "" ]; then       # Name leer?
	INSERTPHONE=""
else	
	INSERTPHONE="		\\usekomavar*{fromphone}  & \usekomavar{fromphone} \\\\"
fi
echo ""
echo ""
echo "Handynummer?"
read MOBILE
if  [ "$MOBILE" == "" ]; then
	INSERTMOBILE=""
else
	INSERTMOBILE="		\\usekomavar*{frommobile} & \usekomavar{frommobile}\\\\"
fi
echo ""
echo ""
echo "E-Mail-Adresse?"
read MAILADDRESS
if  [ "$MAILADDRESS" == "" ]; then
        INSERTMAIL=""
else
        INSERTMAIL="        \\usekomavar*{fromemail}  & \usekomavar{fromemail} \\\\"
fi
echo ""
echo "Homepage?"
read HOMEPAGE
echo ""
if  [ "$HOMEPAGE" == "" ]; then
        INSERTURL=""
else
        INSERTURL="        \\usekomavar*{fromurl}    & \usekomavar{fromurl}"
fi
echo "#################################################"
echo ""
echo ""
}

function recipient {
RECIPIENT=""
echo ""
while [ "$RECIPIENT" == "" ]; do
        echo "#################################################"
        echo "Bitte den Empfängernamen eingeben! (q zum Beenden)"
        read RECIPIENT
        if [ "$RECIPIENT" == "q" ]; then
                exit 0
        fi
done
echo ""
echo "#################################################"
echo ""
echo "Empfängeranschrift:"
echo ""
echo "Straße und Hausnummer?"
read RECIPIENTSTREET
echo ""
echo "Postleitzahl und Stadt?"
read RECIPIENTCITY
echo ""
echo "#################################################"
echo ""
echo ""
}

function city {
echo ""
echo "#################################################"
echo "Stadt neben der Datumsangabe?"
read CITY_TEST
if [ "$CITY_TEST" != "" ]; then
	CITY="$CITY_TEST, "
fi
echo ""
echo "#################################################"
echo ""
echo ""
}

function senddate {
echo ""
echo "#################################################"
echo "Datum? (Default: Heutiges Datum)"
read SENDDATE
if  [ "$SENDDATE" == "" ]; then       # Name leer?
	SENDDATE="\today"
fi
echo ""
echo "#################################################"
echo ""
echo "" 
}

function subject {
echo ""
echo "#################################################"
echo "Betreff?"
read SUBJECT
echo ""
echo "#################################################"
echo ""
echo "" 
}

function opening {
echo ""
echo "#################################################"
echo "Anrede? (Default: Sehr geehrte Damen und Herren)"
read OPENING
if  [ "$OPENING" == "" ]; then       # Name leer?
        OPENING="Sehr geehrte Damen und Herren,"
fi
echo ""
echo "#################################################"
echo ""
echo ""
}

function closing {
echo ""
echo "#################################################"
echo "Grußformel am Ende? (Default: Mit freundlichen Grüßen)"
read CLOSING
if  [ "$CLOSING" == "" ]; then       # Name leer?
        CLOSING="Mit freundlichen Grüßen"
fi
echo ""
echo "#################################################"
echo ""
echo "" 
}

function attachments {
echo ""
echo "#################################################"
echo "Anlagen? (Mehrere Anlagen durch ein \\\\\\\\ voneinander trennen)"
read ATTACHMENTS
if [ "$ATTACHMENTS" == "" ]; then
	INSERTATTACHMENT="% \\encl{$ATTACHMENTS}"
else
	INSERTATTACHMENT=" \\encl{$ATTACHMENTS}"
fi
echo ""
echo "#################################################"
echo ""
echo "" 
}

function makedir {
FOLDERNAME=""
echo ""
while [ "$FOLDERNAME" == "" ]; do
	echo "#################################################"
	echo "Bitte einen Namen zum Speichern eingeben! (q zum Beenden)"
	read FOLDERNAME
	if [ "$FOLDERNAME" == "q" ]; then
		exit 0
	fi
done
mkdir "$MYPWD/$DATE-$FOLDERNAME"
echo "#################################################"
echo ""
echo ""
}

function lettercontent {
CHECK="1"
echo ""
while [ "$CHECK" == "1" ]; do
	echo "#################################################"
	echo "Bitte den Brieftext eingeben! Einfach den gewünschten Text eingeben,"
	echo "anschließend mit Strg+X beenden und mit J und 2x Enter das Speichern bestätigen."
	echo ""
	echo "Jetzt Enter drücken, um den NANO-Editor zu öffnen und Brieftext einzugeben."
	echo ""
	read CHECK
done
touch $MYPWD/$DATE-$FOLDERNAME/lettercontent.dat
nano $MYPWD/$DATE-$FOLDERNAME/lettercontent.dat
LETTERCONTENT=`cat $MYPWD/$DATE-$FOLDERNAME/lettercontent.dat`
echo "#################################################"
echo ""
echo ""
}

function makealetter {
cd "$MYPWD/$DATE-$FOLDERNAME"
cat <<-EOF > "$FOLDERNAME".tex
%!TEX TS−program = xetex
%!TEX encoding = UTF−8 Unicode  
% Für direkte Eingabe der Sonderzeichen

\\documentclass{scrlttr2}

\\KOMAoptions{parskip,locfield=wide,firsthead=false,enlargefirstpage}
%\\LoadLetterOption{DINmtext}       % Aktivieren, um mehr Text auf die Seite zu bekommen. Dann passt aber die Anschrift nicht mehr ins Brieffenster.

\\setkomavar{fromname}{$SENDER}
\\setkomavar{fromaddress}{$SENDERSTREET\\\\$SENDERCITY}
\\setkomavar{fromphone}[Tel.: ]{$TELEPHONE}
\\setkomavar{fromemail}{$MAILADDRESS}
\\setkomavar{fromurl}[Website: ]{$HOMEPAGE}
\\newkomavar[Mobil:]{frommobile}
\\setkomavar{frommobile}{$MOBILE}

\\setkomavar{location}{%
    \\textbf{\usekomavar{fromname}}\\\\
    \\usekomavar{fromaddress}

    \\scriptsize
    \\begin{tabular}[t]{@{}l@{\ }l}
$INSERTPHONE
$INSERTMOBILE
                                 &                        \\\\
$INSERTMAIL
$INSERTURL
    \\end{tabular}

    \\usekomavar{frombank}
}

\\usepackage[ngerman]{babel}
\\usepackage{graphicx}

\\usepackage{fontspec}% provides font selecting commands
\\usepackage{xunicode}% provides unicode character macros
\\usepackage[no-sscript]{xltxtra} % provides some fixes/extras. no-sscript bewirkt, dass die hochgestellten eckigen Klammern richtig dargestellt werden und nicht abrutschen.
\\usepackage{fixltx2e}                 % verbessert einige Kernkompetenzen von LaTeX2e
\\usepackage{setspace} 		       %Einstellen vom Zeilenabstand (\onehalfspacing)
\\usepackage{ellipsis}                 % kümmert sich um den Leerraum rund um die Auslassungspunkte

\\usepackage{amssymb}
\\usepackage{amsmath}
\\renewcommand{\glqq}{„}
\\renewcommand{\grqq}{“}

% Weitere Pakete für xelatex----------------------

% \\usepackage{unicode-math}
% \\defaultfontfeatures{Mapping=tex-text, Numbers=OldStyle} % mit Mediävalziffern
\\defaultfontfeatures{Mapping=tex-text} % mit normalen Ziffern   Damit man lange Striche weiter mit "--" schreiben kann.
\\setmainfont{$MAINFONT}
\\setsansfont{$SANSFONT}
% \\setmathfont[Scale=MatchLowercase]{Asana Math} %Scale=.. notwendig, da Asana Math-Zahlen etwas zu groß sind! Orientiert sich am Schriftbild. 



\\begin{document}

% %-Zeichen entfernen, sofern nötig

% Datum:
 \\setkomavar{date}{$CITY$SENDDATE}
% Ihr Zeichen:
    %\\setkomavar{yourref}{123}
% Ihr Schreiben vom:
    %\\setkomavar{yourmail}{456}
% Unser Zeichen:
    %\\setkomavar{myref}{789}

\\setkomavar{subject}{$SUBJECT}

\\begin{letter}{%
    $RECIPIENT\\\\
    $RECIPIENTSTREET\\\\
    $RECIPIENTCITY
}

\\opening{$OPENING}

$LETTERCONTENT

\\closing{$CLOSING}

% \\ps PS:
$INSERTATTACHMENT
% \\cc{Verteiler}

\\end{letter}
\\end{document}
EOF
xelatex "$FOLDERNAME".tex
}

function savesender {
mkdir -p "$SAVEPATH"
cd "$SAVEPATH"
echo "$SENDER" > sender.dat
echo "$SENDERSTREET" > senderstreet.dat
echo "$SENDERCITY" > sendercity.dat
echo "$TELEPHONE" > telephone.dat
echo "$MOBILE" > mobile.dat
echo "$MAILADDRESS" > mailaddress.dat
echo "$HOMEPAGE" > homepage.dat
}

function checksavepath {
if [ -d "$SAVEPATH" ]; then
	loadsender
else sender
fi
}


function loadsender {
echo ""
echo "#################################################"
echo "J/j drücken, um gespeicherte Daten aus dem Ordner" 
echo "$SAVEPATH zu übernehmen."
echo ""
read LOADDATA
if [[ "$LOADDATA" == "J" || "$LOADDATA" == "j" ]]; then
	cd "$SAVEPATH"
	if [ -f sender.dat ]; then
		SENDER=`cat sender.dat`
	fi
	if [ -f senderstreet.dat ]; then
	        SENDERSTREET=`cat senderstreet.dat`
	fi
	if [ -f sendercity.dat ]; then
	        SENDERCITY=`cat sendercity.dat`
	fi
	if [ -f telephone.dat ]; then
	        TELEPHONE=`cat telephone.dat`
	fi
	if [ -f mobile.dat ]; then
	        MOBILE=`cat mobile.dat`
	fi
	if [ -f mailaddress.dat ]; then
	        MAILADDRESS=`cat mailaddress.dat`
	fi
	if [ -f homepage.dat ]; then
	        HOMEPAGE=`cat homepage.dat`
	fi
	
	echo ""
	echo "#################################################"
	echo ""
	echo "Folgende Daten wurden geladen:"
	echo ""
	echo "- Absender: $SENDER"
	echo "- Absender-Anschrift: $SENDERSTREET, $SENDERCITY"
	echo "- Telefonnummer: $TELEPHONE"
	echo "- Handynummer: $MOBILE"
	echo "- Mailadresse: $MAILADDRESS"
	echo "- Webseite: $HOMEPAGE"
	echo ""
	echo "#################################################"
	echo ""
	echo ""
else
	sender
fi
}

#
# Funktionen ausführen: Brief erstellen
#


welcome
checksavepath
recipient
subject
city
senddate
opening
closing
attachments
makedir
lettercontent
makealetter
savesender

