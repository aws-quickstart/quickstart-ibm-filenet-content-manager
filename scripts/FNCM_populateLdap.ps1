# Get the domain components from the command line parmeter
$domain = $args[0].split(".")
$domain_component1 = $domain[0]
$domain_component2 = $domain[1]
#echo $domain_component1
#echo $domain_component2

# Generate the unicode Password for the LDAP users
$password = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes('"{0}"' -f $args[3]))
#echo $password

# Create the LDIF file for import
$LDAP_LDIF="
dn: cn=P8Admin,CN=Users,dc=$domain_component1,dc=$domain_component2
changetype: Add
cn: P8Admin
displayName: P8Admin
objectClass: user
sAMAccountName: P8Admin
sn: P8Admin
userPrincipalName: P8Admin@$domain_component1.$domain_component2
userAccountControl: 66048
unicodePwd::$password

dn: cn=P8User,CN=Users,dc=$domain_component1,dc=$domain_component2
changetype: Add
cn: P8User
displayName: P8User
objectClass: user
sAMAccountName: P8User
sn: P8User
userPrincipalName: P8User@$domain_component1.$domain_component2
userAccountControl: 66048
unicodePwd::$password

dn: cn=P8Admins,CN=Users,dc=$domain_component1,dc=$domain_component2
changetype: Add
objectClass: group
instanceType: 4
name: P8Admins
groupType: -2147483646
samAccountName: P8Admins
member: CN=P8Admin,CN=Users,dc=$domain_component1,dc=$domain_component2

dn: cn=GeneralUsers,CN=Users,dc=$domain_component1,dc=$domain_component2
changetype: Add
objectClass: group
instanceType: 4
name: GeneralUsers
groupType: -2147483646
samAccountName: GeneralUsers
member: CN=P8Admin,CN=Users,dc=$domain_component1,dc=$domain_component2
member: CN=P8User,CN=Users,dc=$domain_component1,dc=$domain_component2

"
#echo $LDAP_LDIF
Out-File -FilePath C:\AWSQuickstart\FNCM_Users_Groups.ldf -InputObject $LDAP_LDIF -Encoding ascii

# Create the import command line
$Executable="ldifde"
$Parameters="-i -v -k -f C:\AWSQuickstart\FNCM_Users_Groups.ldf" + " -s " + $args[0] + " -t 636 -b " + $args[1] + " " + $args[2] + " " + $args[3]
$Parameters=$Parameters.Split(" ")

# Execute the import script
& $Executable $Parameters