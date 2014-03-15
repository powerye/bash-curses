#trap '' INT TERM QUIT EXIT
#trap '' WINCH

Initscr() {
    clear
    LINES=`tput lines`
    COLS=`tput cols`
    BUFFER=BUFFER0
    BUFFER0=
    BUFFER1=
    BUFFER2=
    BUFFER3=
}

Closeall() {
    unset LINES COLS
    unset ${!BUFFER@}
}

Setbuffer() {
    [ "$1" = BUFFER[0-3] ] && BUFFER=$1
}

Clean() {
    eval $BUFFER=
}

Add() {
    eval $BUFFER=\"${!BUFFER}\$1\"
}

Move() {
    Add "[${2};${1}H"
}

Refresh() {
    echo -en "${!BUFFER}"
    Clean
}

box() {
    local i

    for i in `seq $1 $3`
    do  Print $i $2 "$6"
        Print $i $4 "${10}"
    done

    for i in `seq $2 $4`
    do  Print $1 $i "${12}"
        Print $3 $i "$8"
    done

    Print $1 $2 "$5"
    Print $3 $2 "$7"
    Print $1 $4 "${11}"
    Print $3 $4 "$9"
}

Box1() {
    box $1 $2 $3 $4 ┌ ─ ┐ │ ┘ ─ └ │ 
}

Box2() {
    box $1 $2 $3 $4 ╔ ═ ╗ ║ ╝ ═ ╚ ║
}

Box3() {
    box $1 $2 $3 $4 '*' '*' '*' '*' '*' '*' '*' '*'
}

Boxu() {
    box $1 $2 $3 $4 ┌ ─ ┐ │ ┤ ─ ├ │
}

Boxd() {
    box $1 $2 $3 $4 ├ ─ ┤ │ ┘ ─ └ │
}

Boxq() {
    box $1 $2 $3 $4 ┌ ─ ┬ │ ┼ ─ ├ │
}

Boxw() {
    box $1 $2 $3 $4 ┬ ─ ┐ │ ┤ ─ ┼ │
}

Boxa() {
    box $1 $2 $3 $4 ├ ─ ┼ │ ┴ ─ └ │
}

Boxs() {
    box $1 $2 $3 $4 ┼ ─ ┤ │ ┘ ─ ┴ │
}

linev() {
    local i

    for((i=$2;i<=$3;i++))
    do  Print $1 $i "$4"
    done
}

lineh() {
    local i

    for((i=$1;i<=$2;i++))
    do  Print $i $3 "$4"
    done
}

line_bc() {
/usr/bin/bc -lq <<EOF
x1=$1
y1=$2
x2=$3
y2=$4
dx=(x2-x1)/200
dy=(y2-y1)/200
while(x1!=x2) {
print x1," ",y1,"\n"
y1+=dy
x1+=dx
}
print x2," ",y2
EOF
}


draw() {
    while read x y
    do  Print ${x%%.*} ${y%%.*} "$1"
    done
}

Line() {
    [ "$1" -eq "$3" ] && linev $1 $(($2>=$4?$4:$2)) $(($2>=$4?$2:$4)) "$5" && return
    [ "$2" -eq "$4" ] && lineh $(($1>=$3?$3:$1)) $(($1>=$3?$1:$3)) $2 "$5" && return
    lineall $1 $2 $3 $4 "$5"
}

Block() {
    local i

    for((i=$2;i<=$4;i++))
    do  for((j=$1;j<=$3;j++))
        do  Print $j $i '█'
        done
    done
}

Beep() {
    tput bel
}

circle_bc() {
/usr/bin/bc -lq <<EOF
pi=4*a(1)
x=$1
y=$2
r=$3
start=($4+90)/180*pi
end=($5+90)/180*pi
p=1.625*$6
for(i=start;i<=end;i+=0.03) {
print x+r*s(i)*p," ",y+r*c(i),"\n"
}
EOF
}

circle() {
    local tmp=`circle_bc $1 $2 $3 $4 $5 $6`
    draw "$7" <<< "$tmp"
}

Circle() {
    circle $1 $2 $3 0 360 1 '*'
}

Circleup() {
    circle $1 $2 $3 0 180 1 '*'
}

Circledown() {
    circle $1 $2 $3 180 360 1 '*'
}

Circleleft() {
    circle $1 $2 $3 90 270 1 '*'
}

Circleright() {
    circle $1 $2 $3 270 450 1 '*'
}

Ellipse() {
    circle $1 $2 $3 0 360 $4 '*'
}

Print() {
#    local tmp=${3:0:$[$COLS-$1+1]}
    Move $1 $2
    Add "${3:0:$[$COLS-$1+1]}"
}

lineall() {
    local tmp=`line_bc $1 $2 $3 $4`
    draw "$5" <<< "$tmp"
}

Printu() {
    local i=$2
    while read -r -s -n1 tmp
    do  Move $1 $i
        Add "$tmp"
        ((i--))
        [ $i -le 0 ] && break
    done <<< "$3"
}

Printd() {
    local i=$2
    while read -r -s -n1 tmp
    do  Move $1 $i
        Add "$tmp"
        ((i++))
        [ $i -gt $LINES ] && break
    done <<< "$3"
}

Printl() {
    local i=$1
    while read -r -s -n1 tmp
    do  Move $i $2
        Add "$tmp"
        ((i--))
        [ $i -le 0 ] && break
    done <<< "$3"
}
