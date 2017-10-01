# Test Infrastructure

Peering connection

INTERNAL: Create peering connection
  - TEST ACCOUNT ID
  - TEST VPC ID
  - INTERNAL VPC ID
TEST: Accept peering connection
  - CONNECTION ID (from last step)
INTERNAL: Add route table records
  - TEST VPC CIDR RANGE
  - INTERNAL ROUTE TABLE ID
  - PEERING CONNECTION ID
TEST: Add route table records
  - INTERNAL VPC CIDR RANGE
  - TEST ROUTE TABLE ID
  - PEERING CONNECTION ID
Update security groups
  - INTERNAL ACCOUNT ID
  - JENKINS AGENT SECURITY GROUP ID
  - SWARM MASTER SECURITY GROUP ID

Sharing DNS private zones

TEST: Create VPC association authorization
  - INTERNAL VPC ID
  - TEST HOSTED ZONE ID
INTERNAL: Associate VPC with hosted zone
  - INTERNAL VPC ID
  - TEST HOSTED ZONE ID
TEST: Delete VPC association authorization
  - INTERNAL VPC ID
  - TEST HOSTED ZONE ID
