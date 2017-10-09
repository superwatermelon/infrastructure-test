resource "aws_security_group_rule" "jenkins_agent_to_swarm_manager" {
  type                     = "ingress"
  from_port                = 2375
  to_port                  = 2375
  protocol                 = "tcp"
  source_security_group_id = "${data.terraform_remote_state.internal.jenkins_agent_sg}"
  security_group_id        = "${data.terraform_remote_state.test.swarm_manager_sg}"
}
