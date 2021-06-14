#!/bin/bash

declare -Ar NAME_TO_LETTER=(
	[alpha]='Α α'
	[beta]='Β β'
	[gamma]='Γ γ'
	[delta]='Δ δ'
	[epsilon]='Ε ε'
	[zeta]='Ζ ζ'
	[eta]='Η η'
	[theta]='Θ θ'
	[iota]='Ι ι'
	[kappa]='Κ κ'
	[lambda]='Λ λ'
	[mu]='Μ μ'
	[nu]='Ν ν'
	[xi]='Ξ ξ'
	[omicron]='Ο ο'
	[pi]='Π π'
	[rho]='Ρ ρ'
	[sigma]='Σ σ'
	[tau]='Τ τ'
	[upsilon]='Υ υ'
	[phi]='Φ φ'
	[chi]='Χ χ'
	[psi]='Ψ ψ'
	[omega]='Ω ω'
)

main () {
	local names=()
	for i in "$@"; do
		n=$( echo "$i" | tr '[:upper:]' '[:lower:]' )
		if [[ -v "NAME_TO_LETTER[$n]" ]]; then
			names+=( "$n" )
		fi
	done

	local table=$( generate_table "${names[@]}" )

	echo -e "$table"
}

generate_table () {
	local names=("$@")
	local length="${#names[@]}"
	local table=""

	if (( "$length" == 0 )); then
		names=(
			"alpha" "beta" "gamma" "delta" "epsilon" "zeta"
			"eta" "theta" "iota" "kappa" "lambda" "mu"
			"nu" "xi" "omicron" "pi" "rho" "sigma"
			"tau" "upsilon" "phi" "chi" "psi" "omega"
		)
		length="${#names[@]}"
	fi

	if (( "$length" <= 12 )); then
		table=$( generate_double_column_table "${names[@]}" )
	else
		table=$( generate_quadruple_column_table "${names[@]}" )
	fi

	echo -e "$table"
}

generate_double_column_table () {
	local names=("$@")

	local longest=$( longest_string "${names[@]}" )
	if (( "$longest" < 4 )); then longest=4; fi
	local col2_line="$( repeat_string '━' $(( $longest + 2 )) )"

	# Generate header
	local table=$( cat <<- EOF
		┏━━━━━━━━┯${col2_line}┓
		┃ Letter │ $( string_pad_right 'Name' $longest ' ' ) ┃
		┣━━━━━━━━┿${col2_line}┫\n
		EOF
	)

	# Generate body
	for i in "${names[@]}"; do
		table+="┃  ${NAME_TO_LETTER[$i]}   │ "
		table+="$( string_pad_right $i $longest ' ' ) ┃\n"
	done
	table+="┗━━━━━━━━┷${col2_line}┛"

	echo -e "$table"
}

generate_quadruple_column_table () {
	local names=("$@")

	local num_of_names="${#names[@]}"
	local num_of_rows=$(( (num_of_names + 1) / 2 )) # Not counting the header.
	local longest_in_col2=$( longest_string "${names[@]:0:$num_of_rows}" )
	if (( "$longest_in_col2" < 4 )); then longest_in_col2=4; fi
	local longest_in_col4=$(
		longest_string "${names[@]:$(( $num_of_rows ))}"
	)
	if (( "$longest_in_col4" < 4 )); then longest_in_col4=4; fi
	local col2_line="$( repeat_string '━' $(( $longest_in_col2 + 2 )) )"
	local col4_line="$( repeat_string '━' $(( $longest_in_col4 + 2 )) )"

	# Generate header
	local table="┏━━━━━━━━┯${col2_line}┳━━━━━━━━┯${col4_line}┓\n"
	table+="┃ Letter │ "
	table+="$( string_pad_right 'Name' $longest_in_col2 ' ' ) "
	table+="┃ Letter │ "
	table+="$( string_pad_right 'Name' $longest_in_col4 ' ' ) ┃\n"
	table+="┣━━━━━━━━┿${col2_line}╋━━━━━━━━┿${col4_line}┫\n"

	# Generate body
	for (( i=0; i<"$num_of_rows"; i+=1 )); do
		table+="┃  ${NAME_TO_LETTER[${names[$i]}]}   │ "
		table+="$( string_pad_right ${names[$i]} $longest_in_col2 ' ' ) "
		if (( i == "$num_of_rows" - 1 )) && (( ("$num_of_names" % 2) != 0 )); then
			table+="┣━━━━━━━━┷${col4_line}┛\n"
			table+="┗━━━━━━━━┷${col2_line}┛"
		else
			table+="┃  ${NAME_TO_LETTER[${names[$(( $num_of_rows + $i ))]}]}   │ "
			table+="$( string_pad_right ${names[$(( $num_of_rows + $i ))]} $longest_in_col4 ' ' ) ┃\n"
		fi
	done
	if (( ("$num_of_names" % 2) == 0 )); then
		table+="┗━━━━━━━━┷${col2_line}┻━━━━━━━━┷${col4_line}┛"
	fi

	echo -e "$table"
}

longest_string () {
	local array=("$@")

	local m=-1
	for i in "${array[@]}"; do
		if (( "${#i}" > "$m" )); then
			m="${#i}"
		fi
	done

	echo "$m"
}

repeat_string () {
	local ret=""

	for (( i=0; i<"$2"; i+=1 )); do
		ret+="$1"
	done

	echo "$ret"
}

string_pad_right () {
	local str="$1"
	local padded_len="$2"
	local pad="$3"

	local str_len="${#str}"
	local padding=$( repeat_string "$pad" $(( "$padded_len" - "$str_len" )) )
	str="${str}${padding}"

	echo "$str"
}

main "$@"

exit 0
