define user::ensure_key_value($file, $key, $value, $delimiter = " ") {

    Exec {
        environment => [ "P_KEY=$key",
                         "P_VALUE=$value",
                         "P_DELIM=$delimiter",
                         "P_FILE=$file" ],
        path => "/bin:/usr/bin",
    }

    exec { "update-$name":
        command => 'perl -pi -e \'s{^\Q$ENV{P_KEY}\E\s*\Q$ENV{P_DELIM}\E.*}{$ENV{P_KEY}$ENV{P_DELIM}$ENV{P_VALUE}}g\' --  "$P_FILE"',
        unless  => 'grep -Fxq "${P_KEY}${P_DELIM}${P_VALUE}" "$P_FILE"',
    }
  
    exec { "append-$name":
        command => 'printf "%s\n" "$P_KEY$P_DELIM$P_VALUE" >> "$P_FILE"',
        unless  => 'grep -qxe "^${P_KEY}${P_DELIM}.*$" "$P_FILE"',
    }
}
