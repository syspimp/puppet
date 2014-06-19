#!/usr/bin/env python
import sys
import ldap
import adconfig
from pprint import pprint
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-t", "--target", type="string", dest="TARGET", help="Target to search for", default=False)
parser.add_option("-u", "--user", action="store_true", dest="USER", help="Search for a user (default)", default=True)
parser.add_option("-c", "--computer", action="store_true", dest="COMPUTER", help="Search for a computer", default=False)

def perform_search(Filter=None,target=None,Base=adconfig.Base,SearchAttrs=adconfig.SearchAttrs):
  try:
    l = ldap.initialize(adconfig.Server)
    Scope = ldap.SCOPE_SUBTREE
    l.protocol_version = 3
    l.set_option(ldap.OPT_REFERRALS, 0)
    l.simple_bind_s(adconfig.username, adconfig.secret)

    r = l.search(Base, Scope, Filter, SearchAttrs)
    Type,user = l.result(r,60)
    Name,Attrs = user[0]
    for attr in adconfig.SearchAttrs:
      if attr in Attrs:
        print Attrs[attr]
  except Exception,e:
    print "Exception!"
    for i in e:
      print i

def check_user(target=None):
  filter="(&(objectClass=user)(sAMAccountName="+target+"))"
  adconfig.SearchAttrs = ["displayName","memberOf"]
  perform_search(filter,target)

def check_computer(target=None):
  filter="(&(objectClass=computer)(sAMAccountName="+target+"$))"
  adconfig.SearchAttrs = ["memberOf"]
  perform_search(filter,target)

def mainloop():
  (options, args) = parser.parse_args()
  if options.COMPUTER and options.TARGET:
    check_computer(options.TARGET)
  elif options.USER and options.TARGET:
    check_user(options.TARGET)
  else:
    print "I need a target! Example: thisscript.py -u -t dtaylor"
    print "Nothing to do!"

if __name__=='__main__':
  try:
    mainloop()
  except Exception as e:
    print "Exception!"
    for i in e:
      print i
  sys.exit()
