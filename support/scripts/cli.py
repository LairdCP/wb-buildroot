#!/usr/bin/env python
from __future__ import print_function
"""
Command Line Interface for the CVE lookup. See README for more information
"""
import argparse
import sys
import re
import os
from collections import defaultdict

# preload XML
import xml.etree.cElementTree as ET
import defusedxml.cElementTree as DET
import re
import glob

xmlstring = []

# NIST url to link to CVEs
NIST_URL = "https://web.nvd.nist.gov/view/vuln/detail?vulnId="

parser = argparse.ArgumentParser(description="Lookup known vulnerabilities from yocto/RPM/SWID in the CVE."+
                                             " Output in JUnit style XML where a CVE = failure")
parser.add_argument("packages", help="The list of packages to run through the lookup", type=open)
parser.add_argument("db_loc", help="The folder that holds the CVE xml database files", type=str)
parser.add_argument("target", help="Target name to run cve-check", type=str)
parser.add_argument("-f", "--format", help="The format of the packages", choices=["swid","rpm",'yocto'], default="yocto")
parser.add_argument("-a", "--fail", help="Severity value [0-10] over which it will be a FAILURE", type=float, default=3)
parser.add_argument("-i", "--skip_file", help="""List of specific CVE's to mark or issue "skipped" in place of failure.
                                                    These CVE's will show up as skip in the report""", type=open)
parser.add_argument("-x", "--pass_file", help="""List with higher precendence than skip_list containing list of specific CVE's
                                                  to mark or issue "pass" in place of failure/skip. These CVE's will show up as "pass"
                                                  in the report""",type=open)
parser.add_argument("-o","--output_file", help="The output file that holds reported  CVE xml found in Sofware", type=str)

def parse_dbs(folder):
    """
    parse the XML dbs and build an in-memory lookup
    :param folder: the folder full of *.xml files
    :return:
    """
    root = None
    for filename in glob.glob(folder+'/*.xml'):
        with open(filename) as f:
            db_string = f.read() # remove the annoying namespace
            db_string = re.sub(' xmlns="[^"]+"', '', db_string, count=1)
            # xmlstring.append(db_string)
            data = ET.fromstring(db_string)
            if root is None:
                root = data
            else:
                root.extend(data)
    return root


#root = ET.fromstring("\n".join(xmlstring))
# namespace ="http://nvd.nist.gov/feeds/cve/1.2"

def etree_to_dict(t):
    """
    Change the xml tree to an easy to use python dict
    :param t: the xml tree
    :return: a dict representation
    """
    d = {t.tag: {} if t.attrib else None}
    children = list(t)
    if children:
        dd = defaultdict(list)
        for dc in map(etree_to_dict, children):
            for k, v in dc.iteritems():
                dd[k].append(v)
        d = {t.tag: {k:v[0] if len(v) == 1 else v for k, v in dd.iteritems()}}
    if t.attrib:
        d[t.tag].update(('@' + k, v) for k, v in t.attrib.iteritems())
    if t.text:
        text = t.text.strip()
        if children or t.attrib:
            if text:
              d[t.tag]['#text'] = text
        else:
            d[t.tag] = text
    return d


def get_packages_swid(package_list):
    """
    Get the packages from a swid string
    :param package_strs:
    :return:
    """
    package_xml = None
    packages = defaultdict(set)
    errors = []
    for xml_doc in package_list.split("\n"):
        try:
            #print('Hello 81 xml_doc="{0}"',format(xml_doc))
            # remove the <? ?> if any
            xml_doc = re.sub('<\?[^>]+\?>', '', xml_doc)
            # use DET since this is untrusted data
            data = DET.fromstring(xml_doc)
            """"""
            name, version = data.attrib['name'], data.attrib['version']
            #print('87 name="{0}" version="{1}"'.format(data.attrib['name'], data.attrib['version']))
            version = version.split("-")[0]
            packages[name].add(version)

        except Exception as e:
            errors.append(str(e))

    return errors, packages


def get_packages_rpm(package_list):
    """
    Get the packages from an rpm string
    :param package_strs:
    :return:
    """
    package_strs = package_list.split("\n")
    packages = defaultdict(set)
    errors = []
    for x in package_strs:
        m = re.search(r'(.*)\|(.*)\|(.*)', x)
        if m:
            (vendor, name, version) = m.groups()
            #path = path or ''
            verrel = version
            packages[name].add(version)

            #print ('118',format([vendor, name, version ]))
        else:
            errors.append('ERROR: Invalid name: %s\n' % x)
    return errors, packages


def get_package_dict(package_list):
    """
    Get the packages from the string
    :param package_strs:
    :return:
    """
    if package_list.startswith("<?xml"):
        return get_packages_swid(package_list)
    else:
        return get_packages_rpm(package_list)


def get_vulns(packages, root):
    """
    Get the vulns from a list of packages returned by get_package_dict()
    :param packages:
    :return:
    """
    result = defaultdict(list)
    for entry in root:
        for vuln_soft in entry.findall("vuln_soft"):
            for prod in vuln_soft.findall("prod"):
                if prod.attrib['name'] in packages:

                    vers = set([x.attrib['num'] for x in prod.findall("vers")])
                    #print('149 prod="{0}" vers="{1}"'.format(prod.attrib['name'], vers))

                    intersection = set(vers).intersection(packages[prod.attrib['name']])

                    #print('intersection="{0}"'.format(intersection))
                    if len(intersection) > 0:
                        si = ' - ' + ','.join(intersection)
                        result[prod.attrib['name'] + si].append(etree_to_dict(entry)["entry"])
    return result

#MAIN
args = parser.parse_args()

#from cve_lookup import *
root = parse_dbs(args.db_loc)

errors, packages = get_package_dict(args.packages.read())
cves = get_vulns(packages, root)

# get the skip list
skip_list = set()
skip_control_lookup = {}
if args.skip_file is not None:
    # first column is CVE, 2nd column is human readable description of control taken
    # eg: CVE-2015-7696 , Device shall never allow decompression of arbitrary zip files
    for line in args.skip_file:
        cols = line.split(",") # split on ,
        if len(cols) > 0:
            cve_id = cols[0].strip()
            cve_control = "N/A"
            if len(cols) > 1:
                cve_control = cols[1]
            # add them to the list
            skip_list.add(cve_id)
            skip_control_lookup[cve_id] = cve_control


# get the pass list
pass_list = set()
pass_control_lookup = {}
if args.pass_file is not None:
    # first column is CVE, 2nd column is human readable description of control taken
    # eg: CVE-2015-7696 , Device shall never allow decompression of arbitrary zip files
    for line in args.pass_file:
        cols = line.split(",") # split on ,
        if len(cols) > 0:
            cve_id = cols[0].strip()
            cve_control = "N/A"
            if len(cols) > 1:
                cve_control = cols[1]
            # add them to the list
            pass_list.add(cve_id)
            pass_control_lookup[cve_id] = cve_control


num_cves = sum(len(x) for x in cves.values())
num_failed_cves = sum(len([e for e in x if (e['@name'] not in skip_list and e['@name'] not in pass_list and float(e['@CVSS_score']) >= args.fail)]) for x in cves.values())
print("Generating CVE file [ Started ]")
if os.path.exists(args.output_file):
	os.remove(args.output_file)

f = open(args.output_file,"w")
# print the xml header
f.write('<?xml version="1.0" encoding="UTF-8" ?>\n')
#print('<testsuites tests="{0}" failures="{0}" > '.format(num_cves))
f.write('<testsuite id="{0}-cve-test" name="{0}-cve-test" tests="{1}" failures="{2}">\n'.format(args.target,num_cves, num_failed_cves))
for package_name, info in cves.iteritems():
    for e in info:
        f.write('<testcase id="{0}" name="{0}" classname="{1}" time="0">\n'.format(e['@name'], package_name))
        try:
            # always warn, but fail if we're above the failure threshold
            sev = "failure" if float(e['@CVSS_score']) >= args.fail else "skip"

            try:
                description = e['desc']['descript']['#text']
            except:
                description = ""

            # mark any CVEs in the skip_list as skipped
            if e['@name'] in skip_list:
                sev = "skip"
                # append the mitigating control
                description += "\n\n Controlled by: " + skip_control_lookup[e['@name']]

            if e['@name'] in pass_list:
                sev = "pass"
                # append the mitigating control
                description += "\n\n Controlled by: " + pass_control_lookup[e['@name']]

            f.write("<{0}> {6} ({1}) - {2} \n\n {3} {4} {5} </{0}>\n".format(sev, e['@CVSS_score'], description,
                                                                   e['@type'], "Published on: " + e['@published'],
                                                                   NIST_URL+e['@name'], e['@severity']))
        except Exception as e:
            f.write('<error>{0}</error>\n'.format(str(e)))

        f.write('</testcase>\n')

f.write("</testsuite>\n")
f.close()
print("File CVE Generated in %s [ Done ]"% args.output_file)
#print "</testsuites>"
