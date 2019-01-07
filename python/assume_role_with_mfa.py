import boto
from boto.sts import STSConnection
from boto.ec2 import EC2Connection

# Role from the trusting account to assume
role_arn = "arn:aws:iam::ACCOUNT-NUMBER-WITHOUT-HYPHENS:role/ROLE-TO-ASSUME"
# String to identify the role session
role_session_name = "AssumeRoleSessionWithMFA"

# MFA device ID (serial number for hardware device or ARN for virtual device)
mfa_serial_number = "arn:aws:iam::ACCOUNT-NUMBER-WITHOUT-HYPHENS:mfa/MFA-DEVICE-ID"

# The calls to AssumeRole must be signed using the access key ID and
# secret access key of an IAM user. The IAM user credentials can be 
# in environment variables or in a configuration file and will be 
# discovered automatically by the STSConnection() function. For more 
# information, see the Python SDK documentation:
# http://boto.readthedocs.org/en/latest/boto_config_tut.html
print "nConnecting to Security Token Service..."
sts_connection = STSConnection()
print "Connection successful."

# Assume the role
print "nAssuming role", role_arn, "using MFA device", mfa_serial_number, "..."
# Prompt for MFA one-time-password
mfa_token = raw_input("Enter the MFA code: ")
role_session = sts_connection.assume_role(
    role_arn=role_arn,
    role_session_name=role_session_name,
    mfa_serial_number=mfa_serial_number,
    mfa_token=mfa_token
)
print "Assumed the role successfully."

# Use the role-provided temporary security credentials to connect to EC2
print "nConnecting to Elastic Compute Cloud service..."
ec2_connection = EC2Connection(
    aws_access_key_id=role_session.credentials.access_key,
    aws_secret_access_key=role_session.credentials.secret_key,
    security_token=role_session.credentials.session_token
)
print "Connection successful."

# Terminate instance
print "nTerminating EC2 instance..."
instance_id = raw_input("Enter id of the instance to teminate: ")
response = ec2_connection.terminate_instances(instance_id)
print response
print "Done."
