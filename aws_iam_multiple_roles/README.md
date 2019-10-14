# This repo shows how you can create multiple IAM Roles from a map

This terraform showcase the new functionality `for_each` in v_0.12+
to iterate over a map of roles and create a IAM Role for each of them.

Unlike `count` it will not update an already created resource if you change an element from the list.

You can access the keys and the values in the map with the special variable `each`

Example:

```hcl-terraform
locals {
  users = {
    John = "value1"
    Doe = "value2"
  }
}
```

`each.key` will give you the keys(E.g. John, Doe)
and `each.value` will give you the value of the key(E.g. value1, value2 etc.)

* If you like me don't like repetitive work, this is ideal for example for creating multiple users/roles in AWS

Example:

```hcl-terraform
resource "aws_iam_role" "iam_role" {
  for_each = local.users

  name = "${each.key}-role"
  description = each.value
  assume_role_policy = file("${path.module}/policies/ecs_task_assume_role.json")
}
```









