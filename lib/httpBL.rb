require 'resolv'
require 'ipaddr'

# Copyright (C) 2007 Richard Heycock
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Simple class to perform a wrap a lookup to the Project Honey Pot
# using the Http:BL API: http://www.projecthoneypot.org/httpbl_api
# You instantiate the object with your access key and then give the
# ip address to lookup. A hash is returned with the results of the
# lookup. If the Project Honey Pot doesn't have any information
# about the particular IP address an empty hash is returned.

class HttpBl

	TYPE = { "0" => [:search_engine],
	         "1" => [:suspicious],
	         "2" => [:harvester],
	         "3" => [:suspicious, :harvester],
	         "4" => [:comment_spammer],
	         "5" => [:suspicious, :comment_spammer],
	         "6" => [:harvester, :comment_spammer],
	         "7" => [:suspicious, :harvester, :comment_spammer] }

	# Create a new HttpBL with the key as required to access this service.
	# See http://www.projecthoneypot.org/httpbl_configure.php to get a key.
	def initialize(key)
		@key = key
	end


	# Perform a lookup on the provided ip address.
	def check(ip_addr)
    ip = IPAddr.new(ip_addr)
		query = "#{@key}.#{ip.reverse.gsub("in-addr.arpa", "dnsbl.httpbl.org")}"

		begin
			lookup = Resolv.getaddress(query)
			values = lookup.split(".")
			{ :last_activity => values[1],
			  :threat => values[2],
			  :type => TYPE[values[3]],
			  :raw_data => lookup
			}
		rescue
			return { :type => [:error] }
		end
	end
end
