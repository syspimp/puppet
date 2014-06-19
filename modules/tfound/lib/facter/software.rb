Facter.add("httpd") do
	setcode do
		FileTest.exist?("/usr/sbin/httpd")
	end
end

Facter.add("php") do
	setcode do
		FileTest.exist?("/usr/lib64/httpd/modules/libphp5.so") or
		FileTest.exist?("/usr/lib/httpd/modules/libphp5.so") or
		FileTest.exist?("/usr/bin/php") or
		FileTest.exist?("/usr/bin/php-cgi")
	end
end

Facter.add("mysql") do
	setcode do
		FileTest.exist?("/usr/bin/mysqld_safe")
	end
end

Facter.add("postgresql") do
	setcode do
		FileTest.exist?("/usr/bin/postmaster")
	end
end


