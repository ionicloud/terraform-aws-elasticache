#
# Security Group Resources
#
resource "aws_security_group" "this" {
  count = var.create && var.use_existing_security_groups == false ? 1 : 0

  vpc_id = var.vpc_id
  name   = format("%s-elasticcache-sg", var.name)
  tags   = var.tags
}

resource "aws_security_group_rule" "egress" {
  count = var.create && var.use_existing_security_groups == false ? 1 : 0

  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this[0].id
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count = var.create && var.use_existing_security_groups == false ? length(var.allowed_security_groups) : 0

  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_groups[count.index]
  security_group_id        = aws_security_group.this[0].id
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count = var.create && var.use_existing_security_groups == false && length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.this[0].id
  type              = "ingress"
}
